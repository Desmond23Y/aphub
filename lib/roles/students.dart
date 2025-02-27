// Students Functionalities
import 'package:flutter/material.dart';
import 'package:aphub/utils/app_colors.dart'; 

class StudentPage extends StatelessWidget {
  const StudentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black, 
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/icons/MAE_APHUB_MENU_ICON.png'),
          width: 110,
        ),  
        backgroundColor: AppColors.darkdarkgrey,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            onPressed: () {
              // TODO Function
            },
            icon: const Image(
              image: AssetImage('assets/icons/MAE_notification_icon.png'),
              width: 35,
            ),
          )
        ]
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centers horizontally
        children: [
          const SizedBox(height: 20), // Adjust space between AppBar & Container
          Container(
            width: double.infinity, 
            padding: const EdgeInsets.symmetric(vertical: 20), 
            margin: const EdgeInsets.symmetric(horizontal: 20), 
            decoration: BoxDecoration(
              color: AppColors.darkdarkgrey,
              borderRadius: BorderRadius.circular(10), // Rounded corners
              boxShadow: [
                BoxShadow(
                  color: AppColors.darkGray.withOpacity(0.5), // Slightly transparent
                  blurRadius: 10,
                  spreadRadius: 2,
                  offset: const Offset(0, 4), // Shadow position
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
                        AppColors.lightGray,
                        AppColors.darkGray,
                        AppColors.black,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4), // Space between ring and image
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.black,
                    ),
                    child: const CircleAvatar(
                      radius: 50, // Adjust as needed
                      backgroundImage: AssetImage('assets/icons/MAE_DESMOND_ICON.png'),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Name Text
                const Text(
                  'Desmond',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),

                // TPNO Text
                const Text(
                  'TP123456', // Replace with actual TPNO
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.lightGray, // Slightly dimmer than name
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20), // Adjust space between Container & Upcoming Booking
          _buildUpcomingBooking(), // Upcoming Booking Widget
        ],
      ),
    bottomNavigationBar: BottomAppBar(
      color: AppColors.darkdarkgrey,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem('assets/icons/MAE_Calender_icon.png', 'Booking', () {}),
            _buildNavItem('assets/icons/MAE_History_icon.png', 'History', () {}),
            _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {}),
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
              color: AppColors.darkGray.withOpacity(0.2),
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
          Image.asset(iconPath, width: 30, height: 30), // Icon Image
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ],
      ),
    );
  }
}
