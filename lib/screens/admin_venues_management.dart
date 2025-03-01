import 'package:aphub/screens/admin_create_venues.dart';
import 'package:aphub/screens/admin_update_venues.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VenuesManagement extends StatefulWidget {
  const VenuesManagement({super.key});

  @override
  VenuesManagementState createState() => VenuesManagementState();
}

class VenuesManagementState extends State<VenuesManagement> {
  final CollectionReference _venuesRef =
      FirebaseFirestore.instance.collection("venues");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues Management'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _venuesRef.snapshots(), // Listen to Firestore updates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No Venues Available"));
          }

          List<QueryDocumentSnapshot> venues = snapshot.data!.docs;

          return ListView.builder(
            itemCount: venues.length,
            itemBuilder: (context, index) {
              var venue = venues[index];
              String venueId = venue.id;
              Map<String, dynamic> venueData =
                  venue.data() as Map<String, dynamic>;

              return Card(
                child: ListTile(
                  title: Text(venueData['name'] ?? 'Unnamed Venue'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Capacity: ${venueData['capacity']}"),
                      Text(
                          "Equipment: ${(venueData['equipment'] as List<dynamic>?)?.join(', ') ?? 'No Equipment'}"),
                      Text("Venue Type: ${venueData['venuetype'] ?? 'N/A'}"),
                      Text(
                        "Status: ${venueData['status'] ?? 'N/A'}",
                        style: TextStyle(
                          color: venueData['status'] == 'available'
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editVenue(venueId, venueData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteVenue(venueId);
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
      floatingActionButton: FloatingActionButton(
        onPressed: _createVenue,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _editVenue(String venueId, Map<String, dynamic> venueData) {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => EditVenuePage(
                venueId: venueId,
                venueData: venueData,
              )),
    );
  }

  void _deleteVenue(String venueId) {
    _venuesRef.doc(venueId).delete();
  }

  void _createVenue() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CreateVenuePage()),
    );
  }
}
