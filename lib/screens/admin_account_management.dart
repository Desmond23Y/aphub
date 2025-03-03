import 'package:aphub/screens/admin_create_account.dart';
import 'package:aphub/screens/admin_update_account.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AccountManagement extends StatefulWidget {
  const AccountManagement({super.key});

  @override
  AccountManagementState createState() => AccountManagementState();
}

class AccountManagementState extends State<AccountManagement> {
  final CollectionReference _usersRef =
      FirebaseFirestore.instance.collection("users");

  String _searchQuery = "";
  String _selectedRole = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Account Management',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.white),
                hintText: "Search accounts...",
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
          const SizedBox(height: 10),
          // Role Filter Dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: DropdownButtonFormField<String>(
              value: _selectedRole,
              dropdownColor: Colors.grey[800],
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: ["All", "Student", "Lecturer", "Admin"]
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role,
                            style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Account List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No Accounts Available",
                          style: TextStyle(color: Colors.white)));
                }

                List<QueryDocumentSnapshot> users = snapshot.data!.docs;

                // Apply search filter and role filter
                users = users.where((user) {
                  Map<String, dynamic> userData =
                      user.data() as Map<String, dynamic>;

                  String name = (userData['name'] ?? '')
                      .toLowerCase(); // Access name at top-level
                  String role = (userData['role'] ?? '')
                      .toLowerCase(); // Try accessing role at top-level first

                  // If role is inside "modules", fetch from there
                  if (role.isEmpty && userData.containsKey('modules')) {
                    role = (userData['modules']['role'] ?? '').toLowerCase();
                  }

                  bool matchesSearch =
                      _searchQuery.isEmpty || name.contains(_searchQuery);
                  bool matchesRole = _selectedRole == "All" ||
                      role == _selectedRole.toLowerCase();

                  return matchesSearch && matchesRole;
                }).toList();

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    var user = users[index];
                    String userId = user.id;
                    Map<String, dynamic> userData =
                        user.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          userData['name'] ?? 'Unknown User',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("TP Number: $userId",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Role: ${userData['role'] ?? userData['modules']?['role'] ?? 'No role'}",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Email: ${userData['email'] ?? 'No email'}",
                                style: const TextStyle(color: Colors.white70)),
                            if (userData['role'] == 'Lecturer')
                              Text(
                                  "Modules: ${userData['modules'] ?? 'Not assigned'}",
                                  style:
                                      const TextStyle(color: Colors.white70)),
                            Text(
                                "Password: ${userData['password'] ?? 'Not available'}",
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _editAccount(userId, userData);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteAccount(userId);
                              },
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

      // Floating Action Button for adding accounts
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _createAccount,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _editAccount(String userId, Map<String, dynamic> userData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UpdateAccount(
          userId: userId,
          name: userData['name'] ?? '',
          role: userData['role'] ?? '',
          password: userData['password'] ?? '',
          modules: userData['modules'] ?? '',
        ),
      ),
    );
  }

  void _deleteAccount(String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Confirm Deletion",
              style: TextStyle(color: Colors.white)),
          content: const Text("Are you sure you want to delete this account?",
              style: TextStyle(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () {
                _usersRef.doc(userId).delete();
                Navigator.of(context).pop(); // Close the dialog after deletion
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _createAccount() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CreateAccount()));
  }
}
