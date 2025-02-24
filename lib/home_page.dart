import 'package:flutter/material.dart';
import 'roles/students.dart';
import 'roles/lecturers.dart';
import 'roles/admins.dart';
import 'utils/app_colors.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APHub'),
        centerTitle: true,
        backgroundColor: AppColors.black, // Uses defined color
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.lightGray, AppColors.darkGray], // Uses defined colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/aphub_emblems.jpg', height: 120), // Ensure correct filename
              const SizedBox(height: 20),
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white, // Uses defined color
                ),
              ),
              const SizedBox(height: 30),
              _buildRoleButton(context, 'Student', const StudentPage()),
              const SizedBox(height: 15),
              _buildRoleButton(context, 'Lecturer', const LecturerPage()),
              const SizedBox(height: 15),
              _buildRoleButton(context, 'Admin', const AdminPage()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleButton(BuildContext context, String text, Widget page) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.black,
        foregroundColor: AppColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(text),
    );
  }
}
