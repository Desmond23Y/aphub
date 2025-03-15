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
  final CollectionReference _timeslotsRef =
      FirebaseFirestore.instance.collection("timeslots");

  String _searchQuery = "";
  String _selectedVenueType = "All";
  String? _selectedDate;

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
                    items: [
                      'All',
                      'Labs',
                      'Meeting Room',
                      'Classroom',
                      'Auditorium'
                    ]
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
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: "Filter by date (YYYY-MM-DD)",
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
                        _selectedDate = value.isEmpty ? null : value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _timeslotsRef
                  .where("status", isEqualTo: "available")
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                      child: Text("No Available Venues",
                          style: TextStyle(color: Colors.white)));
                }
                List<QueryDocumentSnapshot> timeslots = snapshot.data!.docs;
                timeslots = timeslots.where((slot) {
                  Map<String, dynamic> slotData =
                      slot.data() as Map<String, dynamic>;
                  String name = (slotData['venueName'] ?? '').toLowerCase();
                  String venueType = (slotData['venueType'] ?? 'N/A');
                  String date = slotData['date'] ?? '';
                  bool matchesSearch =
                      _searchQuery.isEmpty || name.contains(_searchQuery);
                  bool matchesFilter = _selectedVenueType == "All" ||
                      venueType == _selectedVenueType;
                  bool matchesDate =
                      _selectedDate == null || date == _selectedDate;
                  return matchesSearch && matchesFilter && matchesDate;
                }).toList();
                return ListView.builder(
                  itemCount: timeslots.length,
                  itemBuilder: (context, index) {
                    var slot = timeslots[index];
                    Map<String, dynamic> slotData =
                        slot.data() as Map<String, dynamic>;
                    return Card(
                      color: Colors.grey[850],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 10),
                      child: ListTile(
                        title: Text(
                          slotData['venueName'] ?? 'Unnamed Venue',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Date: ${slotData['date']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Time: ${slotData['startTime']} - ${slotData['endTime']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text("Capacity: ${slotData['capacity']}",
                                style: const TextStyle(color: Colors.white70)),
                            Text(
                                "Equipment: ${(slotData['equipment'] as List<dynamic>?)?.join(', ') ?? 'No Equipment'}",
                                style: const TextStyle(color: Colors.white70)),
                          ],
                        ),
                        trailing: ElevatedButton(
                          onPressed: () async {
                            try {
                              // Fetch the user's name from Firestore
                              DocumentSnapshot userDoc = await FirebaseFirestore
                                  .instance
                                  .collection("users")
                                  .doc(widget.tpNumber)
                                  .get();

                              if (!userDoc.exists) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text("User not found!")),
                                );
                                return;
                              }

                              String lecturerName = userDoc["name"] ??
                                  "Unknown Lecturer"; // Default if name is missing

                              String newStatus = "scheduled";

                              // Add the booking to TPbooking collection with user's name
                              await FirebaseFirestore.instance
                                  .collection("TPbooking")
                                  .add({
                                "userId": widget.tpNumber,
                                "name": lecturerName, // Added name field
                                "venueName": slotData['venueName'],
                                "venueType": slotData['venueType'],
                                "date": slotData['date'],
                                "startTime": slotData['startTime'],
                                "endTime": slotData['endTime'],
                                "status": newStatus,
                                "bookedtime": Timestamp.now(),
                              });

                              await FirebaseFirestore.instance
                                  .collection("notifications")
                                  .add({
                                "userId": widget.tpNumber,
                                "venueName": slotData['venueName'],
                                "venueType": slotData['venueType'],
                                "date": slotData['date'],
                                "startTime": slotData['startTime'],
                                "endTime": slotData['endTime'],
                                "bookedtime": Timestamp.now(),
                                "bstatus": "scheduled",
                                "message":
                                    "Your booking for ${slotData['venueName']} on ${slotData['date']} has been successfully scheduled.",
                                "nstatus": "new",
                              });

                              // Update the timeslot status in the timeslots collection
                              await _timeslotsRef
                                  .doc(slot.id)
                                  .update({"status": newStatus});

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text("Booking Successful!")),
                              );
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error: $e")),
                              );
                            }
                          },
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
