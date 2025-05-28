import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/services/api_service.dart';

class UserCheckoutScreen extends StatefulWidget {
  final int bookingId;

  const UserCheckoutScreen({required this.bookingId, super.key});

  @override
  _UserCheckoutScreenState createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  String _photoUrl = '';

  void _submitCheckout() async {
    if (_photoUrl.isEmpty) {
      Fluttertoast.showToast(msg: 'Enter photo URL');
      return;
    }

    try {
      bool success = await ApiService.checkout(widget.bookingId, _photoUrl);
      if (success) {
        Fluttertoast.showToast(msg: 'Checkout successful');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Checkout failed');
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Checkout failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Out')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Photo URL'),
              onChanged: (value) => _photoUrl = value,
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _submitCheckout,
              child: const Text('Submit Check Out'),
            ),
          ],
        ),
      ),
    );
  }
}