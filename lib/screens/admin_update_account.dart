import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateAccount extends StatefulWidget {
  final String userId;
  final String name;
  final String role;
  final String password;
  final List<String> modules; // Changed to non-nullable

  const UpdateAccount({
    super.key,
    required this.userId,
    required this.name,
    required this.role,
    required this.password,
    required this.modules, // Made required
  });

  @override
  UpdateAccountState createState() => UpdateAccountState();
}

class UpdateAccountState extends State<UpdateAccount> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _modulesController;
  late String _email;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _passwordController = TextEditingController(text: widget.password);

    // Initialize with empty list if null (shouldn't happen since it's required)
    _modulesController = TextEditingController(
      text: widget.modules.join(', '),
    );

    _email = "${widget.userId}@mail.apu.edu.my";
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      final updatedData = <String, dynamic>{
        'name': _nameController.text.trim(),
        'email': _email,
        'password': _passwordController.text.trim(),
      };

      // Handle modules based on role
      if (widget.role == 'Lecturer') {
        updatedData['modules'] = _modulesController.text.isNotEmpty
            ? _modulesController.text
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList()
            : <String>[]; // Ensure it's always a list
      } else {
        // For non-lecturers, completely remove the modules field
        updatedData.remove('modules');
      }

      // Debug print to verify data before saving
      debugPrint('Updating data: $updatedData');

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account updated successfully!"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error updating account: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title:
            const Text("Update Account", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Role (Read-only)
              TextFormField(
                initialValue: widget.role.toUpperCase(),
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Role"),
              ),
              const SizedBox(height: 20),

              // User ID (Read-only)
              TextFormField(
                initialValue: widget.userId,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("User ID"),
              ),
              const SizedBox(height: 20),

              // Name (Editable)
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Name"),
                validator: (value) =>
                    value!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 20),

              // Email (Read-only)
              TextFormField(
                initialValue: _email,
                readOnly: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Email"),
              ),
              const SizedBox(height: 20),

              // Modules (Only for lecturers)
              if (widget.role == 'Lecturer') ...[
                TextFormField(
                  controller: _modulesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Modules (comma separated)"),
                  validator: (value) {
                    if (widget.role == 'Lecturer' && value!.isEmpty) {
                      return 'Please enter at least one module';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
              ],

              // Password (Editable)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Password"),
                validator: (value) =>
                    value!.isEmpty ? "Password is required" : null,
              ),
              const SizedBox(height: 20),

              // Update Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _updateAccount,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.all(15),
                  ),
                  child: const Text("Update Account",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.grey[800],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _modulesController.dispose();
    super.dispose();
  }
}
