import 'package:flutter/material.dart';
import 'home_page.dart';

void main() {
  runApp(const APHub());
}

class APHub extends StatelessWidget {
  const APHub({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APHub',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const HomePage(),
    );
  }
}
