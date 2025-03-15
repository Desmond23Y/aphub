import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LecturerNotificationPage extends StatelessWidget {
  final String tpNumber;
  const LecturerNotificationPage({super.key, required this.tpNumber});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark theme
      appBar: AppBar(
        title: const Text('Lecturer Notifications'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () => _markAllAsRead(),
            child: const Text("Mark All as Read",
                style: TextStyle(color: Colors.pink)),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("notifications")
            .where("userId", isEqualTo: tpNumber)
            .orderBy("bookedtime", descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.pink));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text("No notifications",
                  style: TextStyle(color: Colors.white70)),
            );
          }

          var notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              var notif = notifications[index].data() as Map<String, dynamic>;

              return Card(
                color: Colors.grey[850], // Dark mode card
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                margin: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(
                    notif["message"] ?? "No message",
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    "${notif["date"]} | ${notif["startTime"]} - ${notif["endTime"]}",
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: notif["nstatus"] == "new"
                      ? const Icon(Icons.notifications_active,
                          color: Colors.pink)
                      : null,
                  onTap: () {
                    // Mark individual notification as read
                    FirebaseFirestore.instance
                        .collection("notifications")
                        .doc(notifications[index].id)
                        .update({"nstatus": "read"});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _markAllAsRead() async {
    var notifications = await FirebaseFirestore.instance
        .collection("notifications")
        .where("userId", isEqualTo: tpNumber)
        .where("nstatus", isEqualTo: "new")
        .get();

    for (var doc in notifications.docs) {
      await doc.reference.update({"nstatus": "read"});
    }
  }
}
