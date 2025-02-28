import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../login_page.dart';
import '../utils/app_colors.dart';
import 'package:aphub/screens/admin_venues_management.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  void _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return; // Check if context is still valid

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
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(color: AppColors.white),
        ),
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
              // Navigation Buttons
              _buildSection(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavButton(context, Icons.business, 'Venues',
                        const VenuesManagement()),
                    _buildNavButton(context, Icons.calendar_today, 'Timetables',
                        const Placeholder()),
                    _buildNavButton(
                        context, Icons.book, 'Bookings', const Placeholder()),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Search Bar
              _buildSection(
                child: Container(
                  decoration: _boxShadowDecoration(),
                  child: const TextField(
                    decoration: InputDecoration(
                      labelText: 'Search for Facility',
                      labelStyle: TextStyle(color: AppColors.lightgrey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(12),
                    ),
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Facility Utilization
              _buildSection(
                child: Column(
                  children: [
                    _buildSectionHeader('Facility Utilization', () {}),
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

              // Upcoming Bookings
              _buildSection(
                child: Column(
                  children: [
                    _buildSectionHeader('Upcoming Bookings', () {}),
                    _buildBookingItem(
                        'Meeting Room', '13:00 - 14:00', 'John Doe'),
                    _buildBookingItem(
                        'Cisco Lab', '15:00 - 16:00', 'Jane Smith'),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Buttons
              _buildSection(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildShadowedButton('Manage Bookings', () {}),
                    _buildShadowedButton('Add Venues', () {}),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required Widget child}) {
    return Container(
      decoration: _boxShadowDecoration(),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  BoxDecoration _boxShadowDecoration() {
    return BoxDecoration(
      color: AppColors.darkdarkgrey,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: AppColors.lightgrey.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildNavButton(
      BuildContext context, IconData icon, String label, Widget page) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: AppColors.white),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => page),
            );
          },
        ),
        Text(label, style: const TextStyle(color: AppColors.white)),
      ],
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback? onViewAll) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.white),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('View All',
                style: TextStyle(color: AppColors.lightgrey)),
          ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String change) {
    return Card(
      color: AppColors.darkdarkgrey,
      elevation: 8, // Elevation for slight depth
      shadowColor: AppColors.lightgrey, // Dark shadow effect
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

  Widget _buildShadowedButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkdarkgrey,
        foregroundColor: AppColors.white,
        shadowColor: AppColors.lightgrey,
        elevation: 6, // Add depth
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      child: Text(text),
    );
  }
}
