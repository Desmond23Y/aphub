import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aphub/screens/student_booking_page.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/roles/students.dart';
import 'package:aphub/screens/student_history_page.dart';

class StudentNotificationPage extends StatefulWidget {
  final String tpNumber;

  const StudentNotificationPage({super.key, required this.tpNumber});

  @override
  StudentNotificationPageState createState() => StudentNotificationPageState();
}

class StudentNotificationPageState extends State<StudentNotificationPage> {
  String selectedFacility = 'All';
  String selectedStatus = 'All';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/icons/MAE_APHUB_MENU_ICON.png'),
          width: 90,
        ),
        backgroundColor: AppColors.darkdarkgrey,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            onPressed: () {},
            icon: const Image(
              image: AssetImage('assets/icons/MAE_notification_icon.png'),
              width: 35,
            ),
          )
        ],
      ),
      backgroundColor: AppColors.black,
      body: Column(
        children: [
          const SizedBox(height: 20),
          _buildFilters(),
          Expanded(child: _buildNotificationList()),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

void _markNotificationAsRead(DocumentReference docRef) async {
  try {
    await docRef.update({'nstatus': 'read'});
    debugPrint("Notification marked as read");
  } catch (e) {
    debugPrint("Error updating notification: $e");
  }
}

Widget _buildNotificationList() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('notifications')
        .where('users', isEqualTo: widget.tpNumber) // Use 'isEqualTo' for single string
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        debugPrint("Error fetching notifications: ${snapshot.error}");
        return Center(
          child: Text(
            'Error: ${snapshot.error}',
            style: const TextStyle(color: AppColors.white),
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        debugPrint("No notifications found for TP: ${widget.tpNumber}");
        return const Center(
          child: Text(
            'No notifications available',
            style: TextStyle(color: AppColors.white),
          ),
        );
      }

      // Convert Firestore documents to a list of maps
      var notifications = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      debugPrint("Fetched ${notifications.length} notifications for TP: ${widget.tpNumber}");

      // Sort notifications: "new" notifications first, then "read" notifications
      notifications.sort((a, b) {
        String statusA = a['nstatus'] ?? 'read'; // Default to "read" if null
        String statusB = b['nstatus'] ?? 'read'; // Default to "read" if null

        if (statusA == 'new' && statusB != 'new') {
          return -1; // "new" comes before "read"
        } else if (statusA != 'new' && statusB == 'new') {
          return 1; // "read" comes after "new"
        } else {
          return 0; // No change in order
        }
      });

      return ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          var doc = snapshot.data!.docs[index]; // Get the document reference
          var data = notifications[index];
          String bookingId = data['bookingid'] ?? 'N/A';
          String bstatus = data['bstatus'] ?? 'Unknown';
          String nstatus = data['nstatus'] ?? 'Unknown';

          debugPrint("Notification: $bookingId | Status: $bstatus | Notification Status: $nstatus");

          // Apply Filters
          if ((selectedFacility != 'All' && selectedFacility != bstatus) ||
              (selectedStatus != 'All' && selectedStatus != nstatus)) {
            return const SizedBox.shrink(); // Hide if it doesn't match filters
          }

          // Set opacity based on notification status
          double opacity = nstatus == 'new' ? 0.8 : 0.4;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Move margin to Container
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4), // Match the Card's border radius
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkgrey.withOpacity(opacity), // Dynamic opacity
                  blurRadius: 6,
                  spreadRadius: 0.5,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Card(
              color: AppColors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4), // Match the Container's border radius
              ),
              child: ListTile(
                title: Text(
                  'Booking ID: $bookingId',
                  style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Status: $bstatus | Notification: $nstatus',
                  style: const TextStyle(color: AppColors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.white, size: 18),
                onTap: () {
                  // Mark notification as "read" when tapped
                  _markNotificationAsRead(doc.reference);
                  _showNotificationDetails(data);
                },
              ),
            ),
          );
        },
      );
    },
  );
}

  /// 🔹 Show Notification Details in Dialog
  void _showNotificationDetails(Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.darkgrey,
          title: const Text('Notification Details', style: TextStyle(color: AppColors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Booking ID:', data['bookingid']),
              _detailRow('Status:', data['bstatus']),
              _detailRow('Message:', data['message']),
              _detailRow('Notification:', data['nstatus']),
              _detailRow('Venue:', data['venue']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: AppColors.white)),
            ),
          ],
        );
      },
    );
  }

  /// 🔹 Helper to Build a Row for Dialog Details
  Widget _detailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label ', style: const TextStyle(color: AppColors.white, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value ?? 'N/A', style: const TextStyle(color: AppColors.white))),
        ],
      ),
    );
  }

  /// 🔹 Filters for Notification List
  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DropdownButton<String>(
            dropdownColor: AppColors.darkgrey,
            value: selectedFacility,
            items: ['All', 'Completed', 'Pending', 'Cancelled', 'Scheduled']
                .map((facility) => DropdownMenuItem(
                      value: facility,
                      child: Text(facility, style: const TextStyle(color: AppColors.white)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedFacility = value!;
              });
            },
          ),
          DropdownButton<String>(
            dropdownColor: AppColors.darkgrey,
            value: selectedStatus,
            items: ['All', 'read', 'new']
                .map((status) => DropdownMenuItem(
                      value: status,
                      child: Text(status, style: const TextStyle(color: AppColors.white)),
                    ))
                .toList(),
            onChanged: (value) {
              setState(() {
                selectedStatus = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  /// 🔹 Bottom Navigation Bar
  Widget _buildBottomNavBar() {
    return BottomAppBar(
      color: AppColors.darkdarkgrey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('assets/icons/MAE_Calender_icon.png', 'Booking', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentBookingPage(tpNumber: widget.tpNumber)),
              );
            }),
            _buildNavItem('assets/icons/MAE_History_icon.png', 'History', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentHistoryPage(tpNumber: widget.tpNumber)),
              );
            }),
            _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => StudentPage(tpNumber: widget.tpNumber)),
              );
            }),
            _buildNavItem('assets/icons/MAE_logout_icon.png', 'Logout', () {}),
          ],
        ),
      ),
    );
  }

  /// 🔹 Helper for Bottom Navigation
  Widget _buildNavItem(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.white)),
        ],
      ),
    );
  }
}
