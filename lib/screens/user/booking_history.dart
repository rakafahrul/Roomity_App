import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/models/booking.dart';

class UserBookingScreen extends StatefulWidget {
  final Room room;

  const UserBookingScreen({required this.room, super.key});

  @override
  _UserBookingScreenState createState() => _UserBookingScreenState();
}

class _UserBookingScreenState extends State<UserBookingScreen> {
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);
  String _purpose = '';

  void _submitBooking() async {
    if (_purpose.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter purpose');
      return;
    }

    try {
      bool success = await ApiService.createBooking(
        Booking(
          id: 0, // This will be assigned by the server
          userId: 1, // Replace with current user ID
          roomId: widget.room.id,
          bookingDate: _selectedDate,
          startTime: _startTime.format(context),
          endTime: _endTime.format(context),
          purpose: _purpose,
          status: 'pending',
          checkinTime: null,
          checkoutTime: null,
          locationGps: '',
          isPresent: false,
          roomPhotoUrl: null,
        ),
      );
      if (success) {
        Fluttertoast.showToast(msg: 'Booking successful');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Booking failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Booking failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Book Meeting Room')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Room: ${widget.room.name}'),
            ElevatedButton(
              onPressed: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(DateTime.now().year + 1),
                );
                if (pickedDate != null) {
                  setState(() => _selectedDate = pickedDate);
                }
              },
              child: Text('Select Date: ${_selectedDate.toString()}'),
            ),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _startTime,
                );
                if (pickedTime != null) {
                  setState(() => _startTime = pickedTime);
                }
              },
              child: Text('Start Time: ${_startTime.format(context)}'),
            ),
            ElevatedButton(
              onPressed: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: _endTime,
                );
                if (pickedTime != null) {
                  setState(() => _endTime = pickedTime);
                }
              },
              child: Text('End Time: ${_endTime.format(context)}'),
            ),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Purpose'),
              onChanged: (value) => _purpose = value,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitBooking,
              child: const Text('Submit Booking'),
            ),
          ],
        ),
      ),
    );
  }
}