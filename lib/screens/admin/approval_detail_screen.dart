import 'package:flutter/material.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/models/approval.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminApprovalDetailScreen extends StatefulWidget {
  final Booking booking;

  const AdminApprovalDetailScreen({required this.booking, super.key});

  @override
  _AdminApprovalDetailScreenState createState() => _AdminApprovalDetailScreenState();
}

class _AdminApprovalDetailScreenState extends State<AdminApprovalDetailScreen> {
  List<Approval> _approvals = [];
  String _note = '';

  @override
  void initState() {
    super.initState();
    _loadApprovals();
  }

  void _loadApprovals() async {
    try {
      List<Approval> approvals = await ApiService.getApprovals(widget.booking.id);
      setState(() => _approvals = approvals);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load approvals');
    }
  }

  void _approveBooking() async {
    if (_note.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter approval note');
      return;
    }

    try {
      bool success = await ApiService.approveBooking(widget.booking.id, _note);
      if (success) {
        Fluttertoast.showToast(msg: 'Booking approved');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Approval failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Approval failed');
    }
  }

  void _rejectBooking() async {
    if (_note.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter rejection note');
      return;
    }

    try {
      bool success = await ApiService.rejectBooking(widget.booking.id, _note);
      if (success) {
        Fluttertoast.showToast(msg: 'Booking rejected');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Rejection failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Rejection failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Approval Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Room: ${widget.booking.roomId}'),
            Text('Date: ${widget.booking.bookingDate}'),
            Text('Start Time: ${widget.booking.startTime}'),
            Text('End Time: ${widget.booking.endTime}'),
            Text('Purpose: ${widget.booking.purpose}'),
            const SizedBox(height: 20),
            TextFormField(
              decoration: const InputDecoration(labelText: 'Note'),
              onChanged: (value) => _note = value,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _approveBooking,
              child: const Text('Approve'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _rejectBooking,
              child: const Text('Reject'),
            ),
            const SizedBox(height: 20),
            ListView.builder(
              shrinkWrap: true,
              itemCount: _approvals.length,
              itemBuilder: (context, index) {
                Approval approval = _approvals[index];
                return ListTile(
                  title: Text('Stage: ${approval.stage}'),
                  subtitle: Text('Status: ${approval.status}'),
                  trailing: Text(approval.note),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}