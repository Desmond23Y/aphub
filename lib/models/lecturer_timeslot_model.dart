import 'package:cloud_firestore/cloud_firestore.dart';

class Timeslot {
  final String id;
  final String venueName;
  final String venueType;
  final String date;
  final String startTime;
  final String endTime;
  final int capacity;
  final List<String> equipment;
  final String status; // "available", "scheduled", "booked"

  Timeslot({
    required this.id,
    required this.venueName,
    required this.venueType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.capacity,
    required this.equipment,
    required this.status,
  });

  factory Timeslot.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Timeslot(
      id: doc.id,
      venueName: data['venueName'] ?? '',
      venueType: data['venueType'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      capacity: data['capacity'] ?? 0,
      equipment: List<String>.from(data['equipment'] ?? []),
      status: data['status'] ?? 'available',
    );
  }

  Map<String, dynamic> toJson() => {
        'venueName': venueName,
        'venueType': venueType,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'capacity': capacity,
        'equipment': equipment,
        'status': status,
      };
}