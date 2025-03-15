import 'package:flutter/material.dart';

class LecturerFaqPage extends StatelessWidget {
  final String tpNumber;
  const LecturerFaqPage({super.key, required this.tpNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme background
      appBar: AppBar(
        title: const Text('FAQs'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white, // Ensures text is white
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildCategoryTile("Booking", [
            _buildFaqTile("How do I book a venue?",
                "Go to the 'Bookings' page, and press the 'Book' button."),
            _buildFaqTile("Can I see my current bookings?",
                "Current bookings are displayed at the 'My Bookings' section in the dashboard."),
          ]),
          _buildCategoryTile("Cancellations", [
            _buildFaqTile("Can I cancel a booking?",
                "Yes, before the session starts. Ongoing bookings cannot be canceled."),
            _buildFaqTile(
                "Will I be penalized for cancellations?", "Currently, No."),
          ]),
          _buildCategoryTile("Viewing & History", [
            _buildFaqTile("Where can I see my past bookings?",
                "Go to the 'History' page to view past and canceled bookings."),
          ]),
          _buildCategoryTile("Support", [
            _buildFaqTile("Who do I contact for urgent issues?",
                "Reach out to support at admin@apu.com."),
          ]),
        ],
      ),
    );
  }

  Widget _buildCategoryTile(String category, List<Widget> faqs) {
    return Card(
      color: Colors.grey[850], // Slightly lighter than background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        iconColor: Colors.pink,
        collapsedIconColor: Colors.white,
        title: Text(category,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        children: faqs,
      ),
    );
  }

  Widget _buildFaqTile(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpansionTile(
        iconColor: Colors.pink,
        collapsedIconColor: Colors.white,
        title: Text(question,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
            child: Text(answer, style: const TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
