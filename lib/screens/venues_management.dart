import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class VenuesManagement extends StatefulWidget {
  const VenuesManagement({super.key});

  @override
  VenuesManagementState createState() => VenuesManagementState();
}

class VenuesManagementState extends State<VenuesManagement> {
  final DatabaseReference _venuesRef =
      FirebaseDatabase.instance.ref().child("venues");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Venues Management'),
      ),
      body: StreamBuilder(
        stream: _venuesRef.onValue,
        builder: (context, AsyncSnapshot<DatabaseEvent> snapshot) {
          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No Venues Available"));
          }

          Map<dynamic, dynamic> venues =
              Map<dynamic, dynamic>.from(snapshot.data!.snapshot.value as Map);
          List<MapEntry<dynamic, dynamic>> venueList = venues.entries.toList();

          return ListView.builder(
            itemCount: venueList.length,
            itemBuilder: (context, index) {
              String venueKey = venueList[index].key;
              Map venueData = venueList[index].value;

              return Card(
                child: ListTile(
                  title: Text(venueData['name'] ?? 'Unnamed Venue'),
                  subtitle: Text("Capacity: ${venueData['capacity']}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          _editVenue(venueKey, venueData);
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _deleteVenue(venueKey);
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

  void _editVenue(String venueKey, Map venueData) {
    // Navigate to Edit Venue Page (To be implemented)
  }

  void _deleteVenue(String venueKey) {
    _venuesRef.child(venueKey).remove();
  }

  void _createVenue() {
    // Navigate to Create Venue Page (To be implemented)
  }
}