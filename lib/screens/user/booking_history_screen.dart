import 'package:flutter/material.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserBookingHistoryScreen extends StatefulWidget {
  const UserBookingHistoryScreen({super.key});

  @override
  _UserBookingHistoryScreenState createState() => _UserBookingHistoryScreenState();
}

class _UserBookingHistoryScreenState extends State<UserBookingHistoryScreen> {
  List<Booking> _bookings = [];

  @override
  void initState() {
    super.initState();
    _fetchBookings();
  }

  void _fetchBookings() async {
    try {
      List<Booking> bookings = await ApiService.getBookings();
      setState(() => _bookings = bookings.where((b) => b.status != 'pending').toList());
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking History')),
      body: ListView.builder(
        itemCount: _bookings.length,
        itemBuilder: (context, index) {
          Booking booking = _bookings[index];
          return ListTile(
            title: Text('Room: ${booking.roomId}'),
            subtitle: Text('Date: ${booking.bookingDate}'),
            trailing: Text(booking.status),
            onTap: () {
              Navigator.pushNamed(
                context, '/user/booking_details',
                arguments: booking,
              );
            },
          );
        },
      ),
    );
  }
}