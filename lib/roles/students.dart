import 'package:aphub/screens/student_notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:aphub/screens/student_history_page.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/screens/student_booking_page.dart';


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
                  builder: (context) => StudentNotificationPage(tpNumber: tpNumber),
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
                      builder: (context) => StudentHistoryPage(tpNumber: tpNumber), 
                    ),
                  );
                },
              ),
              _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are already on the Home page!')),
                  );
                },
              ),
              _buildNavItem('assets/icons/MAE_logout_icon.png', 'Logout', () {}),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.darkdarkgrey.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Upcoming Booking',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
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
