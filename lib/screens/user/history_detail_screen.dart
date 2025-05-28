import 'package:flutter/material.dart';
import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/services/api_service.dart';

class UserHistoryDetailScreen extends StatelessWidget {
  final Booking booking;

  const UserHistoryDetailScreen({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Room: ${booking.roomId}'),
            Text('Date: ${booking.bookingDate}'),
            Text('Start Time: ${booking.startTime}'),
            Text('End Time: ${booking.endTime}'),
            Text('Status: ${booking.status}'),
            if (booking.status == 'approved')
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/user/checkin', arguments: booking.id);
                },
                child: const Text('Check In'),
              ),
          ],
        ),
      ),
    );
  }
}