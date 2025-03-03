import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditModuleScreen extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final String timeSlot; // Ensure this exists
  final String duration; // Ensure this exists
  final String lecturerId;
  final String lecturerName; // Ensure this exists

  const EditModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.timeSlot, // Add this
    required this.duration, // Add this
    required this.lecturerId,
    required this.lecturerName, // Add this
  });

  @override
  EditModuleScreenState createState() => EditModuleScreenState();
}

class EditModuleScreenState extends State<EditModuleScreen> {
  final TextEditingController _moduleNameController = TextEditingController();
  String? _selectedLecturer;
  String? _selectedTimeSlot;
  final List<String> _timeSlots = ["1hr", "1hr30min", "1hr45min", "2hrs"];
  List<Map<String, String>> _lecturers = [];

  @override
  void initState() {
    super.initState();
    _moduleNameController.text = widget.moduleName;
    _selectedLecturer = widget.lecturerId;
    _selectedTimeSlot = widget.timeSlot;
    _fetchLecturers();
  }

  Future<void> _fetchLecturers() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'Lecturer')
        .get();

    if (!mounted) return;
    setState(() {
      _lecturers = querySnapshot.docs
          .map((doc) => {
                'id': doc.id,
                'name': doc['name'] as String,
              })
          .toList();
    });
  }

  void _updateModule() {
    FirebaseFirestore.instance
        .collection('modules')
        .doc(widget.moduleId)
        .update({
      'moduleName': _moduleNameController.text,
      'lecturerId': _selectedLecturer,
      'timeSlot': _selectedTimeSlot,
    }).then((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Module updated successfully!')),
      );
      Navigator.pop(context);
    }).catchError((error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating module: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Module"),
        backgroundColor: Colors.grey[900],
      ),
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _moduleNameController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Module Name",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 10),

            /// Time Slot Dropdown
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[800],
              value: _selectedTimeSlot ?? _timeSlots.first,
              decoration: InputDecoration(
                labelText: "Time Slot",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _timeSlots.map((slot) {
                return DropdownMenuItem<String>(
                  value: slot,
                  child:
                      Text(slot, style: const TextStyle(color: Colors.white)),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedTimeSlot = value;
                });
              },
            ),
            const SizedBox(height: 10),

            /// Lecturer Dropdown
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[800],
              value: _selectedLecturer,
              decoration: InputDecoration(
                labelText: "Assign Lecturer",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _lecturers.map((lecturer) {
                return DropdownMenuItem<String>(
                  value: lecturer['id'],
                  child: Text(
                    lecturer['name'] ?? "Unknown",
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLecturer = value;
                });
              },
            ),
            const SizedBox(height: 20),

            /// Update Button
            ElevatedButton(
              onPressed: _updateModule,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Update Module",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
