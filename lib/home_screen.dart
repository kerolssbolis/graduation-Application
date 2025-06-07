import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();

  LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> routePoints = [];
  bool manualInput = false;

  final String mapboxToken =
      'pk.eyJ1Ijoia2Vyb2xzc2JvbGlzIiwiYSI6ImNtYWJ3OGZ4aTJlOWkya3M2OHJnemx3cW8ifQ.lfacom04rCDdmmpb5Sn1jQ';

  Future<void> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    print("📍 Current Location: ${position.latitude}, ${position.longitude}");

    setState(() {
      startPoint = LatLng(position.latitude, position.longitude);
      startController.text = "My Current Location";
      manualInput = true;
    });
  }

  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    final url =
        'https://api.mapbox.com/geocoding/v5/mapbox.places/${Uri.encodeFull(address)}.json?access_token=$mapboxToken';
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['features'] != null && data['features'].isNotEmpty) {
        final coords = data['features'][0]['center'];
        print("📍 Address '$address' resolved to: ${coords[1]}, ${coords[0]}");
        return LatLng(coords[1], coords[0]);
      }
    }
    return null;
  }

  Future<void> getRoute() async {
    if (startPoint == null || endPoint == null) return;

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${startPoint!.longitude},${startPoint!.latitude};${endPoint!.longitude},${endPoint!.latitude}?geometries=geojson&access_token=$mapboxToken';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];
      print(coords);
      setState(() {
        routePoints =
            coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
      });
    }
  }

  Future<void> processRoute() async {
    if (startController.text.isNotEmpty &&
        startController.text != 'My Current Location') {
      startPoint = await getCoordinatesFromAddress(startController.text);
    }

    if (destinationController.text.isNotEmpty) {
      endPoint = await getCoordinatesFromAddress(destinationController.text);
    }

    if (startPoint != null && endPoint != null) {
      await getRoute();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Invalid address(es)")));
    }
  }

  void handleMapTap(LatLng tappedPoint) async {
    if (manualInput) return; // Ignore map taps if manual input is active

    setState(() {
      if (startPoint == null) {
        startPoint = tappedPoint;
        print(
          "🟢 Start Point from map: ${startPoint!.latitude}, ${startPoint!.longitude}",
        );
      } else if (endPoint == null) {
        endPoint = tappedPoint;
        print(
          "🔴 End Point from map: ${endPoint!.latitude}, ${endPoint!.longitude}",
        );
      } else {
        startPoint = tappedPoint;
        print(
          "🟢 New Start Point from map: ${startPoint!.latitude}, ${startPoint!.longitude}",
        );
        endPoint = null;
        routePoints.clear();
      }
    });

    if (startPoint != null && endPoint != null) {
      await getRoute();
    }
  }

  void _onTextInputChanged(String value) {
    if (!manualInput) {
      setState(() {
        manualInput = true;
        startPoint = null;
        endPoint = null;
        routePoints.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = startPoint ?? LatLng(31.2001, 29.9187); // Alexandria

    return Scaffold(
      backgroundColor: Color(0xFF283747),
      appBar: AppBar(
        title: Text("Route Planner"),
        backgroundColor: Colors.teal,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Choose your destination",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: startController,
                    onChanged: _onTextInputChanged,
                    decoration: InputDecoration(
                      hintText: "Enter Start Location",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.my_location, color: Colors.white),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.gps_fixed, color: Colors.blue),
                        onPressed: getCurrentLocation,
                      ),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  TextField(
                    controller: destinationController,
                    onChanged: _onTextInputChanged,
                    decoration: InputDecoration(
                      hintText: "Where to go?",
                      hintStyle: TextStyle(color: Colors.white70),
                      prefixIcon: Icon(Icons.location_on, color: Colors.white),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: processRoute,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "Show Route",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  center: center,
                  zoom: 13,
                  onTap: (_, point) => handleMapTap(point),
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      if (startPoint != null)
                        Marker(
                          point: startPoint!,
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_on,
                            size: 35,
                            color: Colors.green,
                          ),
                        ),
                      if (endPoint != null)
                        Marker(
                          point: endPoint!,
                          width: 80,
                          height: 80,
                          child: Icon(
                            Icons.location_on,
                            size: 35,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                  if (routePoints.isNotEmpty)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routePoints,
                          strokeWidth: 4,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
