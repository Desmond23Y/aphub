import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateModuleScreen extends StatefulWidget {
  const CreateModuleScreen({super.key});

  @override
  CreateModuleScreenState createState() => CreateModuleScreenState();
}

class CreateModuleScreenState extends State<CreateModuleScreen> {
  final TextEditingController _moduleNameController = TextEditingController();
  String? _selectedLecturer;
  String? _selectedTimeSlot;
  final List<String> _timeSlots = ["1hr", "1hr30min", "1hr45min", "2hrs"];
  final CollectionReference _lecturersRef =
      FirebaseFirestore.instance.collection("users");
  final CollectionReference _modulesRef =
      FirebaseFirestore.instance.collection("modules");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Module"),
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
            StreamBuilder<QuerySnapshot>(
              stream: _lecturersRef
                  .where("role", isEqualTo: "Lecturer")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                var lecturers = snapshot.data!.docs;
                return DropdownButtonFormField<String>(
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
                  items: lecturers.map((doc) {
                    var data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem(
                      value: doc.id,
                      child: Text(data['name'] ?? 'Unknown',
                          style: const TextStyle(color: Colors.white)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLecturer = value;
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[800],
              value: _selectedTimeSlot,
              decoration: InputDecoration(
                labelText: "Select Time Slot",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: _timeSlots.map((slot) {
                return DropdownMenuItem(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createModule,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text("Create Module",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _createModule() async {
    if (_moduleNameController.text.isEmpty ||
        _selectedLecturer == null ||
        _selectedTimeSlot == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    await _modulesRef.add({
      "name": _moduleNameController.text,
      "lecturer": _selectedLecturer,
      "timeSlot": _selectedTimeSlot,
    });

    if (!mounted) return;
    Navigator.pop(context);
  }
}
