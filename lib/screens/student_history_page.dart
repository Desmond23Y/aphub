import 'dart:async';

import 'package:aphub/screens/student_booking_page.dart';
import 'package:flutter/material.dart';
import 'package:aphub/utils/app_colors.dart';
import 'package:aphub/roles/students.dart';
import 'package:aphub/screens/student_notification_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:aphub/login_page.dart'; 


class StudentHistoryPage extends StatefulWidget {
  final String tpNumber;

  const StudentHistoryPage({super.key, required this.tpNumber});

  @override
  StudentHistoryPageState createState() => StudentHistoryPageState();
}

class StudentHistoryPageState extends State<StudentHistoryPage> {
  String selectedFacility = 'All'; // Move to state
  String selectedStatus = 'All'; // Move to state

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Sign out the user

      // Navigate to the login page and remove all previous routes
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    } catch (e) {
      debugPrint("Error during logout: $e");
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to log out. Please try again.')),
      );
    }
  }

  @override

  void initState() {
    super.initState();
    _checkAndUpdateBookingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Image(
          image: AssetImage('assets/icons/MAE_APHUB_MENU_ICON.png'),
          width: 90,
        ),
        backgroundColor: AppColors.darkdarkgrey,
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 15),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      StudentNotificationPage(tpNumber: widget.tpNumber),
                ),
              );
            },
            icon: const Image(
              image: AssetImage('assets/icons/MAE_notification_icon.png'),
              width: 35,
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.black,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _buildCurrentBooking(widget.tpNumber),
            const SizedBox(height: 20),
            _buildPastBooking(),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: AppColors.darkdarkgrey,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem('assets/icons/MAE_Calender_icon.png', 'Booking', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        StudentBookingPage(tpNumber: widget.tpNumber),
                  ),
                );
              }),
              _buildNavItem(
                'assets/icons/MAE_History_icon.png',
                'History',
                () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You are already on the History page!')),
                  );
                },
              ),
              _buildNavItem('assets/icons/MAE_Home_Icon.png', 'Home', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => StudentPage(tpNumber: widget.tpNumber),
                  ),
                );
              }),
              _buildNavItem('assets/icons/MAE_logout_icon.png', 'Logout', () {_logout();}),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildCurrentBooking(String tpNumber) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.darkdarkgrey,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkdarkgrey.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Current Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            DropdownButton<String>(
              dropdownColor: AppColors.darkdarkgrey.withOpacity(0.7),
              value: selectedFacility,
              items: ['All', 'Lab', 'Meeting room', 'Classroom', 'Auditorium']
                  .map((facility) => DropdownMenuItem(
                        value: facility,
                        child: Text(
                          facility,
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFacility = value!;
                });
              },
            ),
            DropdownButton<String>(
              dropdownColor: AppColors.darkdarkgrey.withOpacity(0.7),
              value: selectedStatus,
              items: ['All', 'Pending', 'Scheduled', 'Ongoing']
                  .map((status) => DropdownMenuItem(
                        value: status,
                        child: Text(
                          status,
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('TPbooking') // Query the TPbooking collection
              .where('userId', isEqualTo: widget.tpNumber) // Filter by userId
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildNoDataMessage('No bookings available');
            }

            final bookings = snapshot.data!.docs;

            // Apply filters locally
            final filteredBookings = bookings.where((booking) {
              final status = booking['status'] ?? 'unknown';
              final venueType = booking['venueType'] ?? 'Unknown';

              // Filter by selected status
              bool matchesStatus = selectedStatus == 'All' ||
                  status.toLowerCase() == selectedStatus.toLowerCase();

              // Filter by selected facility
              bool matchesFacility = selectedFacility == 'All' ||
                  venueType == selectedFacility;

              return matchesStatus && matchesFacility;
            }).toList();

            if (filteredBookings.isEmpty) {
              return _buildNoDataMessage('No bookings match the selected filters');
            }

            // Filter the bookings to include only ongoing, scheduled, and pending statuses
            final filteredList = filteredBookings.where((booking) {
              final status = booking['status']?.toLowerCase() ?? 'unknown';
              return status == 'ongoing' || status == 'scheduled' || status == 'pending';
            }).toList();

            // Calculate the total number of bookings
            final totalBookings = filteredList.length;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Bookings: $totalBookings', // Display the total number of bookings
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredList.length, // Use the filtered list length
                  itemBuilder: (context, index) {
                    final booking = filteredList[index]; // Use the filtered list
                    final bookingId = booking.id; // Get the booking ID
                    final status = booking['status'] ?? 'unknown';
                    final startTime = booking['startTime'] ?? 'N/A';
                    final endTime = booking['endTime'] ?? 'N/A';
                    final timeRange = '$startTime - $endTime';
                    final venueName = booking['venueName'] ?? 'Unknown';
                    final venueType = booking['venueType'] ?? 'Unknown';
                    final date = booking['date'] ?? 'Unknown';

                    // Determine the color based on the status
                    Color statusColor;
                    switch (status.toLowerCase()) {
                      case 'scheduled':
                        statusColor = Colors.orange;
                        break;
                      case 'ongoing':
                        statusColor = Colors.green;
                        break;
                      case 'pending':
                        statusColor = Colors.yellow;
                        break;
                      default:
                        statusColor = AppColors.white; // Default color if status is unknown
                    }

                    // Dynamic opacity for the shadow
                    const opacity = 0.5; // You can adjust this value as needed

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8), // Add margin
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.darkgrey.withOpacity(opacity), // Shadow color with dynamic opacity
                            blurRadius: 6, // Blur radius
                            spreadRadius: 0.5, // Spread radius
                            offset: const Offset(0, 4), // Shadow offset
                          ),
                        ],
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.black.withOpacity(0.7), // Black background with 70% opacity
                          borderRadius: BorderRadius.circular(8), // Match the outer container's border radius
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Add padding inside ListTile
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Date: $date', // Display the date
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8), // Add spacing between date and timeRange
                              Text(
                                timeRange,
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8), // Add spacing between timeRange and venue details
                              Text(
                                'Venue: $venueName',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 4), // Add spacing between venue name and type
                              Text(
                                'Type: $venueType',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Status Container
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // Padding inside the box
                                decoration: BoxDecoration(
                                  color: statusColor.withOpacity(0.2), // Background color with slight opacity
                                  borderRadius: BorderRadius.circular(12), // Rounded edges
                                  border: Border.all(
                                    color: statusColor, // Border color
                                    width: 1, // Border width
                                  ),
                                ),
                                child: Text(
                                  status, // Display the full status text
                                  style: TextStyle(
                                    color: statusColor, // Text color
                                    fontSize: 12, // Adjust font size if needed
                                    fontWeight: FontWeight.bold, // Bold text
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8), // Add spacing between status and cancel button
                              // Cancel Button
                              if (status.toLowerCase() == 'pending' || status.toLowerCase() == 'scheduled')
                                IconButton(
                                  icon: const Icon(Icons.cancel, color: Colors.red),
                                    onPressed: () async {
                                    // Show a confirmation dialog
                                    bool confirmCancel = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Cancel Booking'),
                                        content: const Text('Are you sure you want to cancel this booking?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, false),
                                            child: const Text('No'),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.pop(context, true),
                                            child: const Text('Yes'),
                                          ),
                                        ],
                                      ),
                                    );

                                    if (confirmCancel == true) {
                                      try {
                                        // Step 1: Update the status in the TPbooking collection
                                        await FirebaseFirestore.instance
                                            .collection('TPbooking')
                                            .doc(bookingId)
                                            .update({'status': 'cancelled'});

                                        // Step 2: Update the status in the TPform collection where TPbookingId matches
                                        final tpFormQuery = await FirebaseFirestore.instance
                                            .collection('TPform')
                                            .where('TPbookingId', isEqualTo: bookingId)
                                            .get();

                                        if (tpFormQuery.docs.isNotEmpty) {
                                          // If a matching TPform document is found, update its status
                                          for (final doc in tpFormQuery.docs) {
                                            await FirebaseFirestore.instance
                                                .collection('TPform')
                                                .doc(doc.id)
                                                .update({'status': 'cancelled'});
                                          }
                                        }

                                        // Step 3: Update the timeslots collection from "scheduled" to "available"
                                        debugPrint('Querying timeslots with:');
                                        debugPrint('venueName: $venueName');
                                        debugPrint('startTime: $startTime');
                                        debugPrint('endTime: $endTime');
                                        debugPrint('date: $date');

                                        final timeslotQuery = await FirebaseFirestore.instance
                                            .collection('timeslots')
                                            .where('venueName', isEqualTo: venueName)
                                            .where('startTime', isEqualTo: startTime)
                                            .where('endTime', isEqualTo: endTime)
                                            .where('date', isEqualTo: date)
                                            .get();

                                        if (timeslotQuery.docs.isNotEmpty) {
                                          // Log the found document
                                          debugPrint('Found matching timeslot document:');
                                          debugPrint(timeslotQuery.docs.first.data().toString());

                                          // Update the first matching document (assuming there's only one)
                                          final timeslotDocRef = timeslotQuery.docs.first.reference;
                                          await timeslotDocRef.update({'status': 'available'});
                                          debugPrint('Timeslot status updated to "available"');
                                        } else {
                                          debugPrint('No matching timeslot document found');
                                          throw Exception('Matching timeslot not found');
                                        }

                                        // Step 4: Add a notification to the 'notifications' collection
                                        await FirebaseFirestore.instance.collection('notifications').add({
                                          'date': date,
                                          'bstatus': 'cancelled',
                                          'venueName': venueName,
                                          'venueType': venueType,
                                          'userId': widget.tpNumber,
                                          'bookedtime': DateTime.now(),
                                          'message':
                                              'Your booking for "$venueName" on $date from $startTime to $endTime has been cancelled successfully.',
                                          'nstatus': 'new',
                                          'startTime': startTime,
                                          'endTime': endTime,
                                        });

                                        // Show a success message
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Booking cancelled successfully')),
                                        );
                                      } catch (e) {
                                        // Handle any errors
                                        debugPrint('Error cancelling booking: $e');
                                        // ignore: use_build_context_synchronously
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Failed to cancel booking: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

Widget _buildPastBooking() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    margin: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.darkdarkgrey,
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(
          color: AppColors.darkdarkgrey.withOpacity(0.3),
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Past Booking',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.white,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Facility Dropdown
            DropdownButton<String>(
              dropdownColor: AppColors.darkdarkgrey.withOpacity(0.7),
              value: selectedFacility,
              items: {
                'All',
                'Lab',
                'Meeting room',
                'Classroom',
                'Auditorium'
              }.toList() // Ensure unique values
                  .map((facility) => DropdownMenuItem(
                        value: facility, // Ensure this value is unique
                        child: Text(
                          facility,
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedFacility = value!;
                });
              },
            ),
            // Status Dropdown
            DropdownButton<String>(
              dropdownColor: AppColors.darkdarkgrey.withOpacity(0.7),
              value: selectedStatus,
              items: ['All', 'Completed', 'Cancelled', 'Ongoing', 'Scheduled', '']
                  .map((status) => DropdownMenuItem(
                        value: status, // Ensure this value is unique
                        child: Text(
                          status,
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('TPbooking') // Query the TPbooking collection
              .where('userId', isEqualTo: widget.tpNumber) // Filter by userId
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return _buildNoDataMessage('No past bookings available');
            }

            final bookings = snapshot.data!.docs;

            // Apply filters locally
            final filteredBookings = bookings.where((booking) {
              final status = booking['status']?.toString().toLowerCase() ?? 'unknown';
              final venueType = booking['venueType']?.toString() ?? 'Unknown';

              // Filter by selected status
              bool matchesStatus = selectedStatus.toLowerCase() == 'all' ||
                  status == selectedStatus.toLowerCase();

              // Filter by selected facility
              bool matchesFacility = selectedFacility == 'All' ||
                  venueType == selectedFacility;

              return matchesStatus && matchesFacility;
            }).toList();

            if (filteredBookings.isEmpty) {
              return _buildNoDataMessage('No past bookings match the selected filters');
            }

            // Filter the bookings to include only "Cancelled" and "Completed" statuses
            final pastBookings = filteredBookings.where((booking) {
              final status = booking['status']?.toString().toLowerCase() ?? 'unknown';
              return status == 'cancelled' || status == 'completed';
            }).toList();

            if (pastBookings.isEmpty) {
              return _buildNoDataMessage('No past bookings available');
            }

            return SingleChildScrollView(
              child: Column(
                children: List.generate(pastBookings.length, (index) {
                  final booking = pastBookings[index]; // Use the filtered list
                  final status = booking['status'] ?? 'unknown';
                  final startTime = booking['startTime'] ?? 'N/A';
                  final endTime = booking['endTime'] ?? 'N/A';
                  final timeRange = '$startTime - $endTime';
                  final venueName = booking['venueName'] ?? 'Unknown';
                  final venueType = booking['venueType'] ?? 'Unknown';
                  final date = booking['date'] ?? 'Unknown';

                  // Determine the color based on the status
                  Color statusColor;
                  switch (status.toLowerCase()) {
                    case 'completed':
                      statusColor = Colors.green;
                      break;
                    case 'cancelled':
                      statusColor = Colors.red;
                      break;
                    default:
                      statusColor = AppColors.white; // Default color if status is unknown
                  }

                  // Dynamic opacity for the shadow
                  const opacity = 0.5; // You can adjust this value as needed

                  return Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 8), // Add margin
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8), // Rounded corners
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkgrey.withOpacity(
                              opacity), // Shadow color with dynamic opacity
                          blurRadius: 6, // Blur radius
                          spreadRadius: 0.5, // Spread radius
                          offset: const Offset(0, 4), // Shadow offset
                        ),
                      ],
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.black.withOpacity(
                            0.7), // Black background with 70% opacity
                        borderRadius: BorderRadius.circular(
                            8), // Match the outer container's border radius
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12), // Add padding inside ListTile
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Date: $date', // Display the date
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8), // Add spacing between date and timeRange
                            Text(
                              timeRange,
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8), // Add spacing between timeRange and venue details
                            Text(
                              'Venue: $venueName',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4), // Add spacing between venue name and type
                            Text(
                              'Type: $venueType',
                              style: const TextStyle(
                                color: AppColors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6), // Padding inside the box
                          decoration: BoxDecoration(
                            color: statusColor.withOpacity(
                                0.2), // Background color with slight opacity
                            borderRadius: BorderRadius.circular(
                                12), // Rounded edges
                            border: Border.all(
                              color: statusColor, // Border color
                              width: 1, // Border width
                            ),
                          ),
                          child: Text(
                            status, // Display the full status text
                            style: TextStyle(
                              color: statusColor, // Text color
                              fontSize: 12, // Adjust font size if needed
                              fontWeight: FontWeight.bold, // Bold text
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          },
        ),
      ],
    ),
  );
}

void _checkAndUpdateBookingStatus() {
  Timer.periodic(const Duration(minutes: 1), (timer) async {
    final now = DateTime.now();
    final bookings = await FirebaseFirestore.instance
        .collection('TPbooking')
        .where('userId', isEqualTo: widget.tpNumber)
        .get();

    for (final booking in bookings.docs) {
      final startTime = booking['startTime'];
      final endTime = booking['endTime'];
      final date = booking['date'];
      final status = booking['status'];
      final venueName = booking['venueName'];
      final venueType = booking['venueType'];

      final bookingDateTime = DateTime.parse('$date $startTime');
      final endDateTime = DateTime.parse('$date $endTime');

      if (status == 'scheduled' && now.isAfter(bookingDateTime)) {
        if (now.isBefore(endDateTime)) {
          // Update status to "ongoing" if the current time is between startTime and endTime
          await FirebaseFirestore.instance
              .collection('TPbooking')
              .doc(booking.id)
              .update({'status': 'ongoing'});

          // Send notification for "ongoing" status
          await FirebaseFirestore.instance.collection('notifications').add({
            'date': date,
            'bstatus': 'ongoing',
            'venueName': venueName,
            'venueType': venueType,
            'userId': widget.tpNumber,
            'bookedtime': DateTime.now(),
            'message':
                'Your booking for "$venueName" on $date from $startTime is currently ongoing.',
            'nstatus': 'new',
            'startTime': startTime,
            'endTime': endTime,
          });
        } else {
          // Update status to "completed" if the current time is after endTime
          await FirebaseFirestore.instance
              .collection('TPbooking')
              .doc(booking.id)
              .update({'status': 'completed'});

          // Send notification for "completed" status
          await FirebaseFirestore.instance.collection('notifications').add({
            'date': date,
            'bstatus': 'completed',
            'venueName': venueName,
            'venueType': venueType,
            'userId': widget.tpNumber,
            'bookedtime': DateTime.now(),
            'message':
                'Your booking for "$venueName" on $date from $startTime to $endTime is currently completed.',
            'nstatus': 'new',
            'startTime': startTime,
            'endTime': endTime,
          });
        }
      } else if (status == 'ongoing' && now.isAfter(endDateTime)) {
        // Update status to "completed" if the current time is after endTime
        await FirebaseFirestore.instance
            .collection('TPbooking')
            .doc(booking.id)
            .update({'status': 'completed'});

        // Send notification for "completed" status
        await FirebaseFirestore.instance.collection('notifications').add({
          'date': date,
          'bstatus': 'completed',
          'venueName': venueName,
          'venueType': venueType,
          'userId': widget.tpNumber,
          'bookedtime': DateTime.now(),
          'message':
              'Your booking for "$venueName" on $date from $startTime to $endTime is currently completed.',
          'nstatus': 'new',
          'startTime': startTime,
          'endTime': endTime,
        });
      }
    }
  });
}



  Widget _buildNavItem(String iconPath, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(iconPath, width: 24, height: 24),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(color: AppColors.white)),
        ],
      ),
    );
  }

  Widget _buildNoDataMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 14,
        ),
      ),
    );
  }
}