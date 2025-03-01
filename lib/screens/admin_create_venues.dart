import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateVenuePage extends StatefulWidget {
  const CreateVenuePage({super.key});

  @override
  CreateVenuePageState createState() => CreateVenuePageState();
}

class CreateVenuePageState extends State<CreateVenuePage> {
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final List<String> _selectedEquipment = [];

  final List<String> _availableEquipment = ['Mic', 'Speaker', 'Projector'];
  final List<String> _venueTypes = [
    'classroom',
    'meetingroom',
    'auditorium',
    'lab'
  ];
  final List<String> _statusOptions = ['available', 'unavailable'];

  String _selectedVenueType = 'classroom';
  String _selectedStatus = 'available';

  Future<void> _saveVenue() async {
    if (!mounted) return;

    String location = _locationController.text.trim();
    String capacityText = _capacityController.text.trim();

    if (location.isEmpty || capacityText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    int? capacity = int.tryParse(capacityText);
    if (capacity == null || capacity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enter a valid capacity")),
      );
      return;
    }

    CollectionReference venues =
        FirebaseFirestore.instance.collection('venues');

    try {
      DocumentSnapshot venueDoc = await venues.doc(location).get();

      if (venueDoc.exists) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Venue already exists!")),
        );
        return;
      }

      await venues.doc(location).set({
        "name": location,
        "capacity": capacity,
        "equipment": _selectedEquipment,
        "venuetype": _selectedVenueType,
        "status": _selectedStatus,
      });

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving venue: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Venue')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                  labelText: "Venue Location (e.g., A-07-01)"),
            ),
            TextField(
              controller: _capacityController,
              decoration: const InputDecoration(labelText: "Capacity"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            const Text("Select Equipment:"),
            Wrap(
              spacing: 10,
              children: _availableEquipment.map((equipment) {
                return FilterChip(
                  label: Text(equipment),
                  selected: _selectedEquipment.contains(equipment),
                  onSelected: (bool selected) {
                    setState(() {
                      if (selected) {
                        _selectedEquipment.add(equipment);
                      } else {
                        _selectedEquipment.remove(equipment);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedVenueType,
              decoration: const InputDecoration(labelText: "Venue Type"),
              items: _venueTypes.map((type) {
                return DropdownMenuItem(value: type, child: Text(type));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVenueType = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(labelText: "Status"),
              items: _statusOptions.map((status) {
                return DropdownMenuItem(value: status, child: Text(status));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedStatus = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVenue,
              child: const Text("Save Venue"),
            ),
          ],
        ),
      ),
    );
  }
}
