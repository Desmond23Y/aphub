import 'package:aphub/screens/admin_create_module.dart';
import 'package:aphub/screens/admin_update_module.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ModuleManagement extends StatefulWidget {
  const ModuleManagement({super.key});

  @override
  ModuleManagementState createState() => ModuleManagementState();
}

class ModuleManagementState extends State<ModuleManagement> {
  final CollectionReference _modulesRef =
      FirebaseFirestore.instance.collection("modules");
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("users");

  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Module Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintText: "Search modules...",
                hintStyle: const TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _modulesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No Modules Available",
                        style: TextStyle(color: Colors.white)),
                  );
                }
                List<QueryDocumentSnapshot> modules = snapshot.data!.docs;
                modules = modules.where((module) {
                  String moduleName =
                      (module["moduleName"] ?? "").toLowerCase();
                  return _searchQuery.isEmpty ||
                      moduleName.contains(_searchQuery);
                }).toList();
                return ListView.builder(
                  itemCount: modules.length,
                  itemBuilder: (context, index) {
                    var module = modules[index];
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          module["moduleName"] ?? "Unknown Module",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Duration: ${module["duration"] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Lecturer: ${module["lecturerName"] ?? 'Unassigned'}",
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editModule(module),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteModule(module.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _createModule,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _createModule() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateModuleScreen()),
    );
  }

  void _editModule(DocumentSnapshot module) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditModuleScreen(
          moduleId: module.id,
          moduleName: module["moduleName"] ?? "Unknown",
          timeSlot: module["timeSlot"] ?? "Not Set", // Ensure this is added
          duration: module["duration"] ?? "N/A",
          lecturerId: module["lecturerId"] ?? "",
          lecturerName: module["lecturerName"] ?? "Unassigned",
        ),
      ),
    );
  }

  void _deleteModule(String moduleId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Confirm Deletion",
              style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to delete this module?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _modulesRef.doc(moduleId).delete();
                Navigator.of(context).pop();
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
