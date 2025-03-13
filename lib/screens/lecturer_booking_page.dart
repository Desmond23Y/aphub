import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/app_colors.dart';

class LecturerBookingPage extends StatefulWidget {
  final String tpNumber;
  
  const LecturerBookingPage({super.key, required this.tpNumber});

  @override
  LecturerBookingPageState createState() => LecturerBookingPageState();
}

class LecturerBookingPageState extends State<LecturerBookingPage> {
  final CollectionReference _venuesRef =
      FirebaseFirestore.instance.collection("venues");

  String _searchQuery = "";
  String _selectedVenueType = "All";
  bool _showOnlyAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Text(
          'Book a Venue',
          style: TextStyle(color: AppColors.white),
        ),
        backgroundColor: AppColors.darkdarkgrey,
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      body: Column(
        children: [
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
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
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
                    items: ['All', 'Labs', 'Meeting room', 'Classroom', 'Auditorium']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type, style: const TextStyle(color: Colors.white)),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedVenueType = value!;
                      });
                    },
                  ),
                ),
                Switch(
                  value: _showOnlyAvailable,
                  onChanged: (value) {
                    setState(() {
                      _showOnlyAvailable = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
                const Text(
                  "Available Only",
                  style: TextStyle(color: Colors.white),
                )
              ],
            ),
          ),
          const SizedBox(height: 10),
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
                venues = venues.where((venue) {
                  Map<String, dynamic> venueData = venue.data() as Map<String, dynamic>;
                  String name = (venueData['name'] ?? '').toLowerCase();
                  String venueType = (venueData['venuetype'] ?? 'N/A');
                  String status = (venueData['status'] ?? 'unavailable');
                  bool matchesSearch = _searchQuery.isEmpty || name.contains(_searchQuery);
                  bool matchesFilter = _selectedVenueType == "All" || venueType == _selectedVenueType;
                  bool matchesAvailability = !_showOnlyAvailable || status == 'available';
                  return matchesSearch && matchesFilter && matchesAvailability;
                }).toList();
                return ListView.builder(
                  itemCount: venues.length,
                  itemBuilder: (context, index) {
                    var venue = venues[index];
                    Map<String, dynamic> venueData = venue.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
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
                            Text("Venue Type: ${venueData['venuetype'] ?? 'N/A'}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                              "Status: ${venueData['status'] ?? 'N/A'}",
                              style: TextStyle(
                                color: venueData['status'] == 'available' ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: venueData['status'] == 'available'
                              ? () {
                                  // Proceed with booking process
                                }
                              : null,
                          child: const Text("Book"),
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
    );
  }
}
