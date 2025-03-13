import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TimeSlotManagement extends StatefulWidget {
  const TimeSlotManagement({super.key});

  @override
  TimeSlotManagementState createState() => TimeSlotManagementState();
}

class TimeSlotManagementState extends State<TimeSlotManagement> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  late CollectionReference timeslotsRef;
  DateTime? selectedWeek;

  String? selectedVenueType;
  String? selectedDate;
  String? selectedTime;

  List<Map<String, dynamic>> venues = [];
  List<String> timeSlots = [
    "All", // Add "All" as the first option
    "08:30",
    "09:00",
    "09:30",
    "10:00",
    "10:30",
    "11:00",
    "11:30",
    "12:00",
    "12:30",
    "13:00",
    "13:30",
    "14:00",
    "14:30",
    "15:00",
    "15:30",
    "16:00",
    "16:30",
    "17:00"
  ];

  List<String> venueTypeOptions = [
    "All",
    "Auditorium",
    "Classroom",
    "Lab",
    "Meeting Room"
  ];

  bool isGenerating = false; // Track if time slots are being generated

  @override
  void initState() {
    super.initState();
    timeslotsRef = firestore.collection("timeslots");
    fetchVenues().then((fetchedVenues) {
      setState(() {
        venues = fetchedVenues;
      });
    });
  }

  Future<List<Map<String, dynamic>>> fetchVenues() async {
    QuerySnapshot querySnapshot = await firestore.collection("venues").get();
    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }

  Future<void> _selectWeek(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedWeek ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      if (!mounted) return; // Ensure the widget is still in the tree
      setState(() {
        selectedWeek = _getStartOfWeek(picked);
      });
      _generateTimeslotsForAllVenues(); // Remove `context` from function call
    }
  }

  Future<void> _generateTimeslotsForAllVenues() async {
    if (selectedWeek == null) return;

    setState(() {
      isGenerating = true;
    });

    for (int i = 0; i < 5; i++) {
      DateTime currentDate = selectedWeek!.add(Duration(days: i));
      String formattedDate = DateFormat('yyyy-MM-dd').format(currentDate);

      for (var venue in venues) {
        String venueName = venue["name"];
        String venueType = venue["venuetype"];
        String block = venue["block"];
        int capacity = venue["capacity"];
        List<dynamic> equipment = venue["equipment"];
        String level = venue["level"];
        String status = venue["status"];

        for (int j = 0; j < timeSlots.length - 1; j++) {
          String startTime = timeSlots[j];
          String endTime = timeSlots[j + 1];

          await timeslotsRef.add({
            "venueName": venueName,
            "venueType": venueType,
            "block": block,
            "capacity": capacity,
            "equipment": equipment,
            "level": level,
            "status": status,
            "date": formattedDate,
            "startTime": startTime,
            "endTime": endTime,
          });

          if (!mounted) return; // Ensure widget is still in the tree
        }
      }
    }

    if (!mounted) return;

    setState(() {
      isGenerating = false;
    });

    // Show notification only if widget is still mounted
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("New Time Slots Generated!"),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Time Slot Management",
            style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: [
          // Filters Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDropdown("Type", venueTypeOptions, selectedVenueType,
                        (value) {
                      setState(() {
                        selectedVenueType = value;
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildDateDropdown(),
                    _buildDropdown("Time", timeSlots, selectedTime, (value) {
                      setState(() {
                        selectedTime = value;
                      });
                    }),
                  ],
                ),
              ],
            ),
          ),

          Expanded(
            child: isGenerating
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blue,
                    ),
                  )
                : StreamBuilder<QuerySnapshot>(
                    stream: timeslotsRef.orderBy("date").snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text("No time slots available",
                              style: TextStyle(color: Colors.white)),
                        );
                      }

                      // Filter results based on selected filters
                      List<Map<String, dynamic>> filteredSlots = snapshot
                          .data!.docs
                          .map((doc) => doc.data() as Map<String, dynamic>)
                          .where((slot) =>
                              (selectedVenueType == null ||
                                  selectedVenueType == "All" ||
                                  slot["venueType"] == selectedVenueType) &&
                              (selectedDate == null ||
                                  selectedDate == "All" ||
                                  slot["date"] == selectedDate) &&
                              (selectedTime == null ||
                                  selectedTime == "All" ||
                                  slot["startTime"] ==
                                      selectedTime)) // Filter by start time
                          .toList();

                      if (filteredSlots.isEmpty) {
                        return const Center(
                          child: Text("No matching time slots",
                              style: TextStyle(color: Colors.white)),
                        );
                      }

                      // Group time slots by date and venue
                      Map<String, Map<String, List<Map<String, dynamic>>>>
                          groupedSlots = {};
                      for (var slot in filteredSlots) {
                        String date = slot["date"];
                        String venueName = slot["venueName"];

                        if (!groupedSlots.containsKey(date)) {
                          groupedSlots[date] = {};
                        }
                        if (!groupedSlots[date]!.containsKey(venueName)) {
                          groupedSlots[date]![venueName] = [];
                        }
                        groupedSlots[date]![venueName]!.add(slot);
                      }

                      return ListView(
                        children: groupedSlots.entries.map((dateEntry) {
                          String date = dateEntry.key;
                          Map<String, List<Map<String, dynamic>>> venuesMap =
                              dateEntry.value;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Date: $date",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...venuesMap.entries.map((venueEntry) {
                                String venueName = venueEntry.key;
                                List<Map<String, dynamic>> slots =
                                    venueEntry.value;

                                // Sort time slots by startTime
                                slots.sort((a, b) =>
                                    a["startTime"].compareTo(b["startTime"]));

                                return Card(
                                  color: Colors.grey[900],
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 6),
                                  child: ExpansionTile(
                                    title: Text(
                                      venueName,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    children: slots.map((slot) {
                                      return ListTile(
                                        title: Text(
                                          "${slot["startTime"]} - ${slot["endTime"]}",
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                );
                              })
                            ],
                          );
                        }).toList(),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        icon: const Icon(Icons.calendar_today, color: Colors.white),
        label: const Text("Generate Weekly Time Slots",
            style: TextStyle(color: Colors.white)),
        onPressed: () => _selectWeek(context),
      ),
    );
  }

  /// Dropdown widget builder
  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return DropdownButton<String>(
      dropdownColor: Colors.grey[900],
      value: selectedValue,
      hint: Text(label, style: const TextStyle(color: Colors.white)),
      icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
      onChanged: onChanged,
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(color: Colors.white)),
        );
      }).toList(),
    );
  }

  /// Dropdown for selecting a date
  Widget _buildDateDropdown() {
    return StreamBuilder<QuerySnapshot>(
      stream: timeslotsRef.orderBy("date").snapshots(),
      builder: (context, snapshot) {
        List<String> dates = snapshot.hasData
            ? snapshot.data!.docs
                .map((doc) =>
                    (doc.data() as Map<String, dynamic>)["date"].toString())
                .toSet()
                .toList()
            : [];
        dates.insert(0, "All");

        return _buildDropdown("Date", dates, selectedDate, (value) {
          setState(() {
            selectedDate = value;
          });
        });
      },
    );
  }
}

DateTime _getStartOfWeek(DateTime date) {
  int difference = date.weekday - DateTime.monday; // Get difference from Monday
  return date.subtract(Duration(days: difference));
}
