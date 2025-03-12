import 'dart:nativewrappers/_internal/vm/lib/internal_patch.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

Future<void> generateWeeklyTimeSlots() async {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference venuesRef = firestore.collection("venues");
  CollectionReference timeslotsRef = firestore.collection("timeslots");

  QuerySnapshot venuesSnapshot = await venuesRef.get();
  WriteBatch batch = firestore.batch();

  for (var venueDoc in venuesSnapshot.docs) {
    Map<String, dynamic>? venueData = venueDoc.data() as Map<String, dynamic>?;

    if (venueData == null) continue; // Skip if data is null

    String venueId = venueDoc.id;
    String venueName = venueData["name"] ?? "Unknown Venue";
    String venueType =
        venueData["venuetype"] ?? "Unknown Type"; // Fixed field name
    String block = venueData["block"] ?? "Unknown Block";
    String level = venueData["level"] ?? "Unknown Level";
    int capacity = venueData["capacity"] ?? 0; // Fetch capacity
    List<dynamic> equipment =
        venueData["equipment"] ?? []; // Fetch equipment list

    DateTime now = DateTime.now();
    DateTime startOfWeek =
        now.subtract(Duration(days: now.weekday - 1)); // Start from Monday

    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      DateTime currentDay = startOfWeek.add(Duration(days: dayOffset));
      DateTime startTime =
          DateTime(currentDay.year, currentDay.month, currentDay.day, 8, 0);
      DateTime endTime =
          DateTime(currentDay.year, currentDay.month, currentDay.day, 18, 0);

      while (startTime.isBefore(endTime)) {
        String formattedDate = DateFormat("yyyy-MM-dd").format(startTime);
        String formattedStartTime = DateFormat("HH:mm").format(startTime);
        DateTime slotEndTime = startTime.add(const Duration(minutes: 30));
        String formattedEndTime = DateFormat("HH:mm").format(slotEndTime);

        String timeslotId = "$venueId-$formattedDate-$formattedStartTime";

        DocumentSnapshot existingSlot =
            await timeslotsRef.doc(timeslotId).get();

        if (!existingSlot.exists) {
          batch.set(timeslotsRef.doc(timeslotId), {
            "block": block,
            "date": formattedDate,
            "endTime": formattedEndTime,
            "level": level,
            "startTime": formattedStartTime,
            "status": "available",
            "venueId": venueId,
            "venueName": venueName,
            "venueType": venueType,
            "capacity": capacity, // Include capacity
            "equipment": equipment, // Include equipment
          });
        }

        startTime = slotEndTime;
      }
    }
  }

  await batch.commit();
  print("Time slots generated for one week!");
}
