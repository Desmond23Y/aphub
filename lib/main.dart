import 'package:flutter/material.dart';

void main() {
  runApp(const APHub());
}

class APHub extends StatelessWidget {
  const APHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APHub',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('APHub'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to APHub!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {}, // Navigate to Booking Page
              child: const Text('Book a Venue'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {}, // Navigate to Facilities Page
              child: const Text('View Facilities'),
            ),
          ],
        ),
      ),
    );
  }
}
