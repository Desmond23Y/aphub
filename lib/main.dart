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
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to APHub!',
                style: TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {}, // Navigate to Booking Page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                ),
                child: const Text('Book a Venue'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {}, // Navigate to Facilities Page
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blueAccent,
                ),
                child: const Text('View Facilities'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
