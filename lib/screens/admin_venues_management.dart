import 'package:aphub/screens/admin_create_venues.dart';
import 'package:aphub/screens/admin_update_venues.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';

class VenuesManagement extends StatefulWidget {
  const VenuesManagement({super.key});

  @override
  VenuesManagementState createState() => VenuesManagementState();
}

class VenuesManagementState extends State<VenuesManagement> {
  final CollectionReference _venuesRef =
      FirebaseFirestore.instance.collection("venues");

  String _searchQuery = "";
  String _selectedVenueType = "All";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          'Venues Management',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.darkdarkgrey,
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
                hintText: "Search venues...",
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

          // Dropdown Filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: DropdownButtonFormField<String>(
              dropdownColor: Colors.grey[800],
              value: _selectedVenueType,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              items: ["All", "Lecture Hall", "Lab", "Auditorium", "Others"]
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type,
                            style: const TextStyle(color: Colors.white)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVenueType = value!;
                });
              },
            ),
          ),

          const SizedBox(height: 10),

          // Venue List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _venuesRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No Venues Available",
                          style: TextStyle(color: Colors.white)));
                }

                List<QueryDocumentSnapshot> venues = snapshot.data!.docs;

                // Apply search and filter
                venues = venues.where((venue) {
                  Map<String, dynamic> venueData =
                      venue.data() as Map<String, dynamic>;
                  String name = (venueData['name'] ?? '').toLowerCase();
                  String venueType = (venueData['venuetype'] ?? 'N/A');
                  bool matchesSearch =
                      _searchQuery.isEmpty || name.contains(_searchQuery);
                  bool matchesFilter = _selectedVenueType == "All" ||
                      venueType == _selectedVenueType;
                  return matchesSearch && matchesFilter;
                }).toList();

                return ListView.builder(
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    var venue = venues[index];
                    String venueId = venue.id;
                    Map<String, dynamic> venueData =
                        venue.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.grey[850], // Dark card background
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          venueData['name'] ?? 'Unnamed Venue',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Capacity: ${venueData['capacity']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Equipment: ${(venueData['equipment'] as List<dynamic>?)?.join(', ') ?? 'No Equipment'}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Venue Type: ${venueData['venuetype'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70)),
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
                              icon: const Icon(Icons.edit, color: Colors.blue),
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
          ),
        ],
      ),

      // Floating Action Button for adding venues
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: _createVenue,
        child: const Icon(Icons.add, color: Colors.white),
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
