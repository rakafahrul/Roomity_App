import 'package:flutter/material.dart';
import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/services/api_service.dart';


class UserBookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const UserBookingDetailsScreen({required this.booking, super.key});

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
            Text('Purpose: ${booking.purpose}'),
            Text('Status: ${booking.status}'),
            if (booking.status == 'approved')
              Column(
                children: [
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/user/checkin', arguments: booking.id);
                    },
                    child: const Text('Check In'),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/user/checkout', arguments: booking.id);
                    },
                    child: const Text('Check Out'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}