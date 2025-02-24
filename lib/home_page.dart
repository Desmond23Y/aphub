import 'package:flutter/material.dart';
import 'roles/students.dart';
import 'roles/lecturers.dart';
import 'roles/admins.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APHub'),
        centerTitle: true,
        backgroundColor: Colors.black, // Matches logo theme
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFbebebe), Color(0xFF434343)], // Using your colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/icons/logo_icon.jpg', height: 120), // Adjusted filename
              const SizedBox(height: 20),
              const Text(
                'Select Your Role',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: const TextStyle(fontSize: 18),
      ),
      child: Text(text),
    );
  }
}
