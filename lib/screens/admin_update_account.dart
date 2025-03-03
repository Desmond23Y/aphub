import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateAccount extends StatefulWidget {
  final String userId;
  final String name;
  final String role;
  final String password;
  final String? modules;

  const UpdateAccount({
    super.key,
    required this.userId,
    required this.name,
    required this.role,
    required this.password,
    this.modules,
  });

  @override
  UpdateAccountState createState() => UpdateAccountState();
}

class UpdateAccountState extends State<UpdateAccount> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _modulesController;
  String? _selectedRole;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _passwordController = TextEditingController(text: widget.password);
    _modulesController = TextEditingController(text: widget.modules ?? '');
    _selectedRole = widget.role;
  }

  Future<void> _updateAccount() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      Map<String, dynamic> updatedData = {
        'name': _nameController.text.trim(),
        'password': _passwordController.text.trim(),
        'role': _selectedRole, // Ensure role is included
      };

      if (_selectedRole == 'lecturer') {
        updatedData['modules'] = _modulesController.text.trim();
      } else {
        updatedData.remove('modules'); // Remove 'modules' for non-lecturers
      }

      await FirebaseFirestore.instance
          .collection("users")
          .doc(widget.userId)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Account updated successfully!"),
            backgroundColor: Colors.green),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
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
              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                dropdownColor: Colors.grey[900],
                decoration: _inputDecoration("Role"),
                style: const TextStyle(color: Colors.white),
                items: [
                  DropdownMenuItem(
                    value: _selectedRole,
                    child: Text(
                      _selectedRole!.toUpperCase(),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
                onChanged: null, // 🔥 Disables selection
              ),

              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: _inputDecoration("Name"),
                validator: (value) =>
                    value!.isEmpty ? "Name is required" : null,
              ),
              const SizedBox(height: 20),

              // Modules Field (Only for Lecturers)
              if (_selectedRole == 'lecturer') ...[
                TextFormField(
                  controller: _modulesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Modules (Courses Taught)"),
                  validator: (value) =>
                      value!.isEmpty ? "Modules are required" : null,
                ),
                const SizedBox(height: 20),
              ],

              // Password Field
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

  /// **Custom Input Decoration**
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
}
