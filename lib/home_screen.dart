import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:traffic_app/appcolors.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? startPoint;
  LatLng? endPoint;
  List<LatLng> routePoints = [];

  String selectedState = 'emergency'; // default
  final TextEditingController durationController = TextEditingController();
  final TextEditingController delayController = TextEditingController();

  final String mapboxToken =
      'pk.eyJ1Ijoia2Vyb2xzc2JvbGlzIiwiYSI6ImNtYWJ3OGZ4aTJlOWkya3M2OHJnemx3cW8ifQ.lfacom04rCDdmmpb5Sn1jQ';

  String apiResponse = ""; // لتخزين الرد النصي من API

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

    setState(() {
      startPoint = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> getRoute() async {
    if (startPoint == null || endPoint == null) return;

    final url =
        'https://api.mapbox.com/directions/v5/mapbox/driving/${startPoint!.longitude},${startPoint!.latitude};${endPoint!.longitude},${endPoint!.latitude}?geometries=geojson&access_token=$mapboxToken';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'];
      setState(() {
        routePoints =
            coords.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
      });
    }
  }

  void handleMapTap(LatLng tappedPoint) async {
    setState(() {
      if (startPoint == null) {
        startPoint = tappedPoint;
      } else if (endPoint == null) {
        endPoint = tappedPoint;
      } else {
        startPoint = tappedPoint;
        endPoint = null;
        routePoints.clear();
      }
    });

    if (startPoint != null && endPoint != null) {
      await getRoute();
    }
  }

  String extractFirstValue(dynamic data) {
    if (data is Map) {
      if (data.isEmpty) return "No data";
      return extractFirstValue(data.values.first);
    } else if (data is List) {
      if (data.isEmpty) return "No data";
      return extractFirstValue(data.first);
    } else {
      return data.toString();
    }
  }

  Future<void> submitData() async {
    if (routePoints.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a route first.")),
      );
      return;
    }

    String state = selectedState == 'emergency' ? 'EMR' : 'ACC';
    int? duration = int.tryParse(durationController.text);
    int? delay = int.tryParse(delayController.text);

    if (duration == null || delay == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Duration and Delay must be integers.")),
      );
      return;
    }

    List<List<double>> coords =
    routePoints.map((point) => [point.latitude, point.longitude]).toList();

    final payload = {
      "coords": coords,
      "state": state,
      "duration": duration,
      "delay": delay
    };

    final response = await http.post(
      Uri.parse("https://taha454-trafficmanager.hf.space/send-coordinates"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(payload),
    );

    final data = json.decode(response.body);
    String value = extractFirstValue(data);

    setState(() {
      if (response.statusCode == 200) {
        apiResponse = "✅ Success:\n$value";
      } else {
        apiResponse = "❌ Error ${response.statusCode}:\n$value";
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Response received, see below.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    LatLng center = startPoint ?? LatLng(31.2001, 29.9187); // Alexandria

    return Scaffold(
      backgroundColor: AppColors.blueblue,
      appBar: AppBar(
        title: Text("Route Planner",style: TextStyle(color: AppColors.balckblue,),),
        backgroundColor: AppColors.blueblue,
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
                    "Select state and durations",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: selectedState,
                    dropdownColor: Colors.grey[900],
                    items: ['emergency', 'accident']
                        .map(
                          (state) => DropdownMenuItem(
                        value: state,
                        child: Text(state, style: TextStyle(color: Colors.white)),
                      ),
                    )
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedState = value!;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: durationController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Duration (int)",
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  TextField(
                    controller: delayController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: "Delay (int)",
                      hintStyle: TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: submitData,
                    child: Text("Submit"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      padding:
                      EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 3,
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
                          child: Icon(Icons.location_on,
                              size: 35, color: Colors.green),
                        ),
                      if (endPoint != null)
                        Marker(
                          point: endPoint!,
                          width: 80,
                          height: 80,
                          child: Icon(Icons.location_on,
                              size: 35, color: Colors.red),
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
            Divider(color: Colors.white70),
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(12),
                color: AppColors.blueblue,
                child: SingleChildScrollView(
                  child: Text(
                    apiResponse.isEmpty ? "Response will appear here" : apiResponse,
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
