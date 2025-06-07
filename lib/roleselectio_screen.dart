import 'package:flutter/material.dart';
import 'package:traffic_app/appcolors.dart';

enum UserRole { user, admin }

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  UserRole? _selectedRole = UserRole.user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:AppColors.blueblue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Account Type',
                style: TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // اختيار User أو Admin
              RadioListTile<UserRole>(
                title: const Text('User',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                value: UserRole.user,
                groupValue: _selectedRole,
                activeColor: Colors.blue,
                onChanged: (UserRole? value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),
              RadioListTile<UserRole>(
                title: const Text('Admin',
                    style: TextStyle(color: Colors.white, fontSize: 20)),
                value: UserRole.admin,
                groupValue: _selectedRole,
                activeColor: Colors.red,
                onChanged: (UserRole? value) {
                  setState(() {
                    _selectedRole = value;
                  });
                },
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                onPressed: () {
                  if (_selectedRole == UserRole.user) {
                    Navigator.pushNamed(context, '/login');
                  } else if (_selectedRole == UserRole.admin) {
                    Navigator.pushNamed(context, '/signup');
                  }
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white,
                ),
                child: Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 20,
                    color: _selectedRole == UserRole.user
                        ? Colors.blue
                        : Colors.red,
                    fontWeight: FontWeight.bold,
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
