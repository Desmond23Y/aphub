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

                // Apply search filter
                users = users.where((user) {
                  Map<String, dynamic> userData =
                      user.data() as Map<String, dynamic>;
                  String name = (userData['name'] ?? '').toLowerCase();
                  bool matchesSearch =
                      _searchQuery.isEmpty || name.contains(_searchQuery);
                  return matchesSearch;
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
                            Text("Role: ${userData['role']}",
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
    _usersRef.doc(userId).delete();
  }

  void _createAccount() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CreateAccount()));
  }
}
