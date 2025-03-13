import 'package:flutter/material.dart';

class LecturerRequestPage extends StatelessWidget {
  final String tpNumber;
  const LecturerRequestPage({super.key, required this.tpNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Help')),
      body: const Center(child: Text('Lecturer Request Help Page Content')),
    );
  }
}