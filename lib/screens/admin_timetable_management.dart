import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlotManagement extends StatefulWidget {
  const TimeSlotManagement({super.key});

  @override
  TimeSlotManagementState createState() => TimeSlotManagementState();
}

class TimeSlotManagementState extends State<TimeSlotManagement> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference timeslotsRef;
  String searchQuery = "";
  String selectedStatus = "All";
  String selectedVenueType = "All";

  @override
  void initState() {
    super.initState();
    timeslotsRef = firestore.collection("timeslots");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set background color to black
      appBar: AppBar(
        title: const Text(
          "Time Slot Management",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search by venue name, date, or status...",
                hintStyle: const TextStyle(color: Colors.white70),
                prefixIcon: const Icon(Icons.search, color: Colors.white70),
                filled: true,
                fillColor: Colors.grey[850],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                  items: ["All", "available", "booked", "scheduled"]
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                ),
                DropdownButton<String>(
                  dropdownColor: Colors.black,
                  value: selectedVenueType,
                  onChanged: (value) {
                    setState(() {
                      selectedVenueType = value!;
                    });
                  },
                  items: [
                    "All",
                    "Auditorium",
                    "Classroom",
                    "Lab",
                    "Meeting Room"
                  ]
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type,
                                style: const TextStyle(color: Colors.white)),
                          ))
                      .toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: timeslotsRef.orderBy("date").snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No Time Slots Available",
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                var timeslots = snapshot.data!.docs.where((doc) {
                  Map<String, dynamic> data =
                      doc.data() as Map<String, dynamic>;

                  // Apply search filter
                  String venueName = data['venueName'].toLowerCase();
                  String date = data['date'].toLowerCase();
                  String status = data['status'].toLowerCase();

                  bool matchesSearch = venueName.contains(searchQuery) ||
                      date.contains(searchQuery) ||
                      status.contains(searchQuery);

                  // Apply status filter
                  bool matchesStatus = selectedStatus == "All" ||
                      data['status'] == selectedStatus;

                  // Apply venue type filter
                  bool matchesVenueType = selectedVenueType == "All" ||
                      data['venueType'] == selectedVenueType;

                  return matchesSearch && matchesStatus && matchesVenueType;
                }).toList();

                return ListView.builder(
                  itemCount: timeslots.length,
                  itemBuilder: (context, index) {
                    var slot = timeslots[index];
                    Map<String, dynamic> data =
                        slot.data() as Map<String, dynamic>;

                    // Convert Firestore date (String) to formatted date
                    String formattedDate = DateFormat("dd MMM yyyy").format(
                      DateTime.parse(data['date']),
                    );

                    return Card(
                      color: Colors.grey[900],
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        title: Text(
                          data['venueName'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Date: $formattedDate",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Time: ${data['startTime']} - ${data['endTime']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Block: ${data['block']} | Level: ${data['level']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Capacity: ${data['capacity']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Venue Type: ${data['venueType']}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Equipment: ${data['equipment'].join(", ")}",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              "Status: ${data['status']}",
                              style: TextStyle(
                                color: data['status'] == 'available'
                                    ? Colors.green
                                    : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
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
    );
  }
}
