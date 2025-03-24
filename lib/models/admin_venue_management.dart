import 'package:flutter/material.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/screens/admin_update_venues.dart';

Widget buildVenueCard({
  required BuildContext context,
  required String venueId,
  required Map<String, dynamic> venueData,
  required VoidCallback onDelete,
}) {
  return Card(
    color: AppColors.darkdarkgrey, // Dark card background
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
    child: ListTile(
      title: Text(
        venueData['name'] ?? 'Unnamed Venue',
        style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Capacity: ${venueData['capacity']}",
              style: const TextStyle(color: AppColors.lightgrey)),
          Text(
            "Equipment: ${(venueData['equipment'] as List<dynamic>?)?.join(', ') ?? 'No Equipment'}",
            style: const TextStyle(color: AppColors.lightgrey),
          ),
          Text("Venue Type: ${venueData['venuetype'] ?? 'N/A'}",
              style: const TextStyle(color: AppColors.lightgrey)),
          Text(
            "Status: ${venueData['status'] ?? 'N/A'}",
            style: TextStyle(
              color: venueData['status'] == 'available'
                  ? Colors.green
                  : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      EditVenuePage(venueId: venueId, venueData: venueData),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    ),
  );
}
