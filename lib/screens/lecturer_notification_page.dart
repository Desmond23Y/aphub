import 'package:flutter/material.dart';

class LecturerNotificationPage extends StatelessWidget {
  final String tpNumber;
  const LecturerNotificationPage({super.key, required this.tpNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lecturer Notifications')),
      body: const Center(child: Text('Lecturer Notification Page Content')),
    );
  }
}