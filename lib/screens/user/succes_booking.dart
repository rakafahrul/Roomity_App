import 'package:flutter/material.dart';

class BookingSuccessScreen extends StatelessWidget {
  const BookingSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              Icon(Icons.check_circle_rounded, color: Color(0xFF4DD18B), size: 100),
              const SizedBox(height: 32),
              const Text(
                'Peminjaman Berhasil Diajukan!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  color: Color(0xFF222B45),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Mohon untuk menunggu konfirmasi persetujuan dari pegawai dan mohon untuk selalu memantau proses peminjaman.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: Colors.black54),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/user/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF192965),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Kembali', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}