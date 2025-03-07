import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditModuleScreen extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final String duration;
  final String lecturerName;
  final String lecturerId;

  const EditModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.duration,
    required this.lecturerName,
    required this.lecturerId,
  });

  @override
  EditModuleScreenState createState() => EditModuleScreenState();
}

class EditModuleScreenState extends State<EditModuleScreen> {
  late TextEditingController _moduleNameController;
  late TextEditingController _durationController;
  late TextEditingController _lecturerNameController;
  late TextEditingController _lecturerIdController;
  bool _isUpdating = false; // Prevent duplicate updates

  final CollectionReference _modulesRef =
      FirebaseFirestore.instance.collection("modules");

  @override
  void initState() {
    super.initState();
    _moduleNameController = TextEditingController(text: widget.moduleName);
    _durationController = TextEditingController(text: widget.duration);
    _lecturerNameController = TextEditingController(text: widget.lecturerName);
    _lecturerIdController = TextEditingController(text: widget.lecturerId);
  }

  Future<void> _updateModule() async {
    if (_moduleNameController.text.isEmpty ||
        _durationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Module name and duration are required")),
      );
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      await _modulesRef.doc(widget.moduleId).update({
        "moduleName": _moduleNameController.text,
        "duration": _durationController.text,
        "lecturerName": _lecturerNameController.text,
        "lecturerId": _lecturerIdController.text,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Module updated successfully")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Module")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _moduleNameController,
              decoration: const InputDecoration(labelText: "Module Name"),
            ),
            TextField(
              controller: _durationController,
              decoration: const InputDecoration(labelText: "Duration"),
            ),
            TextField(
              controller: _lecturerNameController,
              decoration: const InputDecoration(labelText: "Lecturer Name"),
            ),
            TextField(
              controller: _lecturerIdController,
              decoration: const InputDecoration(labelText: "Lecturer ID"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isUpdating ? null : _updateModule,
              child: _isUpdating
                  ? const CircularProgressIndicator()
                  : const Text("Update Module"),
            ),
          ],
        ),
      ),
    );
  }
}
