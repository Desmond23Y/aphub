import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id; // TP number
  final String name;
  final List<String> modules;

  User({
    required this.id,
    required this.name,
    required this.modules,
  });

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      name: data['name'] ?? '',
      modules: List<String>.from(data['modules'] ?? []),
    );
  }
}