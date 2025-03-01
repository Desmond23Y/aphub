import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditVenuePage extends StatefulWidget {
  final String venueId;
  final Map<String, dynamic> venueData;

  const EditVenuePage(
      {super.key, required this.venueId, required this.venueData});

  @override
  EditVenuePageState createState() => EditVenuePageState();
}

class EditVenuePageState extends State<EditVenuePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _locationController;
  late TextEditingController _capacityController;
  final List<String> _venueTypes = [
    'Classroom',
    'Meeting Room',
    'Auditorium',
    'Lab'
  ];
  final List<String> _blocks = ['A', 'B', 'C', 'D'];
  final List<String> _levels = ['1', '2', '3', '4', '5'];
  final List<String> _equipmentOptions = ['Mic', 'Speaker', 'Projector'];
  final List<String> _statusOptions = ['available', 'unavailable'];

  late String _selectedVenueType;
  late String _selectedBlock;
  late String _selectedLevel;
  late String _selectedStatus;
  Set<String> _selectedEquipment = {};

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _locationController =
        TextEditingController(text: widget.venueData['location'] ?? '');
    _capacityController = TextEditingController(
        text: widget.venueData['capacity']?.toString() ?? '');

    _selectedVenueType = widget.venueData['venuetype'] ?? 'Classroom';
    _selectedBlock = widget.venueData['block'] ?? 'A';
    _selectedLevel = widget.venueData['level']?.toString() ?? '1';
    _selectedStatus = widget.venueData['status'] ?? 'available';

    _selectedEquipment = Set<String>.from(widget.venueData['equipment'] ?? []);
  }

  @override
  void dispose() {
    _locationController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _updateVenue() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection("venues")
          .doc(widget.venueId)
          .set({
        "location": _locationController.text.trim(),
        "capacity": int.tryParse(_capacityController.text.trim()) ?? 0,
        "venuetype": _selectedVenueType,
        "block": _selectedBlock,
        "level": _selectedLevel,
        "equipment": _selectedEquipment.toList(),
        "status": _selectedStatus,
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Venue updated successfully!")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error updating venue: $e")),
        );
      }
    }

    setState(() => _isLoading = false);
  }

  Widget _buildEquipmentChips() {
    return Wrap(
      spacing: 8.0,
      children: _equipmentOptions.map((equipment) {
        final isSelected = _selectedEquipment.contains(equipment);
        return ChoiceChip(
          label: Text(equipment),
          selected: isSelected,
          onSelected: (selected) {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Venue")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: _selectedVenueType,
                decoration: const InputDecoration(labelText: "Venue Type"),
                items: _venueTypes
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedVenueType = value!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                    labelText: "Venue Location (e.g., A-07-01)"),
                validator: (value) =>
                    value!.trim().isEmpty ? "Enter venue location" : null,
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _selectedBlock,
                decoration: const InputDecoration(labelText: "Block"),
                items: _blocks
                    .map((block) =>
                        DropdownMenuItem(value: block, child: Text(block)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedBlock = value!),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _selectedLevel,
                decoration: const InputDecoration(labelText: "Level"),
                items: _levels
                    .map((level) =>
                        DropdownMenuItem(value: level, child: Text(level)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedLevel = value!),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Enter capacity";
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return "Enter a valid number > 0";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text("Select Equipment:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 5),
              _buildEquipmentChips(),
              const SizedBox(height: 10),
              DropdownButtonFormField(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: "Status"),
                items: _statusOptions
                    .map((status) =>
                        DropdownMenuItem(value: status, child: Text(status)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStatus = value!),
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _updateVenue,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade100,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text("Save Venue"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
