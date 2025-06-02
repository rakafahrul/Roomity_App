import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rom_app/services/api_service.dart';

class UserCheckoutScreen extends StatefulWidget {
  final int bookingId;

  const UserCheckoutScreen({required this.bookingId, super.key});

  @override
  _UserCheckoutScreenState createState() => _UserCheckoutScreenState();
}

class _UserCheckoutScreenState extends State<UserCheckoutScreen> {
  File? _beforeImage;
  File? _afterImage;
  bool _isLoading = false;

  Future<void> _pickImage(bool isBefore) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.camera);
    if (picked != null) {
      setState(() {
        if (isBefore) {
          _beforeImage = File(picked.path);
        } else {
          _afterImage = File(picked.path);
        }
      });
    }
  }

  Future<String> _uploadToServer(File image) async {
    // TODO: Upload image to your storage (e.g. Firebase Storage) and get the URL
    // For now, just return the file path as a placeholder
    return image.path;
  }

  void _submitCheckout() async {
    if (_beforeImage == null || _afterImage == null) {
      Fluttertoast.showToast(msg: 'Upload foto before & after!');
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Upload foto before
      String beforeUrl = await _uploadToServer(_beforeImage!);
      bool beforeSuccess = await ApiService.checkout(widget.bookingId, beforeUrl);

      // Upload foto after
      String afterUrl = await _uploadToServer(_afterImage!);
      bool afterSuccess = await ApiService.checkout(widget.bookingId, afterUrl);

      setState(() => _isLoading = false);

      if (beforeSuccess && afterSuccess) {
        Fluttertoast.showToast(msg: 'Checkout berhasil!');
        Navigator.pop(context);
      } else {
        Fluttertoast.showToast(msg: 'Checkout gagal!');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      Fluttertoast.showToast(msg: 'Checkout gagal!');
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
            const Text('Upload Foto Before', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _beforeImage == null
                ? OutlinedButton(
                    onPressed: () => _pickImage(true),
                    child: const Text('Pilih Foto Before'),
                  )
                : Image.file(_beforeImage!, height: 120),
            const SizedBox(height: 24),
            const Text('Upload Foto After', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _afterImage == null
                ? OutlinedButton(
                    onPressed: () => _pickImage(false),
                    child: const Text('Pilih Foto After'),
                  )
                : Image.file(_afterImage!, height: 120),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: (_beforeImage != null && _afterImage != null && !_isLoading)
                    ? _submitCheckout
                    : null,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Submit Check Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}