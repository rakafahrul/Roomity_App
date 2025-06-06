// import 'package:flutter/material.dart';
// import 'package:rom_app/models/booking.dart';
// // import 'package:rom_app/services/api_service.dart';


// class UserBookingDetailsScreen extends StatelessWidget {
//   final Booking booking;

//   const UserBookingDetailsScreen({required this.booking, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Booking Details')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Room: ${booking.roomId}'),
//             Text('Date: ${booking.bookingDate}'),
//             Text('Start Time: ${booking.startTime}'),
//             Text('End Time: ${booking.endTime}'),
//             Text('Purpose: ${booking.purpose}'),
//             Text('Status: ${booking.status}'),
//             if (booking.status == 'approved')
//               Column(
//                 children: [
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/user/checkin', arguments: booking.id);
//                     },
//                     child: const Text('Check In'),
//                   ),
//                   const SizedBox(height: 10),
//                   ElevatedButton(
//                     onPressed: () {
//                       Navigator.pushNamed(context, '/user/checkout', arguments: booking.id);
//                     },
//                     child: const Text('Check Out'),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rom_app/models/booking.dart';

class UserBookingDetailsScreen extends StatelessWidget {
  final Booking booking;

  const UserBookingDetailsScreen({required this.booking, super.key});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final timeFormat = DateFormat('HH:mm');
    final statusColor = _statusColor(booking.status);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Peminjaman'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Foto ruangan
            if (booking.roomPhotoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  booking.roomPhotoUrl!,
                  width: double.infinity,
                  height: 160,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 20),
            // Nama ruangan & lokasi
            Text(
              'Ruangan ID: ${booking.roomId}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              'Booking ID: ${booking.id}',
              style: const TextStyle(color: Colors.black54, fontSize: 14),
            ),
            const SizedBox(height: 16),
            // Tanggal & jam
            Row(
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20, color: Colors.black45),
                const SizedBox(width: 8),
                Text(
                  dateFormat.format(booking.bookingDate),
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 20, color: Colors.black45),
                const SizedBox(width: 8),
                Text(
                  '${booking.startTime} - ${booking.endTime} WIB',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Keperluan
            const Text(
              'Keperluan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              booking.purpose,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            // Status
            Row(
              children: [
                const Text(
                  'Status: ',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(booking.status),
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Checkin/Checkout info
            if (booking.checkinTime != null)
              Row(
                children: [
                  const Icon(Icons.login, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Check-in: ${DateFormat('dd MMM yyyy, HH:mm').format(booking.checkinTime!)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            if (booking.checkoutTime != null)
              Row(
                children: [
                  const Icon(Icons.logout, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Check-out: ${DateFormat('dd MMM yyyy, HH:mm').format(booking.checkoutTime!)}',
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            const SizedBox(height: 24),
            // Tombol Check-in/Check-out jika status approved
            if (booking.status == 'approved')
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/user/checkin', arguments: booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4DD18B),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Check In', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/user/checkout', arguments: booking.id);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF192965),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Check Out', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'approved':
        return const Color(0xFF4DD18B);
      case 'pending':
        return const Color(0xFF192965);
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'approved':
        return 'Disetujui';
      case 'pending':
        return 'Pengajuan';
      case 'rejected':
        return 'Ditolak';
      default:
        return status;
    }
  }
}











