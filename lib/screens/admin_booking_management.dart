import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminBookingManagement extends StatefulWidget {
  const AdminBookingManagement({super.key});

  @override
  State<AdminBookingManagement> createState() => _AdminBookingManagementState();
}

class _AdminBookingManagementState extends State<AdminBookingManagement> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference tpBookingsRef;
  late CollectionReference tpFormRef;

  @override
  void initState() {
    super.initState();
    tpBookingsRef = firestore.collection("TPbooking");
    tpFormRef = firestore.collection("TPform");
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Two tabs: All Bookings and Auditorium Requests
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text("Booking Management",
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Bookings"),
              Tab(text: "Auditorium Requests"),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All Bookings
            _buildAllBookingsTab(),
            // Tab 2: Auditorium Requests
            _buildAuditoriumRequestsTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: All Bookings
  Widget _buildAllBookingsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: tpBookingsRef.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No bookings found",
                style: TextStyle(color: Colors.white)),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> booking = doc.data() as Map<String, dynamic>;
            String status = booking["status"] ?? "pending";
            Color statusColor = _getStatusColor(status);

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text(
                  booking["venueName"] ?? "Unknown Venue",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event: ${booking["eventname"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Date: ${booking["date"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Time: ${booking["startTime"]} - ${booking["endTime"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Status: $status",
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Tab 2: Auditorium Requests
  Widget _buildAuditoriumRequestsTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: tpFormRef.where("venueType", isEqualTo: "Auditorium").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No auditorium requests found",
                style: TextStyle(color: Colors.white)),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> request = doc.data() as Map<String, dynamic>;
            String status = request["status"] ?? "pending";
            Color statusColor = _getStatusColor(status);

            return Card(
              color: Colors.grey[900],
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text(
                  request["venueName"] ?? "Unknown Venue",
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event: ${request["eventname"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Date: ${request["date"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Time: ${request["startTime"]} - ${request["endTime"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Estimated People: ${request["estperson"]}",
                      style: const TextStyle(color: Colors.white),
                    ),
                    Text(
                      "Status: $status",
                      style: TextStyle(color: statusColor),
                    ),
                  ],
                ),
                trailing: status == "pending"
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _approveRequest(doc.id),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _rejectRequest(doc.id),
                          ),
                        ],
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }

  // Approve a request
  Future<void> _approveRequest(String docId) async {
    await tpFormRef.doc(docId).update({"status": "scheduled"});
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Request approved!"),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Reject a request with a reason
  Future<void> _rejectRequest(String docId) async {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text("Reject Request",
              style: TextStyle(color: Colors.white)),
          content: TextField(
            controller: reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Enter reason for rejection...",
              hintStyle: TextStyle(color: Colors.grey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child:
                  const Text("Cancel", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.isNotEmpty) {
                  await tpFormRef.doc(docId).update({
                    "status": "cancelled",
                    "rejectionReason": reasonController.text,
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Request rejected!"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                }
              },
              child: const Text("Reject", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "scheduled":
        return Colors.green;
      case "pending":
        return Colors.yellow;
      case "cancelled":
        return Colors.red;
      default:
        return Colors.white;
    }
  }
}
