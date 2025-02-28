import 'package:aphub/screens/student_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/roles/students.dart';


class StudentHistoryPage extends StatelessWidget {
  const StudentHistoryPage({super.key});

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
          _buildCurrentBooking(),
          const SizedBox(height: 20), 
          _buildPastBooking(), 
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
                    builder: (context) => const StudentBookingPage(),
                  ),
                );
              }),
              _buildNavItem(
                'assets/icons/MAE_History_icon.png',
                'History',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You are already on the History page!')),
                  );
                },
              ),
              _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StudentPage(),
                  ),
                );
              }),
              _buildNavItem('assets/icons/MAE_logout_icon.png', 'Logout', () {}),
            ],
          ),
        ),
      ),
    );
  }

  
  Widget _buildCurrentBooking() {
    String selectedFacility = 'All';
    String selectedStatus = 'All';

    return StatefulBuilder(
      builder: (context, setState) {
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
                'Current Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),

              /// Filters Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Facility Type Filter
                  DropdownButton<String>(
                    dropdownColor: AppColors.darkgrey,
                    value: selectedFacility,
                    items: ['All', 'Gym', 'Library', 'Study Room']
                        .map((facility) => DropdownMenuItem(
                              value: facility,
                              child: Text(
                                facility,
                                style: const TextStyle(color: AppColors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFacility = value!;
                      });
                    },
                  ),

                  /// Booking Status Filter
                  DropdownButton<String>(
                    dropdownColor: AppColors.darkgrey,
                    value: selectedStatus,
                    items: ['All', 'Upcoming', 'Pending']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: const TextStyle(color: AppColors.white),
                              ),
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

              const SizedBox(height: 10),

              /// No Booking Available Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkgrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No bookings available',
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
      },
    );
  }


  Widget _buildPastBooking() {
    String selectedFacility = 'All';
    String selectedStatus = 'All';

    return StatefulBuilder(
      builder: (context, setState) {
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
                'Past Booking',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 10),

              /// Filters Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Facility Type Filter
                  DropdownButton<String>(
                    dropdownColor: AppColors.darkgrey,
                    value: selectedFacility,
                    items: ['All', 'Auditorium', 'Meeting Room', 'Class Room']
                        .map((facility) => DropdownMenuItem(
                              value: facility,
                              child: Text(
                                facility,
                                style: const TextStyle(color: AppColors.white),
                              ),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedFacility = value!;
                      });
                    },
                  ),

                  /// Booking Status Filter
                  DropdownButton<String>(
                    dropdownColor: AppColors.darkgrey,
                    value: selectedStatus,
                    items: ['All', 'Completed', 'Cancelled']
                        .map((status) => DropdownMenuItem(
                              value: status,
                              child: Text(
                                status,
                                style: const TextStyle(color: AppColors.white),
                              ),
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

              const SizedBox(height: 10),

              /// No Booking Record Message
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkgrey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'No Booking Record',
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
      },
    );
  }

  
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
