import 'package:aphub/utils/app_colors.dart';
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

  // State for selected filter
  String _selectedStatusFilter = "All"; // Default: Show all bookings

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
        backgroundColor: AppColors.black,
        appBar: AppBar(
          title: const Text("Booking Management",
              style: TextStyle(color: AppColors.white)),
          backgroundColor: AppColors.darkdarkgrey,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          actions: [
            // Dropdown for status filter
            DropdownButton<String>(
              value: _selectedStatusFilter,
              dropdownColor: AppColors.darkdarkgrey,
              icon: const Icon(Icons.filter_list, color: AppColors.white),
              underline: Container(),
              items: <String>[
                "All",
                "scheduled",
                "pending",
                "cancelled",
                "history",
                "completed"
              ].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    value,
                    style: const TextStyle(color: AppColors.white),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStatusFilter = newValue!;
                });
              },
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: "All Bookings"),
              Tab(text: "Auditorium Requests"),
            ],
            indicatorColor: Colors.blue,
            labelColor: Colors.blue,
            unselectedLabelColor: AppColors.white,
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All Bookings with filter
            _buildAllBookingsTab(),
            // Tab 2: Auditorium Requests (only show "pending" requests)
            _buildAuditoriumRequestsTab(),
          ],
        ),
      ),
    );
  }

  // Tab 1: All Bookings with filter
  Widget _buildAllBookingsTab() {
    Query query = tpBookingsRef;

    // Apply status filter if needed
    if (_selectedStatusFilter != "All") {
      query = query.where("status", isEqualTo: _selectedStatusFilter);
    }

    // Ensure Firestore indexing rules are not broken
    if (_selectedStatusFilter == "All") {
      query = query.orderBy("date", descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No bookings found",
                style: TextStyle(color: AppColors.white)),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> booking = doc.data() as Map<String, dynamic>;
            String status = booking["status"] ?? "pending";
            Color statusColor = _getStatusColor(status);

            return Card(
              color: AppColors.darkdarkgrey,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text(
                  booking["venueName"] ?? "Unknown Venue",
                  style: const TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Date: ${booking["date"]}",
                        style: const TextStyle(color: AppColors.white)),
                    Text(
                        "Time: ${booking["startTime"]} - ${booking["endTime"]}",
                        style: const TextStyle(color: AppColors.white)),
                    Text("Booked By: ${booking["name"]} | ${booking["userId"]}",
                        style: TextStyle(color: AppColors.white)),
                    Text(
                      "Status: $status",
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
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

  // Tab 2: Auditorium Requests (only show "pending" requests)
  Widget _buildAuditoriumRequestsTab() {
    // Always filter by "pending" status for Auditorium Requests
    Query query = tpFormRef
        .where("venueType", isEqualTo: "Auditorium")
        .where("status", isEqualTo: "pending");

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              "Error loading requests: ${snapshot.error}",
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No pending auditorium requests found",
                style: TextStyle(color: AppColors.white)),
          );
        }

        return ListView(
          children: snapshot.data!.docs.map((doc) {
            Map<String, dynamic> request = doc.data() as Map<String, dynamic>;
            String status = request["status"] ?? "pending";
            Color statusColor = _getStatusColor(status);

            return Card(
              color: AppColors.darkdarkgrey,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: ListTile(
                title: Text(
                  request["venueName"] ?? "Unknown Venue",
                  style: const TextStyle(
                      color: AppColors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Event: ${request["eventname"] ?? "N/A"}",
                      style: const TextStyle(color: AppColors.white),
                    ),
                    Text(
                      "Date: ${request["date"] ?? "N/A"}",
                      style: const TextStyle(color: AppColors.white),
                    ),
                    Text(
                      "Time: ${request["startTime"] ?? "N/A"} - ${request["endTime"] ?? "N/A"}",
                      style: const TextStyle(color: AppColors.white),
                    ),
                    Text(
                      "Estimated People: ${request["estperson"] ?? "N/A"}",
                      style: const TextStyle(color: AppColors.white),
                    ),
                    Text(
                      "Booked By : ${request["name"] ?? "Unknown"} | ${request["userId"] ?? "N/A"}",
                      style: const TextStyle(color: AppColors.white),
                    ),
                    Text(
                      "Status: $status",
                      style: TextStyle(
                          color: statusColor, fontWeight: FontWeight.bold),
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

  // Approve a request (no changes needed here)
  Future<void> _approveRequest(String docId) async {
    try {
      // Step 1: Get the document from TPform
      DocumentSnapshot tpFormDoc = await tpFormRef.doc(docId).get();

      if (!tpFormDoc.exists) {
        print("Document does not exist in TPform");
        return;
      }

      // Step 2: Extract TPbookingId from TPform
      String tpBookingId = tpFormDoc["TPbookingId"];

      // Step 3: Update status in TPform
      await tpFormRef.doc(docId).update({"status": "scheduled"});

      // Step 4: Update status in TPbooking
      await tpBookingsRef.doc(tpBookingId).update({"status": "scheduled"});

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Request approved and status updated in both collections!"),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print("Error approving request: $e");

      if (!mounted) return;

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to approve request: $e"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // Reject a request with a reason (no changes needed here)
  Future<void> _rejectRequest(String docId) async {
    if (!mounted) return;

    final reasonController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkdarkgrey,
          title: const Text("Reject Request",
              style: TextStyle(color: AppColors.white)),
          content: TextField(
            controller: reasonController,
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: "Enter reason for rejection...",
              hintStyle: TextStyle(color: AppColors.darkdarkgrey),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context, rootNavigator: true).pop();
              },
              child: const Text("Cancel",
                  style: TextStyle(color: AppColors.white)),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.isNotEmpty) {
                  try {
                    // Step 1: Get the document from TPform
                    DocumentSnapshot tpFormDoc =
                        await tpFormRef.doc(docId).get();

                    if (!tpFormDoc.exists) {
                      print("Document does not exist in TPform");
                      return;
                    }

                    // Step 2: Extract TPbookingId from TPform
                    String tpBookingId = tpFormDoc["TPbookingId"];

                    // Step 3: Update status in TPform
                    await tpFormRef.doc(docId).update({
                      "status": "cancelled",
                      "rejectionReason": reasonController.text,
                    });

                    // Step 4: Update status in TPbooking
                    await tpBookingsRef.doc(tpBookingId).update({
                      "status": "cancelled",
                    });

                    // Step 5: Send a notification to the user
                    await _sendNotification(
                      userId: tpFormDoc["userId"],
                      venueName: tpFormDoc["venueName"],
                      date: tpFormDoc["date"],
                      startTime: tpFormDoc["startTime"],
                      endTime: tpFormDoc["endTime"],
                      reason: reasonController.text,
                    );

                    if (!mounted) return;

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text("Request rejected and notification sent!"),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.of(context, rootNavigator: true).pop();
                  } catch (e) {
                    print("Error rejecting request: $e");

                    if (!mounted) return;

                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Failed to reject request: $e"),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              },
              child: const Text("Reject", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendNotification({
    required String userId,
    required String venueName,
    required String date,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    try {
      // Step 1: Create a notification document in Firestore
      await firestore.collection("notifications").add({
        "userId": userId,
        "venueName": venueName,
        "date": date,
        "startTime": startTime,
        "endTime": endTime,
        "message":
            "Your booking for \"$venueName\" on $date from $startTime to $endTime has been cancelled. Reason: $reason",
        "nstatus": "unread", // Notification status
        "bookedtime": DateTime.now(), // Timestamp
        "bstatus": "cancelled", // Booking status
        "venueType": "Auditorium", // Example, adjust as needed
      });

      print("Notification sent successfully!");
    } catch (e) {
      print("Error sending notification: $e");
      rethrow;
    }
  }

  // Helper function to get status color (no changes needed here)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "scheduled":
        return Colors.green;
      case "pending":
        return Colors.yellow;
      case "cancelled":
        return Colors.red;
      case "history":
        return Colors.orange;
      case "completed":
        return Colors.orange;
      case "ongoing":
        return Colors.green;
      default:
        return Colors.white;
    }
  }
}
