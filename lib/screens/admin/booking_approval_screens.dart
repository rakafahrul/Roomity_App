import 'package:flutter/material.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminBookingApprovalScreen extends StatefulWidget {
  const AdminBookingApprovalScreen({super.key});

  @override
  _AdminBookingApprovalScreenState createState() => _AdminBookingApprovalScreenState();
}

class _AdminBookingApprovalScreenState extends State<AdminBookingApprovalScreen> {
  List<Booking> _pendingBookings = [];

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  void _loadBookings() async {
    try {
      List<Booking> bookings = await ApiService.getBookings();
      setState(() => _pendingBookings = bookings.where((b) => b.status == 'pending').toList());
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load bookings');
    }
  }

  void _approveBooking(int bookingId, String note) async {
    bool success = await ApiService.approveBooking(bookingId, note);
    if (success) {
      _loadBookings();
    }
  }

  void _rejectBooking(int bookingId, String note) async {
    bool success = await ApiService.rejectBooking(bookingId, note);
    if (success) {
      _loadBookings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Approvals')),
      body: ListView.builder(
        itemCount: _pendingBookings.length,
        itemBuilder: (context, index) {
          Booking booking = _pendingBookings[index];
          return ListTile(
            title: Text('Room: ${booking.roomId}'),
            subtitle: Text('Date: ${booking.bookingDate}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.approval),
                  onPressed: () {
                    _approveBooking(booking.id, 'Approved');
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: () {
                    _rejectBooking(booking.id, 'Rejected');
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}