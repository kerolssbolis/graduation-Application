import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'appcolors.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  _AdminHomeScreenState createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController carNumberController = TextEditingController(); // vehicle_name
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  String? _selectedVehicleType;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('https://taha454-trafficmanager-account.hf.space/mobile/signup/user');

      final payload = {
        "national_id": nationalIdController.text,
        "name": nameController.text,
        "email": emailController.text,
        "phone_number": phoneController.text,
        "password": passwordController.text,
        "vehicle_name": carNumberController.text,
        "vehicle_type": _selectedVehicleType,
      };

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          _showSuccessDialog();
          nameController.clear();
          phoneController.clear();
          emailController.clear();
          nationalIdController.clear();
          carNumberController.clear();
          passwordController.clear();
          confirmPasswordController.clear();
          setState(() {
            _selectedVehicleType = null;
          });
        } else {
          _showErrorDialog("Failed: ${response.statusCode} - ${response.body}");
        }
      } catch (e) {
        _showErrorDialog("Error: $e");
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Success'),
        content: const Text('User added successfully.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField() {
    const vehicleTypes = ['emergency', 'ambulance', 'police', 'government'];

    return DropdownButtonFormField<String>(
      value: _selectedVehicleType,
      items: vehicleTypes.map((type) {
        return DropdownMenuItem<String>(
          value: type,
          child: Text(
            type,
            style: const TextStyle(color: Colors.black), // داخل القائمة
          ),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedVehicleType = value;
        });
      },
      decoration: InputDecoration(
        labelText: 'Vehicle Type',
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dropdownColor: Colors.white,
      style: const TextStyle(color: Colors.white), // يظهر في الحقل
      selectedItemBuilder: (BuildContext context) {
        return vehicleTypes.map((type) {
          return Text(
            type,
            style: const TextStyle(color: Colors.white), // النص المختار
          );
        }).toList();
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select a vehicle type';
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueblue,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        title: const Text('Admin Dashboard'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                'Add New User',
                style: TextStyle(fontSize: 24, color: Colors.white),
              ),
              const SizedBox(height: 30),

              _buildTextField(nameController, 'Full Name'),
              const SizedBox(height: 20),

              _buildTextField(phoneController, 'Phone Number',
                  keyboardType: TextInputType.phone),
              const SizedBox(height: 20),

              _buildTextField(emailController, 'Email',
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 20),

              _buildTextField(nationalIdController, 'National ID',
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter National ID';
                    } else if (value.length != 14) {
                      return 'National ID must be 14 digits';
                    }
                    return null;
                  }),
              const SizedBox(height: 20),

              _buildTextField(carNumberController, 'Vehicle Name'),
              const SizedBox(height: 20),

              _buildDropdownField(),
              const SizedBox(height: 20),

              _buildTextField(passwordController, 'Password',
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter Password';
                    } else if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  }),
              const SizedBox(height: 20),

              _buildTextField(confirmPasswordController, 'Confirm Password',
                  obscureText: _obscureConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white70,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm the password';
                    } else if (value != passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  }),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.balckblue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Add User',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
        Widget? suffixIcon,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white54),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.blue),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      style: const TextStyle(color: Colors.white),
      validator: validator ??
              (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter $label';
            }
            return null;
          },
    );
  }
}
