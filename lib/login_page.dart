import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../roles/students.dart';
import '../roles/lecturers.dart';
import '../roles/admins.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController tpController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final DatabaseReference _database =
      FirebaseDatabase.instance.ref().child("users");

  Future<void> _login() async {
    String tpNumber = tpController.text.trim();
    String password = passwordController.text.trim();

    if (tpNumber.isEmpty || password.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter TP Number and Password')),
      );
      return;
    }

    try {
      // Define the roles to search in
      List<String> roles = ['admin', 'lecturer', 'student'];
      String? userRole;
      Map<dynamic, dynamic>? userData;

      for (String role in roles) {
        DatabaseEvent event =
            await _database.child(role).child(tpNumber).once();
        DataSnapshot snapshot = event.snapshot;

        if (snapshot.exists && snapshot.value != null) {
          userData = Map<dynamic, dynamic>.from(snapshot.value as Map);
          userRole = role;
          break; // Stop searching if user is found
        }
      }

      if (userData == null || userRole == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User not found')),
        );
        return;
      }

      String storedPassword = userData['password'] ?? '';

      if (password == storedPassword) {
        Widget nextPage;
        if (userRole == 'student') {
          nextPage = const StudentPage();
        } else if (userRole == 'lecturer') {
          nextPage = const LecturerPage();
        } else if (userRole == 'admin') {
          nextPage = const AdminPage();
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Role not recognized')),
          );
          return;
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Incorrect Password')),
        );
      }
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Database Error: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: tpController,
              decoration: const InputDecoration(labelText: 'TP Number'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
