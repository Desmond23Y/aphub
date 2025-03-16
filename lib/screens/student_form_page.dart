import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aphub/utils/app_colors.dart';

class StudentFormPage extends StatefulWidget {
  final String tpNumber;
  final String timeslotId;

  const StudentFormPage({super.key, required this.tpNumber, required this.timeslotId});

  @override
  StudentFormPageState createState() => StudentFormPageState();
}

class StudentFormPageState extends State<StudentFormPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController eventNameController = TextEditingController();
  final TextEditingController eventTypeController = TextEditingController();
  final TextEditingController estPersonController = TextEditingController();

  Map<String, dynamic>? timeslotData;

  @override
  void initState() {
    super.initState();
    fetchTimeslotData();
  }

  Future<void> fetchTimeslotData() async {
    try {
      DocumentSnapshot timeslotSnapshot = await FirebaseFirestore.instance
          .collection('timeslots')
          .doc(widget.timeslotId)
          .get();
      if (timeslotSnapshot.exists) {
        setState(() {
          timeslotData = timeslotSnapshot.data() as Map<String, dynamic>?;
        });
      }
    } catch (e) {
      //
    }
  }

void submitBooking() async {
  if (_formKey.currentState!.validate()) {
    try {
      if (timeslotData == null) {
        throw Exception("Timeslot data is null.");
      }

      // Fetch the student name from the `users` collection
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.tpNumber) // Use the TPNumber to fetch the document
          .get();

      if (!userDoc.exists) {
        throw Exception("User not found in the users collection.");
      }

      final studentName = userDoc['name'] ?? 'Unknown'; // Get the student name

      // Check if estperson is a valid number
      final estPerson = int.tryParse(estPersonController.text);
      if (estPerson == null) {
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please enter a valid number for estimated persons.")),
        );
        return;
      }

      // Proceed with booking submission
      DocumentReference timeslotRef = FirebaseFirestore.instance.collection('timeslots').doc(widget.timeslotId);
      await timeslotRef.update({'status': 'pending'});

      DocumentReference tpBookingRef = await FirebaseFirestore.instance.collection('TPbooking').add({
        'userId': widget.tpNumber,
        'name': studentName, // Include the student name
        'date': timeslotData?['date'],
        'startTime': timeslotData?['startTime'],
        'endTime': timeslotData?['endTime'],
        'status': 'pending',
        'venueName': timeslotData?['venueName'],
        'venueType': timeslotData?['venueType'],
        'bookedtime': DateTime.now(),
      });

      String tpBookingId = tpBookingRef.id;

      await FirebaseFirestore.instance.collection('TPform').add({
        'userId': widget.tpNumber,
        'name': studentName, // Include the student name
        'eventname': eventNameController.text,
        'eventtype': eventTypeController.text,
        'estperson': estPerson,
        'capacity': timeslotData?['capacity'],
        'date': timeslotData?['date'],
        'startTime': timeslotData?['startTime'],
        'endTime': timeslotData?['endTime'],
        'status': 'pending',
        'venueName': timeslotData?['venueName'],
        'venueType': timeslotData?['venueType'],
        'bookedtime': DateTime.now(),
        'TPbookingId': tpBookingId,
      });

      await FirebaseFirestore.instance.collection('notifications').add({
        'date': timeslotData?['date'],
        'bstatus': 'pending',
        'venueName': timeslotData?['venueName'],
        'venueType': timeslotData?['venueType'],
        'userId': widget.tpNumber,
        'bookedtime': DateTime.now(),
        'message': 'Your booking for "${timeslotData?['venueName']}" is pending approval. Your booking is on ${timeslotData?['date']} from ${timeslotData?['startTime']} to ${timeslotData?['endTime']}.',
        'nstatus': 'new',
        'startTime': timeslotData?['startTime'],
        'endTime': timeslotData?['endTime'],
      });

      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Booking Submitted Successfully!")),
      );

      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
      //
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Book Auditorium", style: TextStyle(color: AppColors.white)),
        backgroundColor: AppColors.darkdarkgrey,
      ),
      body: Container(
        color: AppColors.black,
        child: timeslotData == null
            ? const Center(child: CircularProgressIndicator(color: AppColors.white))
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Enhanced Hall Information Card
                      Card(
                        color: AppColors.darkdarkgrey,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        elevation: 5,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                "Hall Information",
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                              ),
                              const SizedBox(height: 16),
                              _buildReadOnlyTextField("Venue Name", timeslotData?['venueName'] ?? 'N/A'),
                              const SizedBox(height: 8),
                              _buildReadOnlyTextField("Venue Type", timeslotData?['venueType'] ?? 'N/A'),
                              const SizedBox(height: 8),
                              _buildReadOnlyTextField("Capacity", timeslotData?['capacity']?.toString() ?? 'N/A'),
                              const SizedBox(height: 8),
                              _buildReadOnlyTextField("Date", timeslotData?['date'] ?? 'N/A'),
                              const SizedBox(height: 8),
                              _buildReadOnlyTextField("Time", "${timeslotData?['startTime'] ?? 'N/A'} - ${timeslotData?['endTime'] ?? 'N/A'}"),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Equipment Information Card
                      if (timeslotData?['equipment'] != null)
                        Card(
                          color: AppColors.darkdarkgrey,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          elevation: 5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  "Equipment",
                                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.white),
                                ),
                                const SizedBox(height: 16),
                                ...(timeslotData?['equipment'] as List<dynamic>).map((equipment) {
                                  return _buildReadOnlyTextField("Equipment", equipment);
                                })
                              ],
                            ),
                          ),
                        ),
                      const SizedBox(height: 20),

                      // Booking Form
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            _buildTextField(eventNameController, "Event Name"),
                            const SizedBox(height: 10),
                            _buildTextField(eventTypeController, "Event Type"),
                            const SizedBox(height: 10),
                            _buildTextField(estPersonController, "Estimated Persons", isNumber: true),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: submitBooking,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.lightgrey,
                                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text("Submit Booking", style: TextStyle(color: AppColors.black)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {bool isNumber = false}) {
    return Card(
      color: AppColors.darkdarkgrey, // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      elevation: 0, // Remove shadow to match the Equipment/Hall Information tabs
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding
        child: TextFormField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: InputBorder.none, // Remove the default border
            focusedBorder: InputBorder.none, // Remove the default border
            border: InputBorder.none, // Remove the default border
          ),
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "Please enter $label"; // Ensure the field is not empty
            }
            if (isNumber && int.tryParse(value) == null) {
              return "Please enter a valid number for $label"; // Ensure the input is a valid number
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildReadOnlyTextField(String label, String value) {
    return Card(
      color: AppColors.darkdarkgrey, // Set the background color
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // Rounded corners
      ),
      elevation: 0, // Remove shadow to match the Equipment/Hall Information tabs
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0), // Add padding
        child: TextFormField(
          initialValue: value,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.white),
            enabledBorder: InputBorder.none, // Remove the default border
            focusedBorder: InputBorder.none, // Remove the default border
            border: InputBorder.none, // Remove the default border
          ),
          enabled: false, // Make the text field non-editable
        ),
      ),
    );
  }
}