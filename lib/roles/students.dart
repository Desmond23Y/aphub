import 'dart:async';

import 'package:aphub/screens/student_notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aphub/screens/student_history_page.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/screens/student_booking_page.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:aphub/login_page.dart'; 


class StudentPage extends StatefulWidget {
  final String tpNumber;
  const StudentPage({super.key, required this.tpNumber});
  

  @override
  StudentPageState createState() => StudentPageState();
}

class StudentPageState extends State<StudentPage> {
  late String name;
  late String tpNumber;


  @override
  void initState() {
    super.initState();
    tpNumber = widget.tpNumber; // Store the TP Number
    name = "Loading...";
    _fetchUserData();
    _checkAndUpdateBookingStatus();
  }

  Future<void> _fetchUserData() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(tpNumber) // Ensure this matches your Firestore document ID
          .get();

      if (userDoc.exists) {
        String fetchedName = userDoc['name'] ?? "Unknown";

        if (mounted) {
          setState(() {
            name = fetchedName;
          });
        }
      } else {
        debugPrint("User document does not exist.");
      }
    } catch (e) {
      debugPrint("Error fetching user data: $e");
    }
  }

    Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user

      // Navigate to the login page and remove all previous routes
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      debugPrint("Error during logout: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
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
            padding: const EdgeInsets.only(right: 15),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentNotificationPage(tpNumber: tpNumber),
                ),
              );
            },
            icon: const Image(
              image: AssetImage('assets/icons/MAE_notification_icon.png'),
              width: 35,
            ),
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
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkgrey.withOpacity(0.5),
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        AppColors.white,
                        AppColors.lightgrey,
                        AppColors.darkgrey,
                        AppColors.black,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black,
                    ),
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          AssetImage('assets/icons/MAE_DESMOND_ICON.jpg'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  name, // Display fetched name
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                Text(
                  tpNumber, // Display fetched TP number
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightgrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const TabBar(
                    tabs: [
                      Tab(text: 'TODAY'),
                      Tab(text: 'UPCOMING'),
                    ],
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildScheduleTab(isToday: true),
                        _buildScheduleTab(isToday: false),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkdarkgrey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('assets/icons/MAE_Calender_icon.png', 'Booking', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentBookingPage(tpNumber: tpNumber),
                  ),
                );
              }),
              _buildNavItem(
                'assets/icons/MAE_History_icon.png',
                'History',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StudentHistoryPage(tpNumber: tpNumber),
                    ),
                  );
                },
              ),
              _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('You are already on the Home page!')),
                );
              }),
              _buildNavItem('assets/icons/MAE_logout_icon.png', 'Logout', () {_logout();}),
            ],
          ),
        ),
      ),
    );
  }



  Widget _buildScheduleTab({required bool isToday}) {
    final today = DateTime.now().toLocal();
    final todayFormatted =
        "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

      return StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('TPbooking')
            .where('userId', isEqualTo: tpNumber)
            .where('status', whereIn: ['scheduled', 'ongoing', 'pending'])
            .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text(
              'No ${isToday ? 'today\'s' : 'upcoming'} bookings available.',
              style: const TextStyle(color: AppColors.white),
            ),
          );
        }

        final bookings = snapshot.data!.docs;
        final filteredBookings = bookings.where((booking) {
          final date = booking['date'] ?? 'Unknown';
          return isToday ? date == todayFormatted : date != todayFormatted;
        }).toList();

        if (filteredBookings.isEmpty) {
          return Center(
            child: Text(
              'No ${isToday ? 'today\'s' : 'upcoming'} bookings available.',
              style: const TextStyle(color: AppColors.white),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredBookings.length,
          itemBuilder: (context, index) {
            final booking = filteredBookings[index];
            final status = booking['status'] ?? 'unknown';
            final startTime = booking['startTime'] ?? 'N/A';
            final endTime = booking['endTime'] ?? 'N/A';
            final timeRange = '$startTime - $endTime';
            final venueName = booking['venueName'] ?? 'Unknown';
            final venueType = booking['venueType'] ?? 'Unknown';
            final date = booking['date'] ?? 'Unknown';

            // Determine status color
            Color statusColor;
            switch (status.toLowerCase()) {
              case 'scheduled':
                statusColor = Colors.orange;
                break;
              case 'ongoing':
                statusColor = Colors.green;
                break;
              case 'pending':
                statusColor = Colors.yellow;
                break;
              default:
                statusColor = AppColors.white;
            }

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.darkgrey.withOpacity(0.5),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date: $date',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        timeRange,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Venue: $venueName',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Type: $venueType',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: statusColor,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _checkAndUpdateBookingStatus() {
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final bookings = await FirebaseFirestore.instance
        .collection('TPbooking')
        .where('userId', isEqualTo: widget.tpNumber)
        .get();

    for (final booking in bookings.docs) {
      final startTime = booking['startTime'];
      final endTime = booking['endTime'];
      final date = booking['date'];
      final status = booking['status'];
      final venueName = booking['venueName'];
      final venueType = booking['venueType'];

      final bookingDateTime = DateTime.parse('$date $startTime');
      final endDateTime = DateTime.parse('$date $endTime');

      if (status == 'scheduled' && now.isAfter(bookingDateTime)) {
        if (now.isBefore(endDateTime)) {
          // Update status to "ongoing" if the current time is between startTime and endTime
          await FirebaseFirestore.instance
              .collection('TPbooking')
              .doc(booking.id)
              .update({'status': 'ongoing'});

          // Send notification for "ongoing" status
          await FirebaseFirestore.instance.collection('notifications').add({
            'date': date,
            'bstatus': 'ongoing',
            'venueName': venueName,
            'venueType': venueType,
            'userId': widget.tpNumber,
            'bookedtime': DateTime.now(),
            'message':
                'Your booking for "$venueName" on $date from $startTime is currently ongoing.',
            'nstatus': 'new',
            'startTime': startTime,
            'endTime': endTime,
          });
        } else {
          // Update status to "completed" if the current time is after endTime
          await FirebaseFirestore.instance
              .collection('TPbooking')
              .doc(booking.id)
              .update({'status': 'completed'});

          // Send notification for "completed" status
          await FirebaseFirestore.instance.collection('notifications').add({
            'date': date,
            'bstatus': 'completed',
            'venueName': venueName,
            'venueType': venueType,
            'userId': widget.tpNumber,
            'bookedtime': DateTime.now(),
            'message':
                'Your booking for "$venueName" on $date from $startTime to $endTime is currently completed.',
            'nstatus': 'new',
            'startTime': startTime,
            'endTime': endTime,
          });
        }
      } else if (status == 'ongoing' && now.isAfter(endDateTime)) {
        // Update status to "completed" if the current time is after endTime
        await FirebaseFirestore.instance
            .collection('TPbooking')
            .doc(booking.id)
            .update({'status': 'completed'});

        // Send notification for "completed" status
        await FirebaseFirestore.instance.collection('notifications').add({
          'date': date,
          'bstatus': 'completed',
          'venueName': venueName,
          'venueType': venueType,
          'userId': widget.tpNumber,
          'bookedtime': DateTime.now(),
          'message':
              'Your booking for "$venueName" on $date from $startTime to $endTime is currently completed.',
          'nstatus': 'new',
          'startTime': startTime,
          'endTime': endTime,
        });
      }
    }
  });
}

  Widget _buildNavItem(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 30, height: 30),
          const SizedBox(height: 4),
          Text(label,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}