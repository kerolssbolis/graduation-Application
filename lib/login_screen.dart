import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'appcolors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController vehicleNumberController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _obscurePassword = true;

  String? nationalIdError;
  String? vehicleNumberError;
  String? passwordError;

  Future<bool> login(String nationalId, String vehicleNumber, String password) async {
    final url = Uri.parse("https://taha454-trafficmanager-account.hf.space/mobile/login/");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "national_id": nationalId,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(data);
      return true;
    } else {
      print("Error: ${response.statusCode} - ${response.body}");
      return false;
    }
  }

  void _validateAndLogin() async {
    final nationalId = nationalIdController.text.trim();
    final vehicleNumber = vehicleNumberController.text.trim();
    final password = passwordController.text.trim();

    setState(() {
      nationalIdError = nationalId.length != 14 ? 'Enter a valid 14-digit ID' : null;
      vehicleNumberError = vehicleNumber.isEmpty ? 'Vehicle number is required' : null;
      passwordError = password.isEmpty ? 'Password is required' : null;
    });

    if (nationalIdError == null && vehicleNumberError == null && passwordError == null) {
      bool success = await login(nationalId, vehicleNumber, password);
      if (success) {
        Navigator.pushNamed(context, '/home');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login failed. Please check your credentials.')),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String? errorText,
    required TextInputType keyboardType,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: 'Enter your $label',
            hintStyle: const TextStyle(color: Colors.white),
            errorText: errorText,
            prefixIcon: Icon(icon, color: Colors.white),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w300,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            hintText: 'Enter your password',
            hintStyle: const TextStyle(color: Colors.white),
            errorText: passwordError,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          style: const TextStyle(color: Colors.white),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueblue,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Login to your account',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w300,
                  fontSize: 32,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Welcome back',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 35),
              _buildTextField(
                label: 'National ID',
                controller: nationalIdController,
                errorText: nationalIdError,
                keyboardType: TextInputType.number,
                icon: Icons.credit_card,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                label: 'Vehicle Number',
                controller: vehicleNumberController,
                errorText: vehicleNumberError,
                keyboardType: TextInputType.text,
                icon: Icons.directions_car,
              ),
              const SizedBox(height: 20),
              _buildPasswordField(),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _validateAndLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Login',
                    style: TextStyle(fontSize: 20, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
