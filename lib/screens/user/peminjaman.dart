// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/services/api_service.dart';
// import 'package:geolocator/geolocator.dart'; 
// import 'package:image_picker/image_picker.dart'; 
// import 'dart:io';

// class PeminjamanScreen extends StatefulWidget {
//   final int currentUserId;
//   const PeminjamanScreen({super.key, required this.currentUserId});

//   @override
//   State<PeminjamanScreen> createState() => _PeminjamanScreenState();
// }

// class _PeminjamanScreenState extends State<PeminjamanScreen> {
//   String selectedTab = 'pending'; // default: Pengajuan
//   List<Booking> _bookings = [];
//   bool _isLoading = false;

//   final tabMap = {
//     'pending': 'Pengajuan',
//     'approved': 'Disetujui',
//     'in_use': 'Pemakaian',
//     'done': 'Selesai',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadBookings();
//   }

//   Future<void> _loadBookings() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final bookings = await ApiService.getBookings();
//       setState(() {
//         _bookings = bookings.where((b) => b.userId == widget.currentUserId).toList();
//         _isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         _isLoading = false;
//       });
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Gagal memuat data: $e')),
//         );
//       }
//     }
//   }

//   Future<void> _refreshBookings() async {
//     await _loadBookings();
//   }

//   // lokasi ruangan dari booking
//   String _getBookingLocation(Booking booking) {
//     final json = booking.toJson();
//     if (json.containsKey('roomLocation')) {
//       return json['roomLocation'] ?? 'Lokasi tidak tersedia';
//     } else if (json.containsKey('room_location')) {
//       return json['room_location'] ?? 'Lokasi tidak tersedia';
//     } else if (json.containsKey('location')) {
//       return json['location'] ?? 'Lokasi tidak tersedia';
//     }
//     return 'Lokasi tidak tersedia';
//   }

//   //  koordinat ruangan
//   double? _getBookingLatitude(Booking booking) {
//     final json = booking.toJson();
//     if (json.containsKey('roomLatitude')) {
//       return json['roomLatitude']?.toDouble();
//     } else if (json.containsKey('room_latitude')) {
//       return json['room_latitude']?.toDouble();
//     } else if (json.containsKey('latitude')) {
//       return json['latitude']?.toDouble();
//     }
//     return null;
//   }

//   double? _getBookingLongitude(Booking booking) {
//     final json = booking.toJson();
//     if (json.containsKey('roomLongitude')) {
//       return json['roomLongitude']?.toDouble();
//     } else if (json.containsKey('room_longitude')) {
//       return json['room_longitude']?.toDouble();
//     } else if (json.containsKey('longitude')) {
//       return json['longitude']?.toDouble();
//     }
//     return null;
//   }

//   Future<void> _konfirmasiKehadiran(Booking b) async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Nyalakan layanan lokasi')),
//         );
//         return;
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Akses lokasi diperlukan untuk konfirmasi kehadiran')),
//           );
//           return;
//         }
//       }

//       Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

//       // Use booking room coordinates if available, otherwise use default
//       double roomLat = _getBookingLatitude(b) ?? -8.174341070852227;
//       double roomLng = _getBookingLongitude(b) ?? 113.70838347516161;
//       double distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, roomLat, roomLng);

//       if (distance <= 100) {
//         // konfirmasi kehadiran
//         await ApiService.confirmAttendance(
//           b.id,
//           "${pos.latitude},${pos.longitude}",
//         );
        
//         // Refresh data
//         await _refreshBookings();
        
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Kehadiran berhasil dikonfirmasi!'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Anda belum berada di lokasi ruangan! Jarak: ${distance.toInt()}m'),
//             backgroundColor: Colors.orange,
//           ),
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   void _openPertanggungjawaban(Booking booking) async {
//     final result = await Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => PertanggungjawabanScreen(booking: booking),
//       ),
//     );
//     if (result == true) {
//       _refreshBookings(); 
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () {
//             Navigator.pushNamedAndRemoveUntil(
//               context,
//               '/user/home',
//               (route) => false,
//             );
//           },
//         ),
//         title: const Text('Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//       ),
//       body: Column(
//         children: [
//           // Tab Bar
//           Padding(
//             padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: tabMap.entries.map((e) {
//                 final selected = selectedTab == e.key;
//                 return GestureDetector(
//                   onTap: () => setState(() => selectedTab = e.key),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: selected ? Colors.white : Colors.grey[100],
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: selected
//                           ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
//                           : [],
//                     ),
//                     child: Text(
//                       e.value,
//                       style: TextStyle(
//                         color: selected ? const Color(0xFF192965) : Colors.black38,
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
          
//           // Content
//           Expanded(
//             child: RefreshIndicator(
//               onRefresh: _refreshBookings,
//               child: _isLoading
//                   ? const Center(child: CircularProgressIndicator())
//                   : _buildBookingsList(),
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//     );
//   }

//   Widget _buildBookingsList() {
//     final filteredBookings = _bookings.where((b) => b.status == selectedTab).toList();
    
//     if (filteredBookings.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.event_note,
//               size: 64,
//               color: Colors.grey[400],
//             ),
//             const SizedBox(height: 16),
//             Text(
//               'Belum ada peminjaman ${tabMap[selectedTab]?.toLowerCase()}',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//             const SizedBox(height: 8),
//             TextButton.icon(
//               onPressed: _refreshBookings,
//               icon: const Icon(Icons.refresh),
//               label: const Text('Muat Ulang'),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//       itemCount: filteredBookings.length,
//       itemBuilder: (context, i) => _bookingCard(context, filteredBookings[i]),
//     );
//   }

//   Widget _bookingCard(BuildContext context, Booking b) {
//     String formatTime(String time) {
//       try {
//         if (time.contains(':')) {
//           final t = TimeOfDay(
//             hour: int.parse(time.split(':')[0]),
//             minute: int.parse(time.split(':')[1]),
//           );
//           final h = t.hour.toString().padLeft(2, '0');
//           final m = t.minute.toString().padLeft(2, '0');
//           return '$h.$m';
//         }
//         if (time.contains('AM') || time.contains('PM')) {
//           final dt = DateFormat.jm().parse(time);
//           return DateFormat('HH.mm').format(dt);
//         }
//         return time;
//       } catch (e) {
//         return time;
//       }
//     }

//     // Get room photo URL with fallback
//     String getPhotoUrl() {
//       if (b.roomPhotoUrl != null && b.roomPhotoUrl!.isNotEmpty) {
//         return b.roomPhotoUrl!;
//       }
//       return 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2';
//     }

//     return Container(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.black12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.03),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Foto ruangan
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: Image.network(
//                   getPhotoUrl(),
//                   width: 90,
//                   height: 90,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 90,
//                     height: 90,
//                     color: Colors.grey[300],
//                     child: Icon(Icons.meeting_room, color: Colors.grey[600]),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 14),
//               // Info booking
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       b.roomName,
//                       style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//                     ),
//                     const SizedBox(height: 2),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on_rounded, size: 16, color: Colors.black26),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             _getBookingLocation(b),
//                             style: const TextStyle(color: Colors.black45, fontSize: 14),
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.black45),
//                         const SizedBox(width: 6),
//                         Text(
//                           DateFormat('dd MMM yyyy').format(b.bookingDate),
//                           style: const TextStyle(fontSize: 15, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time_rounded, size: 18, color: Colors.black45),
//                         const SizedBox(width: 6),
//                         Text(
//                           '${formatTime(b.startTime)}–${formatTime(b.endTime)} WIB',
//                           style: const TextStyle(fontSize: 15, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.description, size: 16, color: Colors.black45),
//                         const SizedBox(width: 4),
//                         Expanded(
//                           child: Text(
//                             b.purpose,
//                             style: const TextStyle(color: Colors.black45, fontSize: 14),
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
          
//           // Status badge & tombol aksi
//           _buildStatusContent(b),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatusContent(Booking b) {
//     switch (b.status) {
//       case 'pending':
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.orange[100],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Text(
//             'Menunggu Persetujuan',
//             style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
//           ),
//         );

//       case 'approved':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _konfirmasiKehadiran(b),
//                 icon: const Icon(Icons.location_on, size: 18),
//                 label: const Text('Konfirmasi Kehadiran'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF192965),
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.info_outline, color: Colors.blue, size: 16),
//                   SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       'Jika tidak melakukan konfirmasi kehadiran > 1 jam dari jadwal, maka peminjaman otomatis dianggap dibatalkan.',
//                       style: TextStyle(color: Colors.blue, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );

//       case 'in_use':
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _openPertanggungjawaban(b),
//                 icon: const Icon(Icons.camera_alt, size: 18),
//                 label: const Text('Pertanggungjawaban'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.yellow[700],
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   elevation: 0,
//                 ),
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.info_outline, color: Colors.orange, size: 16),
//                   SizedBox(width: 6),
//                   Expanded(
//                     child: Text(
//                       'Jika tidak melakukan pertanggungjawaban > 3 hari setelah menggunakan ruang, maka peminjam tidak akan bisa meminjam ruangan kembali di kemudian hari.',
//                       style: TextStyle(color: Colors.orange, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         );

//       case 'done':
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.green[100],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: const Text(
//             'Selesai',
//             style: TextStyle(color: Color(0xFF4DD18B), fontWeight: FontWeight.w600),
//           ),
//         );

//       default:
//         return Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.grey[100],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Text(
//             b.status.toUpperCase(),
//             style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
//           ),
//         );
//     }
//   }
// }

// // Halaman pertanggungjawaban (upload foto before-after)
// class PertanggungjawabanScreen extends StatefulWidget {
//   final Booking booking;
//   const PertanggungjawabanScreen({super.key, required this.booking});

//   @override
//   State<PertanggungjawabanScreen> createState() => _PertanggungjawabanScreenState();
// }

// class _PertanggungjawabanScreenState extends State<PertanggungjawabanScreen> {
//   XFile? beforePhoto;
//   XFile? afterPhoto;
//   bool loading = false;

//   Future<void> pickPhoto(bool isBefore) async {
//     try {
//       final picker = ImagePicker();
//       final XFile? photo = await picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//         maxWidth: 1024,
//         maxHeight: 1024,
//       );
      
//       if (photo != null) {
//         setState(() {
//           if (isBefore) {
//             beforePhoto = photo;
//           } else {
//             afterPhoto = photo;
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Gagal mengambil foto: $e')),
//       );
//     }
//   }

//   Future<void> submit() async {
//     if (beforePhoto == null || afterPhoto == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Foto before & after harus diisi!')),
//       );
//       return;
//     }
    
//     setState(() => loading = true);
    
//     try {
//       // Check if uploadPertanggungjawaban method exists, otherwise use alternative approach
//       if (ApiService().toString().contains('uploadPertanggungjawaban')) {
//         // Use the existing method if available
//         await ApiService.uploadPertanggungjawaban(
//           bookingId: widget.booking.id,
//           beforePhoto: beforePhoto!,
//           afterPhoto: afterPhoto!,
//         );
//       } else {
//         // Alternative approach: upload after photo for checkout
//         // This assumes the after photo is what's needed for checkout
//         final afterPhotoUrl = await ApiService.uploadPhoto(
//           widget.booking.id, 
//           afterPhoto!, 
//           type: 'after'
//         );
        
//         // Use checkout API with the after photo URL
//         await ApiService.checkout(widget.booking.id, afterPhotoUrl);
//       }
      
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Pertanggungjawaban berhasil dikirim'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.pop(context, true);
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal mengirim pertanggungjawaban: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() => loading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Pertanggungjawaban'),
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(24.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Header info
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.blue[50],
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Ruangan: ${widget.booking.roomName}',
//                     style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     'Tanggal: ${DateFormat('dd MMM yyyy').format(widget.booking.bookingDate)}',
//                     style: const TextStyle(color: Colors.grey),
//                   ),
//                 ],
//               ),
//             ),
            
//             const SizedBox(height: 24),
            
//             const Text(
//               'Upload foto before & after ruangan',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Ambil foto kondisi ruangan sebelum dan sesudah digunakan',
//               style: TextStyle(color: Colors.grey),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Photo selection area
//             Row(
//               children: [
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => pickPhoto(true),
//                     child: Container(
//                       height: 160,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: beforePhoto != null ? Colors.green : Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[50],
//                         image: beforePhoto != null
//                           ? DecorationImage(
//                               image: FileImage(File(beforePhoto!.path)), 
//                               fit: BoxFit.cover
//                             )
//                           : null,
//                       ),
//                       child: beforePhoto == null
//                         ? Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.camera_alt, size: 32, color: Colors.grey[600]),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Foto Before',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Tap untuk foto',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.black.withOpacity(0.3),
//                             ),
//                             child: const Center(
//                               child: Icon(
//                                 Icons.check_circle,
//                                 color: Colors.white,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: GestureDetector(
//                     onTap: () => pickPhoto(false),
//                     child: Container(
//                       height: 160,
//                       decoration: BoxDecoration(
//                         border: Border.all(color: afterPhoto != null ? Colors.green : Colors.grey[300]!),
//                         borderRadius: BorderRadius.circular(12),
//                         color: Colors.grey[50],
//                         image: afterPhoto != null
//                           ? DecorationImage(
//                               image: FileImage(File(afterPhoto!.path)), 
//                               fit: BoxFit.cover
//                             )
//                           : null,
//                       ),
//                       child: afterPhoto == null
//                         ? Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(Icons.camera_alt, size: 32, color: Colors.grey[600]),
//                               const SizedBox(height: 8),
//                               Text(
//                                 'Foto After',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.grey[700],
//                                 ),
//                               ),
//                               const SizedBox(height: 4),
//                               Text(
//                                 'Tap untuk foto',
//                                 style: TextStyle(
//                                   fontSize: 12,
//                                   color: Colors.grey[500],
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Container(
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(12),
//                               color: Colors.black.withOpacity(0.3),
//                             ),
//                             child: const Center(
//                               child: Icon(
//                                 Icons.check_circle,
//                                 color: Colors.white,
//                                 size: 32,
//                               ),
//                             ),
//                           ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
            
//             const Spacer(),
            
//             // Submit button
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: loading ? null : submit,
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF192965),
//                   foregroundColor: Colors.white,
//                   padding: const EdgeInsets.symmetric(vertical: 16),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   elevation: 0,
//                 ),
//                 child: loading
//                   ? const SizedBox(
//                       height: 20,
//                       width: 20,
//                       child: CircularProgressIndicator(
//                         color: Colors.white,
//                         strokeWidth: 2,
//                       ),
//                     )
//                   : const Text(
//                       'Kirim Pertanggungjawaban',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }






import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'dart:io';

class PeminjamanScreen extends StatefulWidget {
  final int currentUserId;
  const PeminjamanScreen({super.key, required this.currentUserId});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> {
  String selectedTab = 'pending'; // default: Pengajuan
  List<Booking> _bookings = [];
  bool _isLoading = false;

  final tabMap = {
    'pending': 'Pengajuan',
    'approved': 'Disetujui',
    'in_use': 'Pemakaian',
    'done': 'Selesai',
  };

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await ApiService.getBookings();
      setState(() {
        _bookings = bookings.where((b) => b.userId == widget.currentUserId).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
      }
    }
  }

  Future<void> _refreshBookings() async {
    await _loadBookings();
  }

  // lokasi ruangan dari booking
  String _getBookingLocation(Booking booking) {
    final json = booking.toJson();
    if (json.containsKey('roomLocation')) {
      return json['roomLocation'] ?? 'Lokasi tidak tersedia';
    } else if (json.containsKey('room_location')) {
      return json['room_location'] ?? 'Lokasi tidak tersedia';
    } else if (json.containsKey('location')) {
      return json['location'] ?? 'Lokasi tidak tersedia';
    }
    return 'Lokasi tidak tersedia';
  }

  //  koordinat ruangan
  double? _getBookingLatitude(Booking booking) {
    final json = booking.toJson();
    if (json.containsKey('roomLatitude')) {
      return json['roomLatitude']?.toDouble();
    } else if (json.containsKey('room_latitude')) {
      return json['room_latitude']?.toDouble();
    } else if (json.containsKey('latitude')) {
      return json['latitude']?.toDouble();
    }
    return null;
  }

  double? _getBookingLongitude(Booking booking) {
    final json = booking.toJson();
    if (json.containsKey('roomLongitude')) {
      return json['roomLongitude']?.toDouble();
    } else if (json.containsKey('room_longitude')) {
      return json['room_longitude']?.toDouble();
    } else if (json.containsKey('longitude')) {
      return json['longitude']?.toDouble();
    }
    return null;
  }

  Future<void> _konfirmasiKehadiran(Booking b) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nyalakan layanan lokasi')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Akses lokasi diperlukan untuk konfirmasi kehadiran')),
          );
          return;
        }
      }

      Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      double roomLat = _getBookingLatitude(b) ?? -8.165922026829602;
      double roomLng = _getBookingLongitude(b) ?? 113.7168622702779; //-8.165922026829602, 113.7168622702779
      double distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, roomLat, roomLng);

      if (distance <= 980) {
        // konfirmasi kehadiran
        await ApiService.confirmAttendance(
          b.id,
          "${pos.latitude},${pos.longitude}",
        );
        
        // Refresh data
        await _refreshBookings();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kehadiran berhasil dikonfirmasi!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anda belum berada di lokasi ruangan! Jarak: ${distance.toInt()}m'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _openPertanggungjawaban(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PertanggungjawabanScreen(booking: booking),
      ),
    );
    if (result == true) {
      _refreshBookings(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/user/home',
              (route) => false,
            );
          },
        ),
        title: const Text('Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Tab Bar
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: tabMap.entries.map((e) {
                final selected = selectedTab == e.key;
                return GestureDetector(
                  onTap: () => setState(() => selectedTab = e.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    decoration: BoxDecoration(
                      color: selected ? Colors.white : Colors.grey[100],
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: selected
                          ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
                          : [],
                    ),
                    child: Text(
                      e.value,
                      style: TextStyle(
                        color: selected ? const Color(0xFF192965) : Colors.black38,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Content
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshBookings,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildBookingsList(),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7FA),
    );
  }

  Widget _buildBookingsList() {
    final filteredBookings = _bookings.where((b) => b.status == selectedTab).toList();
    
    if (filteredBookings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_note,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada peminjaman ${tabMap[selectedTab]?.toLowerCase()}',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _refreshBookings,
              icon: const Icon(Icons.refresh),
              label: const Text('Muat Ulang'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: filteredBookings.length,
      itemBuilder: (context, i) => _bookingCard(context, filteredBookings[i]),
    );
  }

  Widget _bookingCard(BuildContext context, Booking b) {
    String formatTime(String time) {
      try {
        if (time.contains(':')) {
          final t = TimeOfDay(
            hour: int.parse(time.split(':')[0]),
            minute: int.parse(time.split(':')[1]),
          );
          final h = t.hour.toString().padLeft(2, '0');
          final m = t.minute.toString().padLeft(2, '0');
          return '$h.$m';
        }
        if (time.contains('AM') || time.contains('PM')) {
          final dt = DateFormat.jm().parse(time);
          return DateFormat('HH.mm').format(dt);
        }
        return time;
      } catch (e) {
        return time;
      }
    }

    // Get room photo URL with fallback
    String getPhotoUrl() {
      if (b.roomPhotoUrl != null && b.roomPhotoUrl!.isNotEmpty) {
        return b.roomPhotoUrl!;
      }
      return 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Foto ruangan
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.network(
                  getPhotoUrl(),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.grey[300],
                    child: Icon(Icons.meeting_room, color: Colors.grey[600]),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Info booking
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      b.roomName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.location_on_rounded, size: 16, color: Colors.black26),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            _getBookingLocation(b),
                            style: const TextStyle(color: Colors.black45, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 18, color: Colors.black45),
                        const SizedBox(width: 6),
                        Text(
                          DateFormat('dd MMM yyyy').format(b.bookingDate),
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, size: 18, color: Colors.black45),
                        const SizedBox(width: 6),
                        Text(
                          '${formatTime(b.startTime)}–${formatTime(b.endTime)} WIB',
                          style: const TextStyle(fontSize: 15, color: Colors.black87),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.description, size: 16, color: Colors.black45),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            b.purpose,
                            style: const TextStyle(color: Colors.black45, fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Status badge & tombol aksi
          _buildStatusContent(b),
        ],
      ),
    );
  }

  Widget _buildStatusContent(Booking b) {
    switch (b.status) {
      case 'pending':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Menunggu Persetujuan',
            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600),
          ),
        );

      case 'approved':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _konfirmasiKehadiran(b),
                icon: const Icon(Icons.location_on, size: 18),
                label: const Text('Konfirmasi Kehadiran'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.blue, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Jika tidak melakukan konfirmasi kehadiran > 1 jam dari jadwal, maka peminjaman otomatis dianggap dibatalkan.',
                      style: TextStyle(color: Colors.blue, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'in_use':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openPertanggungjawaban(b),
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Pertanggungjawaban'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.yellow[700],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.orange, size: 16),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Jika tidak melakukan pertanggungjawaban > 3 hari setelah menggunakan ruang, maka peminjam tidak akan bisa meminjam ruangan kembali di kemudian hari.',
                      style: TextStyle(color: Colors.orange, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );

      case 'done':
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'Selesai',
            style: TextStyle(color: Color(0xFF4DD18B), fontWeight: FontWeight.w600),
          ),
        );

      default:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            b.status.toUpperCase(),
            style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
          ),
        );
    }
  }
}

// ✅ HALAMAN PERTANGGUNGJAWABAN - CAMERA ONLY FIXED
class PertanggungjawabanScreen extends StatefulWidget {
  final Booking booking;
  const PertanggungjawabanScreen({super.key, required this.booking});

  @override
  State<PertanggungjawabanScreen> createState() => _PertanggungjawabanScreenState();
}

class _PertanggungjawabanScreenState extends State<PertanggungjawabanScreen> {
  XFile? photo;
  bool loading = false;

  Future<void> pickPhotoFromCamera() async {
    try {
      final picker = ImagePicker();
      
      // ✅ Konfirmasi sebelum membuka kamera
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Foto Ruangan'),
            content: const Text('Ambil foto kondisi ruangan setelah digunakan?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Buka Kamera'),
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      // ✅ Buka kamera langsung
      final XFile? capturedPhoto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      if (capturedPhoto != null) {
        setState(() {
          photo = capturedPhoto;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto berhasil diambil'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil foto: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> submit() async {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto harus diisi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Kirim pertanggungjawaban sekarang?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton(
              child: const Text('Kirim'),
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192965),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    
    setState(() => loading = true);
    
    try {
      await ApiService.uploadPertanggungjawaban(
        bookingId: widget.booking.id,
        photo: photo!,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pertanggungjawaban berhasil dikirim'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim pertanggungjawaban: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pertanggungjawaban'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ruangan: ${widget.booking.roomName}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tanggal: ${DateFormat('dd MMM yyyy').format(widget.booking.bookingDate)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            const Text(
              'Ambil foto ruangan setelah digunakan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              'Gunakan kamera untuk mengambil foto kondisi ruangan setelah digunakan',
              style: TextStyle(color: Colors.grey),
            ),
            
            const SizedBox(height: 24),
            
            // Photo area
            GestureDetector(
              onTap: pickPhotoFromCamera,
              child: Center(
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: photo != null ? Colors.green : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[50],
                    image: photo != null
                      ? DecorationImage(
                          image: FileImage(File(photo!.path)), 
                          fit: BoxFit.cover
                        )
                      : null,
                  ),
                  child: photo == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey[600]),
                          const SizedBox(height: 16),
                          Text(
                            'Ambil Foto',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk membuka kamera',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 48,
                          ),
                        ),
                      ),
                ),
              ),
            ),
            
            // Info tambahan
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, color: Colors.amber, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Pastikan foto jelas dan kondisi ruangan terlihat dengan baik',
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Kirim Pertanggungjawaban',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}