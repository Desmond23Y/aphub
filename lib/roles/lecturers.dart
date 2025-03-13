import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/screens/lecturer_booking_page.dart';
import 'package:aphub/screens/lecturer_request_page.dart';
import 'package:aphub/screens/lecturer_history_page.dart';
import 'package:aphub/screens/lecturer_notification_page.dart';

class LecturerPage extends StatefulWidget {
  final String tpNumber;
  const LecturerPage({super.key, required this.tpNumber});

  @override
  LecturerPageState createState() => LecturerPageState();
}

class LecturerPageState extends State<LecturerPage> {
  late String name;
  late String tpNumber;

  @override
  void initState() {
    super.initState();
    tpNumber = widget.tpNumber;
    name = "Loading...";
    _updateBookingStates();
    _fetchLecturerData();
  }

  Future<void> _fetchLecturerData() async {
    try {
      DocumentSnapshot lecturerDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tpNumber)
          .get();

      if (lecturerDoc.exists) {
        String fetchedName = lecturerDoc['name'] ?? "Unknown";
        
        if (mounted) {
          setState(() {
            name = fetchedName;
          });
        }
      } else {
        debugPrint("Lecturer document does not exist.");
      }
    } catch (e) {
      debugPrint("Error fetching lecturer data: $e");
    }
  }

  Future<void> _updateBookingStates() async {
    QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
        .collection('bookings')
        .where('state', isEqualTo: 'upcoming') // Get only upcoming bookings
        .get();

    for (var doc in bookingsSnapshot.docs) {
      Map<String, dynamic> bookingData = doc.data() as Map<String, dynamic>;
      
      // Check if 'endTime' exists and is a Timestamp
      if (bookingData.containsKey('endTime') && bookingData['endTime'] is Timestamp) {
        Timestamp endTimeStamp = bookingData['endTime'];
        DateTime endTime = endTimeStamp.toDate(); // Convert to DateTime

        if (DateTime.now().isAfter(endTime)) {
          // Booking has passed, update state to history
          await FirebaseFirestore.instance.collection('bookings').doc(doc.id).update({
            'state': 'history',
          });
        }
      } else {
        debugPrint("Invalid or missing 'endTime' field in booking: ${doc.id}");
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/icons/MAE_APHUB_MENU_ICON.png'),
          width: 90,
        ),
        backgroundColor: AppColors.darkdarkgrey,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: AppColors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LecturerNotificationPage(tpNumber: tpNumber),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppColors.darkdarkgrey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/icons/lecturer_icon.png'),
                ),
                const SizedBox(height: 16),
                Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.white)),
                Text(tpNumber, style: const TextStyle(fontSize: 16, color: AppColors.lightgrey)),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildUpcomingBooking(),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkdarkgrey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.calendar_today, 'Bookings', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LecturerBookingPage(tpNumber: tpNumber),
                  ),
                );
              }),
              _buildNavItem(Icons.history, 'History', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LecturerHistoryPage(tpNumber: tpNumber)),
                );
              }),
              _buildNavItem(Icons.help, 'Request', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LecturerRequestPage(tpNumber: tpNumber)),
                );
              }),
              _buildNavItem(Icons.logout, 'Logout', () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUpcomingBooking() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.darkdarkgrey,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Booking',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkgrey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'No upcoming bookings available.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 30),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}