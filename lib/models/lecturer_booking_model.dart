import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String name;
  final String venueName;
  final String venueType;
  final String date;
  final String startTime;
  final String endTime;
  final String status; // "scheduled", "cancelled", "completed"
  final DateTime bookedTime;
  final String detail; // Purpose (module/event)

  Booking({
    required this.id,
    required this.userId,
    required this.name,
    required this.venueName,
    required this.venueType,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.bookedTime,
    required this.detail,
  });

  factory Booking.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Booking(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      venueName: data['venueName'] ?? '',
      venueType: data['venueType'] ?? '',
      date: data['date'] ?? '',
      startTime: data['startTime'] ?? '',
      endTime: data['endTime'] ?? '',
      status: data['status'] ?? 'scheduled',
      bookedTime: (data['bookedtime'] as Timestamp).toDate(),
      detail: data['detail'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'venueName': venueName,
        'venueType': venueType,
        'date': date,
        'startTime': startTime,
        'endTime': endTime,
        'status': status,
        'bookedtime': Timestamp.fromDate(bookedTime),
        'detail': detail,
      };
}