import 'package:flutter/material.dart';

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
  final TextEditingController carNumberController = TextEditingController();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final name = nameController.text;
      final phone = phoneController.text;
      final email = emailController.text;
      final nationalId = nationalIdController.text;
      final carNumber = carNumberController.text;

      // Placeholder - replace with actual DB or API logic
      print('Name: $name');
      print('Phone: $phone');
      print('Email: $email');
      print('National ID: $nationalId');
      print('Car Number: $carNumber');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User added successfully')),
      );

      // Clear fields after submission
      nameController.clear();
      phoneController.clear();
      emailController.clear();
      nationalIdController.clear();
      carNumberController.clear();
    }
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

              _buildTextField(carNumberController, 'Car Number'),
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

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
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


