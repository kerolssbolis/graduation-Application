import 'package:flutter/material.dart';
import 'package:traffic_app/appcolors.dart';

class AdminOptionsScreen extends StatelessWidget {
  const AdminOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.blueblue,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Action',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),

              // زر إضافة يوزر
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/admin_home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Add New User',
                  style: TextStyle(fontSize: 18),
                ),
              ),
              const SizedBox(height: 20),

              // زر إضافة أدمن
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/add_admin');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Add New Admin',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),

              // زر خريطة الطرق
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.balckblue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  'Go to Route Planner',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
