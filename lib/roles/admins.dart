import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async'; // For Timer
import '../login_page.dart';
import '../utils/app_colors.dart';
import '../screens/admin_account_management.dart';
import '../screens/admin_booking_management.dart';
import '../screens/admin_module_management.dart';
import '../screens/admin_timetable_management.dart';
import '../screens/admin_venues_management.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final PageController _pageController = PageController();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Start auto-swiping after 3 seconds
    _startAutoSwiping();
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    _pageController.dispose(); // Dispose the PageController
    super.dispose();
  }

  void _startAutoSwiping() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_pageController.page == 2) {
        // If on the last page, go back to the first page
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      } else {
        // Go to the next page
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.darkdarkgrey,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: AppColors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppColors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Auto-Swiping Section
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.darkdarkgrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Overview'),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200, // Set a fixed height for the PageView
                      child: PageView(
                        controller: _pageController,
                        children: [
                          _buildUpcomingBookings(),
                          _buildVenues(),
                          _buildModules(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Other sections (e.g., Venues Utilization)
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.darkdarkgrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Venues Utilization'),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatCard('Booked Slots', '45', '+5%'),
                        _buildStatCard('Available Slots', '20', '-10%'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkdarkgrey,
        shape: const CircularNotchedRectangle(),
        child: SizedBox(
          height: 60, // Increase height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavButton(
                  context, Icons.business, 'Venues', const VenuesManagement()),
              _buildNavButton(context, Icons.meeting_room, 'Modules',
                  const ModuleManagement()),
              _buildNavButton(context, Icons.calendar_today, 'Timetables',
                  const TimeSlotManagement()),
              _buildNavButton(context, Icons.book, 'Bookings',
                  const AdminBookingManagement()),
              _buildNavButton(context, Icons.account_circle, 'Account',
                  const AccountManagement()),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Upcoming Bookings Section
  Widget _buildUpcomingBookings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Upcoming Bookings',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white)),
        const SizedBox(height: 10),
        _buildBookingItem('Meeting Room', '13:00 - 14:00', 'John Doe'),
        _buildBookingItem('Cisco Lab', '15:00 - 16:00', 'Jane Smith'),
      ],
    );
  }

  // Widget for Venues Section
  Widget _buildVenues() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Venues',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white)),
        const SizedBox(height: 10),
        _buildVenueItem('Auditorium 1', 'Capacity: 250'),
        _buildVenueItem('Cisco Lab', 'Capacity: 50'),
      ],
    );
  }

  // Widget for Modules Section
  Widget _buildModules() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Modules',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.white)),
        const SizedBox(height: 10),
        _buildModuleItem('Module 1', 'Instructor: John Doe'),
        _buildModuleItem('Module 2', 'Instructor: Jane Smith'),
      ],
    );
  }

  // Widget for Venue Item
  Widget _buildVenueItem(String name, String details) {
    return ListTile(
      leading: const Icon(Icons.business, color: AppColors.lightgrey),
      title: Text(name, style: const TextStyle(color: AppColors.white)),
      subtitle:
          Text(details, style: const TextStyle(color: AppColors.lightgrey)),
    );
  }

  // Widget for Module Item
  Widget _buildModuleItem(String name, String details) {
    return ListTile(
      leading: const Icon(Icons.meeting_room, color: AppColors.lightgrey),
      title: Text(name, style: const TextStyle(color: AppColors.white)),
      subtitle:
          Text(details, style: const TextStyle(color: AppColors.lightgrey)),
    );
  }

  // Widget for Booking Item
  Widget _buildBookingItem(String venue, String time, String user) {
    return ListTile(
      leading: const Icon(Icons.event, color: AppColors.lightgrey),
      title: Text(venue, style: const TextStyle(color: AppColors.white)),
      subtitle: Text(time, style: const TextStyle(color: AppColors.lightgrey)),
      trailing: Text(user,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: AppColors.white)),
    );
  }

  // Widget for Navigation Button
  Widget _buildNavButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        child: SizedBox(
          height: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.white, size: 24),
              const SizedBox(height: 4),
              Text(label,
                  style: const TextStyle(color: AppColors.white, fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  // Widget for Section Header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
    );
  }

  // Widget for Stat Card
  Widget _buildStatCard(String title, String value, String change) {
    return Card(
      color: AppColors.darkdarkgrey,
      elevation: 8,
      shadowColor: AppColors.lightgrey,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.white)),
            Text(value,
                style: const TextStyle(fontSize: 24, color: AppColors.white)),
            Text(change, style: const TextStyle(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
