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

  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _equipmentController;

  final List<String> _venueTypes = [
    'classroom',
    'meetingroom',
    'auditorium',
    'lab'
  ];
  final List<String> _statusOptions = ['available', 'unavailable'];

  late String _selectedVenueType;
  late String _selectedStatus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.venueData['name']);
    _capacityController =
        TextEditingController(text: widget.venueData['capacity'].toString());
    _equipmentController = TextEditingController(
      text: (widget.venueData['equipment'] as List<dynamic>?)?.join(', ') ?? '',
    );
    _selectedVenueType = widget.venueData['venuetype'] ?? 'classroom';
    _selectedStatus = widget.venueData['status'] ?? 'available';
  }

  void _updateVenue() async {
    if (_formKey.currentState!.validate()) {
      String newVenueName = _nameController.text.trim();
      int newCapacity = int.tryParse(_capacityController.text) ?? 0;
      List<String> newEquipment =
          _equipmentController.text.split(',').map((e) => e.trim()).toList();

      await FirebaseFirestore.instance
          .collection("venues")
          .doc(widget.venueId)
          .update({
        "name": newVenueName,
        "capacity": newCapacity,
        "equipment": newEquipment,
        "venuetype": _selectedVenueType,
        "status": _selectedStatus,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Venue updated successfully!"),
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Venue")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Venue Name"),
                validator: (value) =>
                    value!.isEmpty ? "Enter venue name" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _capacityController,
                decoration: const InputDecoration(labelText: "Capacity"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter capacity" : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _equipmentController,
                decoration: const InputDecoration(
                    labelText: "Equipment (comma-separated)"),
                validator: (value) =>
                    value!.isEmpty ? "Enter equipment details" : null,
              ),
              const SizedBox(height: 10),
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
              ElevatedButton(
                  onPressed: _updateVenue, child: const Text("Save Changes")),
            ],
          ),
        ),
      ),
    );
  }
}
