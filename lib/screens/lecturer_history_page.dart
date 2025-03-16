import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aphub/utils/app_colors.dart';

class LecturerHistoryPage extends StatefulWidget {
  final String tpNumber;
  const LecturerHistoryPage({super.key, required this.tpNumber});

  @override
  LecturerHistoryPageState createState() => LecturerHistoryPageState();
}

class LecturerHistoryPageState extends State<LecturerHistoryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Booking History",
          style: TextStyle(color: Colors.white), // Ensuring visibility
        ),
        iconTheme: const IconThemeData(
            color: Colors.white), // Making back button visible
        backgroundColor: AppColors.darkdarkgrey,
      ),
      backgroundColor: AppColors.black,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('TPbooking')
            .where('userId', isEqualTo: widget.tpNumber)
            .where('status', isEqualTo: 'history')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "No past bookings found.",
                style: TextStyle(color: AppColors.white),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              return Card(
                color: AppColors.darkgrey,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(
                    "Venue: ${booking['venueName']}",
                    style: const TextStyle(color: AppColors.white),
                  ),
                  subtitle: Text(
                    "Date: ${booking['date']}\nTime: ${booking['startTime']} - ${booking['endTime']}",
                    style: const TextStyle(
                        color: Colors.white70), // Improved contrast
                  ),
                  leading: const Icon(Icons.history, color: Colors.white),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
