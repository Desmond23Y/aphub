import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpdateModuleScreen extends StatefulWidget {
  final String moduleId; // Document ID of the module to update
  final String moduleName; // Existing module name
  final String duration; // Existing duration
  final String? lecturerId; // Existing lecturer ID
  final String? lecturerName; // Existing lecturer name

  const UpdateModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.duration,
    this.lecturerId,
    this.lecturerName,
  });

  @override
  UpdateModuleScreenState createState() => UpdateModuleScreenState();
}

class UpdateModuleScreenState extends State<UpdateModuleScreen> {
  final TextEditingController _moduleNameController = TextEditingController();
  String? _selectedDuration;
  String? _selectedLecturerId;
  String? _selectedLecturerName;

  bool _isSaving = false; // To prevent duplicate requests

  final CollectionReference _modulesRef =
      FirebaseFirestore.instance.collection("modules");
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("users");

  final List<String> _durations = [
    "1 hour",
    "1 hour 30 minutes",
    "1 hour 45 minutes",
    "2 hours"
  ];

  @override
  void initState() {
    super.initState();

    // Pre-fill the form fields with the existing module data
    _moduleNameController.text = widget.moduleName;
    _selectedDuration = widget.duration;
    _selectedLecturerId = widget.lecturerId;
    _selectedLecturerName = widget.lecturerName;

    // Ensure _selectedDuration is in the _durations list
    if (!_durations.contains(_selectedDuration)) {
      _selectedDuration = null; // Reset to null if not found
    }
  }

  Future<void> _updateModule() async {
    if (_moduleNameController.text.isEmpty || _selectedDuration == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Module name and duration are required")),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await _modulesRef.doc(widget.moduleId).update({
        "moduleName": _moduleNameController.text,
        "duration": _selectedDuration,
        "lecturerName": _selectedLecturerName ?? "Unassigned",
        "lecturerId": _selectedLecturerId ?? "",
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
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Module")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _moduleNameController,
              decoration: const InputDecoration(labelText: "Module Name"),
            ),
            const SizedBox(height: 16),

            // Duration Dropdown
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: "Duration"),
              value: _selectedDuration,
              items: _durations
                  .map((duration) => DropdownMenuItem(
                        value: duration,
                        child: Text(duration),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDuration = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // Lecturer Dropdown
            StreamBuilder<QuerySnapshot>(
              stream:
                  _usersRef.where("role", isEqualTo: "Lecturer").snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                List<QueryDocumentSnapshot> lecturers = snapshot.data!.docs;

                if (lecturers.isEmpty) {
                  return const Text("No lecturers available");
                }

                // Ensure _selectedLecturerId is in the lecturers list
                final lecturerIds =
                    lecturers.map((lecturer) => lecturer.id).toList();
                if (!lecturerIds.contains(_selectedLecturerId)) {
                  _selectedLecturerId = null; // Reset to null if not found
                }

                return DropdownButtonFormField<String>(
                  decoration:
                      const InputDecoration(labelText: "Select Lecturer"),
                  value: _selectedLecturerId,
                  items: lecturers.map((lecturer) {
                    final data = lecturer.data() as Map<String, dynamic>;

                    return DropdownMenuItem<String>(
                      value: lecturer.id,
                      child: Text(data["name"] ?? "Unknown"),
                    );
                  }).toList(),
                  onChanged: (value) {
                    final selectedLecturer = lecturers.firstWhere(
                      (lecturer) => lecturer.id == value,
                    );

                    final lecturerData =
                        selectedLecturer.data() as Map<String, dynamic>;

                    setState(() {
                      _selectedLecturerId = value;
                      _selectedLecturerName = lecturerData["name"];
                    });
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // Update Button
            ElevatedButton(
              onPressed: _isSaving ? null : _updateModule,
              child: _isSaving
                  ? const CircularProgressIndicator()
                  : const Text("Update Module"),
            ),
          ],
        ),
      ),
    );
  }
}
