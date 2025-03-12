import 'package:aphub/screens/admin_account_management.dart';
import 'package:aphub/screens/admin_module_management.dart';
import 'package:aphub/screens/admin_timetable_management.dart';
import 'package:aphub/screens/admin_venues_management.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../utils/app_colors.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

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
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: AppColors.darkdarkgrey,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Upcoming Bookings'),
                    _buildBookingItem(
                        'Meeting Room', '13:00 - 14:00', 'John Doe'),
                    _buildBookingItem(
                        'Cisco Lab', '15:00 - 16:00', 'Jane Smith'),
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
              _buildNavButton(
                  context, Icons.book, 'Bookings', const Placeholder()),
              _buildNavButton(context, Icons.account_circle, 'Account',
                  const AccountManagement()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Expanded(
      child: GestureDetector(
        // Use GestureDetector instead of IconButton for better flexibility
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => page));
        },
        child: SizedBox(
          height: 60, // Ensure a fixed height
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.white),
    );
  }

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
}
