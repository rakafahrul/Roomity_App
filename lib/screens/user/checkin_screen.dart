import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/services/api_service.dart';

class UserCheckinScreen extends StatefulWidget {
  final int bookingId;

  const UserCheckinScreen({required this.bookingId, super.key});

  @override
  _UserCheckinScreenState createState() => _UserCheckinScreenState();
}

class _UserCheckinScreenState extends State<UserCheckinScreen> {
  String _locationGps = '';

  void _submitCheckin() async {
    if (_locationGps.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter GPS location');
      return;
    }

    try {
      bool success = await ApiService.checkin(widget.bookingId, _locationGps);
      
      if (success) {
        Fluttertoast.showToast(msg: 'Check-in successful');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Check-in failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Check-in failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'GPS Location'),
              onChanged: (value) => _locationGps = value,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitCheckin,
              child: const Text('Submit Check In'),
            ),
          ],
        ),
      ),
    );
  }
}