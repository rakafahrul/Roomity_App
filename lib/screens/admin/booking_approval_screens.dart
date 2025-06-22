// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/services/api_service.dart';
// import 'package:rom_app/screens/admin/navbar_admin.dart';

// class AdminPeminjamanScreen extends StatefulWidget {
//   const AdminPeminjamanScreen({super.key});

//   @override
//   State<AdminPeminjamanScreen> createState() => _AdminPeminjamanScreenState();
// }

// class _AdminPeminjamanScreenState extends State<AdminPeminjamanScreen> {
//   String selectedTab = 'pending'; // Default: Pengajuan
//   final TextEditingController _catatanController = TextEditingController();
//   List<Booking> _bookings = [];
//   bool _isLoading = false;

//   final Map<String, String> tabMap = {
//     'pending': 'Pengajuan',
//     'in_use': 'Foto',
//     'done': 'Selesai',
//   };

//   @override
//   void initState() {
//     super.initState();
//     _loadBookings();
//   }

//   @override
//   void dispose() {
//     _catatanController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBookings() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final bookings = await ApiService.getBookings();
//       setState(() {
//         _bookings = bookings;
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

//   // =================== MENU PENGAJUAN (TAB 1) ===================

//   Future<void> _approveBooking(int bookingId) async {
//     try {
//       bool success = await ApiService.approveBooking(bookingId, "Disetujui oleh admin");
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Peminjaman berhasil disetujui'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         throw Exception('Gagal menyetujui peminjaman');
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

//   Future<void> _rejectBooking(int bookingId, String reason) async {
//     try {
//       bool success = await ApiService.rejectBooking(bookingId, reason);
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Peminjaman ditolak'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       } else {
//         throw Exception('Gagal menolak peminjaman');
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

//   Future<void> _showRejectionDialog(Booking booking) async {
//     _catatanController.clear();
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Tolak Peminjaman'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Peminjaman: ${booking.roomName}'),
//             const SizedBox(height: 8),
//             Text('Peminjam: ${_getBookingUserName(booking)}'),
//             const SizedBox(height: 16),
//             const Text('Masukkan alasan penolakan:'),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _catatanController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Alasan penolakan...',
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_catatanController.text.trim().isNotEmpty) {
//                 _rejectBooking(booking.id, _catatanController.text.trim());
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Mohon masukkan alasan penolakan')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
//             child: const Text('Tolak', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // =================== MENU FOTO (TAB 2) ===================

//   Future<void> _markAsCompleted(int bookingId) async {
//     try {
//       bool success = await ApiService.completeBooking(bookingId);
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Peminjaman berhasil diselesaikan'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         throw Exception('Gagal menyelesaikan peminjaman');
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

//   Future<void> _reportIssue(int bookingId, String issue) async {
//     try {
//       bool success = await ApiService.addAdminNote(bookingId, issue);
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Catatan masalah berhasil dikirim ke peminjam'),
//               backgroundColor: Colors.orange,
//             ),
//           );
//         }
//       } else {
//         throw Exception('Gagal mengirim catatan masalah');
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

//   Future<void> _markIssueResolved(int bookingId) async {
//     try {
//       bool success = await ApiService.resolveIssue(bookingId);
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Masalah ditandai sebagai terselesaikan'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         throw Exception('Gagal menandai masalah sebagai terselesaikan');
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

//   Future<void> _showIssueDialog(Booking booking) async {
//     _catatanController.clear();
//     await showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Laporkan Masalah'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Ruangan: ${booking.roomName}'),
//             const SizedBox(height: 8),
//             Text('Peminjam: ${_getBookingUserName(booking)}'),
//             const SizedBox(height: 16),
//             const Text('Masukkan deskripsi masalah untuk peminjam:'),
//             const SizedBox(height: 10),
//             TextField(
//               controller: _catatanController,
//               decoration: const InputDecoration(
//                 border: OutlineInputBorder(),
//                 hintText: 'Deskripsi masalah yang harus diperbaiki...',
//               ),
//               maxLines: 3,
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (_catatanController.text.trim().isNotEmpty) {
//                 _reportIssue(booking.id, _catatanController.text.trim());
//                 Navigator.pop(context);
//               } else {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Mohon masukkan deskripsi masalah')),
//                 );
//               }
//             },
//             style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
//             child: const Text('Kirim Catatan', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );
//   }

//   // =================== MENU SELESAI (TAB 3) ===================

//   Future<void> _showApprovalHistoryDialog(int bookingId) async {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('Riwayat Persetujuan'),
//           content: FutureBuilder<List<Approval>>(
//             future: ApiService.getApprovals(bookingId),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (snapshot.hasError) {
//                 return Text('Gagal memuat data: ${snapshot.error}');
//               }
//               final approvals = snapshot.data ?? [];
//               if (approvals.isEmpty) {
//                 return const Text('Belum ada riwayat persetujuan');
//               }
//               return SizedBox(
//                 width: double.maxFinite,
//                 child: ListView.builder(
//                   shrinkWrap: true,
//                   itemCount: approvals.length,
//                   itemBuilder: (context, i) {
//                     final a = approvals[i];
//                     return ListTile(
//                       leading: const Icon(Icons.check_circle_outline),
//                       title: Text(a.approver),
//                       subtitle: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(a.note),
//                           Text(
//                             DateFormat('dd MMM yyyy – HH:mm').format(a.date),
//                             style: const TextStyle(fontSize: 12, color: Colors.grey),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: const Text('Tutup'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // =================== HELPER METHODS ===================

//   String _getBookingUserName(Booking booking) {
//     // Coba berbagai kemungkinan property untuk username
//     if (booking.toJson().containsKey('userName')) {
//       return booking.toJson()['userName'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('user_name')) {
//       return booking.toJson()['user_name'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('userDisplayName')) {
//       return booking.toJson()['userDisplayName'] ?? 'Peminjam tidak diketahui';
//     }
//     return 'Peminjam tidak diketahui';
//   }

//   String? _getBookingAdminNotes(Booking booking) {
//     // Coba berbagai kemungkinan property untuk admin notes
//     final json = booking.toJson();
//     if (json.containsKey('adminNotes')) {
//       return json['adminNotes'];
//     } else if (json.containsKey('admin_notes')) {
//       return json['admin_notes'];
//     } else if (json.containsKey('notes')) {
//       return json['notes'];
//     }
//     return null;
//   }

//   String? _getBookingAfterPhotoUrl(Booking booking) {
//     // Coba berbagai kemungkinan property untuk after photo
//     final json = booking.toJson();
//     if (json.containsKey('afterPhotoUrl')) {
//       return json['afterPhotoUrl'];
//     } else if (json.containsKey('after_photo_url')) {
//       return json['after_photo_url'];
//     } else if (json.containsKey('roomPhotoAfterUrl')) {
//       return json['roomPhotoAfterUrl'];
//     }
//     return null;
//   }

//   DateTime _getBookingUpdatedAt(Booking booking) {
//     // Coba berbagai kemungkinan property untuk updated at
//     final json = booking.toJson();
//     try {
//       if (json.containsKey('updatedAt')) {
//         return DateTime.parse(json['updatedAt']);
//       } else if (json.containsKey('updated_at')) {
//         return DateTime.parse(json['updated_at']);
//       } else if (json.containsKey('modifiedAt')) {
//         return DateTime.parse(json['modifiedAt']);
//       }
//     } catch (e) {
//       // Jika gagal parse, gunakan createdAt atau tanggal sekarang
//     }
    
//     // Fallback ke createdAt atau tanggal sekarang
//     try {
//       if (json.containsKey('createdAt')) {
//         return DateTime.parse(json['createdAt']);
//       } else if (json.containsKey('created_at')) {
//         return DateTime.parse(json['created_at']);
//       }
//     } catch (e) {
//       return DateTime.now();
//     }
//     return DateTime.now();
//   }

//   // =================== UI COMPONENTS ===================

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Manajemen Peminjaman', style: TextStyle(fontWeight: FontWeight.bold)),
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
//                   : _buildTabContent(),
//             ),
//           ),
//         ],
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//       bottomNavigationBar: const NavBar(currentIndex: 1), // Index 1 untuk Peminjaman
//     );
//   }

//   Widget _buildTabContent() {
//     final filteredBookings = _bookings.where((b) {
//       switch (selectedTab) {
//         case 'pending':
//           return b.status == 'pending';
//         case 'in_use':
//           return b.status == 'in_use' || b.status == 'approved';
//         case 'done':
//           return b.status == 'done';
//         default:
//           return false;
//       }
//     }).toList();

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
//               'Tidak ada data peminjaman ${tabMap[selectedTab]?.toLowerCase()}',
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
//           return '${t.hour.toString().padLeft(2, '0')}.${t.minute.toString().padLeft(2, '0')}';
//         }
//         return time;
//       } catch (e) {
//         return time;
//       }
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
//                   b.roomPhotoUrl ?? 'https://via.placeholder.com/150',
//                   width: 90,
//                   height: 90,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 90,
//                     height: 90,
//                     color: Colors.grey[300],
//                     child: const Icon(Icons.meeting_room, color: Colors.grey),
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
//                         const Icon(Icons.person, size: 16, color: Colors.black26),
//                         const SizedBox(width: 4),
//                         Text(
//                           _getBookingUserName(b),
//                           style: const TextStyle(color: Colors.black45, fontSize: 14),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.calendar_today, size: 18, color: Colors.black45),
//                         const SizedBox(width: 6),
//                         Text(
//                           DateFormat('dd MMM yyyy').format(b.bookingDate),
//                           style: const TextStyle(fontSize: 15, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                     Row(
//                       children: [
//                         const Icon(Icons.access_time, size: 18, color: Colors.black45),
//                         const SizedBox(width: 6),
//                         Text(
//                           '${formatTime(b.startTime)} - ${formatTime(b.endTime)}',
//                           style: const TextStyle(fontSize: 15, color: Colors.black87),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 8),
//                     Row(
//                       children: [
//                         const Icon(Icons.description, size: 18, color: Colors.black45),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             b.purpose,
//                             style: const TextStyle(fontSize: 14, color: Colors.black87),
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
          
//           // Konten spesifik berdasarkan tab
//           if (selectedTab == 'pending') _buildPendingActions(b),
//           if (selectedTab == 'in_use') _buildInUseContent(b),
//           if (selectedTab == 'done') _buildDoneContent(b),
          
//           // Admin notes (jika ada)
//           if (_getBookingAdminNotes(b) != null && _getBookingAdminNotes(b)!.isNotEmpty) ...[
//             const SizedBox(height: 12),
//             Container(
//               padding: const EdgeInsets.all(10),
//               decoration: BoxDecoration(
//                 color: Colors.orange[50],
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(color: Colors.orange[200]!),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.orange[700], size: 18),
//                       const SizedBox(width: 6),
//                       Text(
//                         'Catatan Admin:',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold, 
//                           color: Colors.orange[700],
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     _getBookingAdminNotes(b)!,
//                     style: TextStyle(color: Colors.orange[800]),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }

//   // =================== TAB SPECIFIC CONTENT ===================

//   Widget _buildPendingActions(Booking b) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//       children: [
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _showRejectionDialog(b),
//             icon: const Icon(Icons.close, size: 18),
//             label: const Text('Tolak'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//         const SizedBox(width: 10),
//         Expanded(
//           child: ElevatedButton.icon(
//             onPressed: () => _approveBooking(b.id),
//             icon: const Icon(Icons.check, size: 18),
//             label: const Text('Setujui'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildInUseContent(Booking b) {
//     final afterPhotoUrl = _getBookingAfterPhotoUrl(b);
//     final adminNotes = _getBookingAdminNotes(b);
    
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Status badge
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: b.status == 'approved' ? Colors.blue[50] : Colors.purple[50],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 b.status == 'approved' ? Icons.check_circle : Icons.schedule,
//                 color: b.status == 'approved' ? Colors.blue : Colors.purple,
//                 size: 18,
//               ),
//               const SizedBox(width: 6),
//               Text(
//                 b.status == 'approved' ? 'Siap Digunakan' : 'Sedang Digunakan',
//                 style: TextStyle(
//                   color: b.status == 'approved' ? Colors.blue : Colors.purple,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 12),
        
//         // Photo section
//         if (afterPhotoUrl == null) ...[
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.grey[100],
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: [
//                 Icon(Icons.photo_camera, color: Colors.grey[600]),
//                 const SizedBox(width: 8),
//                 Text(
//                   'Menunggu foto ruangan setelah digunakan',
//                   style: TextStyle(
//                     color: Colors.grey[600],
//                     fontStyle: FontStyle.italic,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ] else ...[
//           const Text(
//             'Foto Ruangan Setelah Dipakai:',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//           ),
//           const SizedBox(height: 8),
//           GestureDetector(
//             onTap: () => _showFullImage(afterPhotoUrl),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(12),
//               child: Image.network(
//                 afterPhotoUrl,
//                 height: 120,
//                 width: double.infinity,
//                 fit: BoxFit.cover,
//                 errorBuilder: (context, error, stackTrace) => Container(
//                   height: 120,
//                   width: double.infinity,
//                   color: Colors.grey[300],
//                   child: const Icon(Icons.error_outline, color: Colors.red),
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
          
//           // Action buttons for photo review
//           Row(
//             children: [
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _showIssueDialog(b),
//                   icon: const Icon(Icons.report_problem, size: 18),
//                   label: const Text('Ada Masalah'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.orange,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 10),
//               Expanded(
//                 child: ElevatedButton.icon(
//                   onPressed: () => _markAsCompleted(b.id),
//                   icon: const Icon(Icons.check_circle, size: 18),
//                   label: const Text('Selesai'),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.green,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                 ),
//               ),
//             ],
//           ),
          
//           // Issue resolution button (if there are admin notes indicating issues)
//           if (adminNotes != null && adminNotes.isNotEmpty) ...[
//             const SizedBox(height: 10),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton.icon(
//                 onPressed: () => _markIssueResolved(b.id),
//                 icon: const Icon(Icons.done_all, size: 18),
//                 label: const Text('Masalah Terselesaikan'),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   foregroundColor: Colors.white,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ],
//     );
//   }

//   Widget _buildDoneContent(Booking b) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Completion status
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//           decoration: BoxDecoration(
//             color: Colors.green[50],
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Row(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const Icon(Icons.check_circle, color: Colors.green, size: 18),
//               const SizedBox(width: 6),
//               Text(
//                 'Selesai pada ${DateFormat('dd MMM yyyy').format(_getBookingUpdatedAt(b))}',
//                 style: const TextStyle(
//                   color: Colors.green,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//             ],
//           ),
//         ),
        
//         const SizedBox(height: 12),
        
//         // History button
//         SizedBox(
//           width: double.infinity,
//           child: TextButton.icon(
//             onPressed: () => _showApprovalHistoryDialog(b.id),
//             icon: const Icon(Icons.history, color: Colors.blue),
//             label: const Text(
//               'Lihat Riwayat Persetujuan',
//               style: TextStyle(color: Colors.blue),
//             ),
//             style: TextButton.styleFrom(
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12),
//                 side: const BorderSide(color: Colors.blue),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 12),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   void _showFullImage(String imageUrl) {
//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: InteractiveViewer(
//           panEnabled: true,
//           minScale: 0.5,
//           maxScale: 3.0,
//           child: Image.network(
//             imageUrl,
//             errorBuilder: (context, error, stackTrace) => const Center(
//               child: Text(
//                 'Gagal memuat gambar',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/services/api_service.dart';
// import 'package:rom_app/screens/admin/navbar_admin.dart';

// class AdminPeminjamanScreen extends StatefulWidget {
//   const AdminPeminjamanScreen({super.key});

//   @override
//   State<AdminPeminjamanScreen> createState() => _AdminPeminjamanScreenState();
// }

// class _AdminPeminjamanScreenState extends State<AdminPeminjamanScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   List<Booking> _bookings = [];
//   bool _isLoading = false;

//   final List<String> _tabs = ['Pengajuan', 'Foto', 'Masalah', 'Selesai'];
//   final List<String> _statusMap = ['pending', 'approved', 'in_use', 'done']; //pending, in_use, reported,done

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _loadBookings();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBookings() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final bookings = await ApiService.getBookings();
//       setState(() {
//         _bookings = bookings;
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

//   String _getBookingUserName(Booking booking) {
//     if (booking.toJson().containsKey('userName')) {
//       return booking.toJson()['userName'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('user_name')) {
//       return booking.toJson()['user_name'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('userDisplayName')) {
//       return booking.toJson()['userDisplayName'] ?? 'Peminjam tidak diketahui';
//     }
//     return 'Peminjam tidak diketahui';
//   }

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

//   void _showBookingDetail(Booking booking) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BookingDetailScreen(booking: booking),
//       ),
//     ).then((_) => _refreshBookings());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Peminjaman',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//           labelColor: const Color(0xFF192965),
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: const Color(0xFF192965),
//           indicatorWeight: 3,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _tabs.asMap().entries.map((entry) {
//           final index = entry.key;
//           final status = _statusMap[index];
//           return _buildBookingList(status);
//         }).toList(),
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//       bottomNavigationBar: const NavBar(currentIndex: 1),
//     );
//   }

//   Widget _buildBookingList(String status) {
//     return RefreshIndicator(
//       onRefresh: _refreshBookings,
//       child: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildBookingContent(status),
//     );
//   }

//   Widget _buildBookingContent(String status) {
//     final filteredBookings = _bookings.where((b) => b.status == status).toList();

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
//               'Belum ada peminjaman',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: filteredBookings.length,
//       itemBuilder: (context, index) {
//         return _buildBookingCard(filteredBookings[index]);
//       },
//     );
//   }

//   Widget _buildBookingCard(Booking booking) {
//     String formatTime(String time) {
//       try {
//         if (time.contains(':')) {
//           final parts = time.split(':');
//           final hour = int.parse(parts[0]);
//           final minute = int.parse(parts[1]);
//           return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
//         }
//         return time;
//       } catch (e) {
//         return time;
//       }
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () => _showBookingDetail(booking),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 // Room Image
//                 ClipRRect(
//                   borderRadius: BorderRadius.circular(12),
//                   // ===== PERUBAHAN DIMULAI DI SINI =====
//                   child: (booking.roomPhotoUrl != null && booking.roomPhotoUrl!.isNotEmpty)
//                       ? Image.network( // Jika URL ada
//                           booking.roomPhotoUrl!,
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                           errorBuilder: (context, error, stackTrace) => Container(
//                             width: 80,
//                             height: 80,
//                             color: Colors.grey[300],
//                             child: Icon(Icons.meeting_room, color: Colors.grey[600]),
//                           ),
//                         )
//                       : Image.asset( // Jika URL null atau kosong
//                           'assets/images/default.jpeg',
//                           width: 80,
//                           height: 80,
//                           fit: BoxFit.cover,
//                         ),
//                   // ===== PERUBAHAN SELESAI DI SINI =====
//                 ),
//                 const SizedBox(width: 16),
                
//                 // Booking Info
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         booking.roomName,
//                         style: const TextStyle(
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       const SizedBox(height: 4),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.location_on_rounded,
//                             size: 14,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 4),
//                           Expanded(
//                             child: Text(
//                               _getBookingLocation(booking),
//                               style: TextStyle(
//                                 color: Colors.grey[600],
//                                 fontSize: 12,
//                               ),
//                               overflow: TextOverflow.ellipsis,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_today,
//                             size: 14,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             DateFormat('dd MMM yyyy').format(booking.bookingDate),
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 2),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.access_time,
//                             size: 14,
//                             color: Colors.grey[600],
//                           ),
//                           const SizedBox(width: 4),
//                           Text(
//                             '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)} WIB',
//                             style: TextStyle(
//                               color: Colors.grey[700],
//                               fontSize: 12,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
                
//                 // Status or Action Indicator
//                 Icon(
//                   Icons.chevron_right,
//                   color: Colors.grey[400],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class BookingDetailScreen extends StatefulWidget {
//   final Booking booking;

//   const BookingDetailScreen({super.key, required this.booking});

//   @override
//   State<BookingDetailScreen> createState() => _BookingDetailScreenState();
// }

// class _BookingDetailScreenState extends State<BookingDetailScreen> {
//   bool _isLoading = false;

//   String _getBookingUserName(Booking booking) {
//     if (booking.toJson().containsKey('userName')) {
//       return booking.toJson()['userName'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('user_name')) {
//       return booking.toJson()['user_name'] ?? 'Peminjam tidak diketahui';
//     } else if (booking.toJson().containsKey('userDisplayName')) {
//       return booking.toJson()['userDisplayName'] ?? 'Peminjam tidak diketahui';
//     }
//     return 'Peminjam tidak diketahui';
//   }

//   String _getBookingLocation(Booking booking) {
//     final json = booking.toJson();
//     if (json.containsKey('roomLocation')) {
//       return json['roomLocation'] ?? 'Gedung 24A, Ilmu Komputer';
//     } else if (json.containsKey('room_location')) {
//       return json['room_location'] ?? 'Gedung 24A, Ilmu Komputer';
//     } else if (json.containsKey('location')) {
//       return json['location'] ?? 'Gedung 24A, Ilmu Komputer';
//     }
//     return 'Gedung 24A, Ilmu Komputer';
//   }

//   String _getBookingEmail(Booking booking) {
//     final json = booking.toJson();
//     if (json.containsKey('userEmail')) {
//       return json['userEmail'] ?? '232410102000@mail.unej.ac.id';
//     } else if (json.containsKey('user_email')) {
//       return json['user_email'] ?? '232410102000@mail.unej.ac.id';
//     } else if (json.containsKey('email')) {
//       return json['email'] ?? '232410102000@mail.unej.ac.id';
//     }
//     return '232410102000@mail.unej.ac.id';
//   }

//   Future<void> _approveBooking() async {
//     setState(() => _isLoading = true);
//     try {
//       bool success = await ApiService.approveBooking(widget.booking.id, "Disetujui oleh admin");
//       if (success) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Booking berhasil disetujui'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal menyetujui booking: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _rejectBooking() async {
//     final reasonController = TextEditingController();
    
//     final reason = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text('Alasan Penolakan'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Berikan alasan penolakan peminjaman:'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: reasonController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'Masukkan alasan penolakan...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.all(12),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (reasonController.text.trim().isNotEmpty) {
//                 Navigator.pop(context, reasonController.text.trim());
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Tolak', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (reason != null && reason.isNotEmpty) {
//       setState(() => _isLoading = true);
//       try {
//         bool success = await ApiService.rejectBooking(widget.booking.id, reason);
//         if (success) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Booking berhasil ditolak'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             Navigator.pop(context);
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Gagal menolak booking: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   String formatTime(String time) {
//     try {
//       if (time.contains(':')) {
//         final parts = time.split(':');
//         final hour = int.parse(parts[0]);
//         final minute = int.parse(parts[1]);
//         return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
//       }
//       return time;
//     } catch (e) {
//       return time;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Persetujuan',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Room Info Card
//             Container(
//               margin: const EdgeInsets.all(20),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     // ===== PERUBAHAN DIMULAI DI SINI =====
//                     child: (widget.booking.roomPhotoUrl != null && widget.booking.roomPhotoUrl!.isNotEmpty)
//                         ? Image.network( // Jika URL ada
//                             widget.booking.roomPhotoUrl!,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) => Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey[300],
//                               child: Icon(Icons.meeting_room, color: Colors.grey[600]),
//                             ),
//                           )
//                         : Image.asset( // Jika URL null atau kosong
//                             'assets/images/default.jpeg',
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                           ),
//                     // ===== PERUBAHAN SELESAI DI SINI =====
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.booking.roomName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_rounded,
//                               size: 16,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 _getBookingLocation(widget.booking),
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.orange[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             '50 Orang',
//                             style: TextStyle(
//                               color: Colors.orange[700],
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Detail Peminjaman
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildDetailRow(
//                     icon: Icons.calendar_today,
//                     label: 'Tanggal',
//                     value: DateFormat('dd MMM yyyy').format(widget.booking.bookingDate),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.person,
//                     label: 'Peminjam',
//                     value: _getBookingUserName(widget.booking),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.access_time,
//                     label: 'Jam',
//                     value: '${formatTime(widget.booking.startTime)} - ${formatTime(widget.booking.endTime)} WIB',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.email,
//                     label: 'Email',
//                     value: _getBookingEmail(widget.booking),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Alasan Peminjaman
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Alasan Peminjaman',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     widget.booking.purpose,
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Alasan Penolakan (if rejected)
//             if (widget.booking.status == 'rejected') ...[
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Alasan Penolakan',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     const Text(
//                       'Dan hanya jika permintaan ditolak.',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // Action Buttons - Only show for pending status
//             if (widget.booking.status == 'pending') ...[
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _isLoading ? null : _rejectBooking,
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red, width: 2),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'Ditolak',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _approveBooking,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF192965),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text(
//                                 'Disetujui',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//     );
//   }

//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }





// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/services/api_service.dart';
// import 'package:rom_app/screens/admin/navbar_admin.dart';

// class AdminPeminjamanScreen extends StatefulWidget {
//   const AdminPeminjamanScreen({super.key});

//   @override
//   State<AdminPeminjamanScreen> createState() => _AdminPeminjamanScreenState();
// }

// class _AdminPeminjamanScreenState extends State<AdminPeminjamanScreen> with TickerProviderStateMixin {
//   late TabController _tabController;
//   List<Booking> _bookings = [];
//   bool _isLoading = false;

//   final List<String> _tabs = ['Pengajuan', 'Foto', 'Masalah', 'Selesai'];
//   final List<String> _statusMap = ['pending', 'approved', 'in_use', 'done'];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     _loadBookings();
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   Future<void> _loadBookings() async {
//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final bookings = await ApiService.getBookings();
//       setState(() {
//         _bookings = bookings;
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

//   String _getBookingUserName(Booking booking) {
//     return booking.userName ?? booking.userDisplayName ?? 'Peminjam tidak diketahui';
//   }

//   String _getBookingLocation(Booking booking) {
//     return 'Gedung 24A, Ilmu Komputer';
//   }

//   String? _getBookingAfterPhoto(Booking booking) {
//     return booking.afterPhotoUrl ?? booking.roomPhotoAfterUrl;
//   }

//   Future<void> _markAsResolved(int bookingId) async {
//     setState(() => _isLoading = true);
//     try {
//       bool success = await ApiService.resolveIssue(bookingId);
//       if (success) {
//         await _refreshBookings();
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Masalah berhasil ditandai sebagai terselesaikan'),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal menandai sebagai terselesaikan: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   void _showPhotoDialog(String? photoUrl) {
//     if (photoUrl == null || photoUrl.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Foto tidak tersedia'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }

//     showDialog(
//       context: context,
//       builder: (context) => Dialog(
//         backgroundColor: Colors.black,
//         child: Stack(
//           children: [
//             Center(
//               child: InteractiveViewer(
//                 panEnabled: true,
//                 minScale: 0.5,
//                 maxScale: 3.0,
//                 child: Image.network(
//                   photoUrl,
//                   fit: BoxFit.contain,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 200,
//                     height: 200,
//                     color: Colors.grey[800],
//                     child: const Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.white, size: 48),
//                         SizedBox(height: 8),
//                         Text(
//                           'Gagal memuat foto',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 20,
//               child: IconButton(
//                 onPressed: () => Navigator.pop(context),
//                 icon: const Icon(Icons.close, color: Colors.white, size: 30),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showBookingDetail(Booking booking) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => BookingDetailScreen(booking: booking),
//       ),
//     ).then((_) => _refreshBookings());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Peminjaman',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
//           labelColor: const Color(0xFF192965),
//           unselectedLabelColor: Colors.grey,
//           indicatorColor: const Color(0xFF192965),
//           indicatorWeight: 3,
//           labelStyle: const TextStyle(fontWeight: FontWeight.w600),
//           unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: _tabs.asMap().entries.map((entry) {
//           final index = entry.key;
//           final status = _statusMap[index];
//           return _buildBookingList(status, index);
//         }).toList(),
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//       bottomNavigationBar: const NavBar(currentIndex: 1),
//     );
//   }

//   Widget _buildBookingList(String status, int tabIndex) {
//     return RefreshIndicator(
//       onRefresh: _refreshBookings,
//       child: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _buildBookingContent(status, tabIndex),
//     );
//   }

//   Widget _buildBookingContent(String status, int tabIndex) {
//     List<Booking> filteredBookings;
    
//     // Filter berdasarkan status dan tab
//     switch (tabIndex) {
//       case 0: // Pengajuan
//         filteredBookings = _bookings.where((b) => b.status == 'pending').toList();
//         break;
//       case 1: // Foto
//         filteredBookings = _bookings.where((b) => 
//           b.status == 'approved' || b.status == 'in_use').toList();
//         break;
//       case 2: // Masalah
//         filteredBookings = _bookings.where((b) => 
//           b.status == 'in_use' || 
//           (b.adminNotes != null && b.adminNotes!.isNotEmpty)).toList();
//         break;
//       case 3: // Selesai
//         filteredBookings = _bookings.where((b) => b.status == 'done').toList();
//         break;
//       default:
//         filteredBookings = [];
//     }

//     if (filteredBookings.isEmpty) {
//       String emptyMessage;
//       switch (tabIndex) {
//         case 0:
//           emptyMessage = 'Belum ada pengajuan peminjaman';
//           break;
//         case 1:
//           emptyMessage = 'Belum ada foto yang perlu direview';
//           break;
//         case 2:
//           emptyMessage = 'Tidak ada masalah yang dilaporkan';
//           break;
//         case 3:
//           emptyMessage = 'Belum ada peminjaman yang selesai';
//           break;
//         default:
//           emptyMessage = 'Belum ada peminjaman';
//       }

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
//               emptyMessage,
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: const EdgeInsets.all(16),
//       itemCount: filteredBookings.length,
//       itemBuilder: (context, index) {
//         return _buildBookingCard(filteredBookings[index], tabIndex);
//       },
//     );
//   }

//   Widget _buildBookingCard(Booking booking, int tabIndex) {
//     String formatTime(String time) {
//       try {
//         if (time.contains(':')) {
//           final parts = time.split(':');
//           final hour = int.parse(parts[0]);
//           final minute = int.parse(parts[1]);
//           return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
//         }
//         return time;
//       } catch (e) {
//         return time;
//       }
//     }

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16),
//       child: Card(
//         elevation: 2,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: InkWell(
//           onTap: () => _showBookingDetail(booking),
//           borderRadius: BorderRadius.circular(16),
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     // Room Image
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(12),
//                       child: (booking.roomPhotoUrl != null && booking.roomPhotoUrl!.isNotEmpty)
//                           ? Image.network(
//                               booking.roomPhotoUrl!,
//                               width: 80,
//                               height: 80,
//                               fit: BoxFit.cover,
//                               errorBuilder: (context, error, stackTrace) => Container(
//                                 width: 80,
//                                 height: 80,
//                                 color: Colors.grey[300],
//                                 child: Icon(Icons.meeting_room, color: Colors.grey[600]),
//                               ),
//                             )
//                           : Image.asset(
//                               'assets/images/default.jpeg',
//                               width: 80,
//                               height: 80,
//                               fit: BoxFit.cover,
//                             ),
//                     ),
//                     const SizedBox(width: 16),
                    
//                     // Booking Info
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             booking.roomName,
//                             style: const TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.location_on_rounded,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Expanded(
//                                 child: Text(
//                                   _getBookingLocation(booking),
//                                   style: TextStyle(
//                                     color: Colors.grey[600],
//                                     fontSize: 12,
//                                   ),
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 8),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.calendar_today,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 DateFormat('dd MMM yyyy').format(booking.bookingDate),
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(height: 2),
//                           Row(
//                             children: [
//                               Icon(
//                                 Icons.access_time,
//                                 size: 14,
//                                 color: Colors.grey[600],
//                               ),
//                               const SizedBox(width: 4),
//                               Text(
//                                 '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)} WIB',
//                                 style: TextStyle(
//                                   color: Colors.grey[700],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
                    
//                     // Status or Action Indicator
//                     Icon(
//                       Icons.chevron_right,
//                       color: Colors.grey[400],
//                     ),
//                   ],
//                 ),
                
//                 // Tab specific actions
//                 if (tabIndex == 1) ..._buildFotoActions(booking), // Tab Foto
//                 if (tabIndex == 2) ..._buildMasalahActions(booking), // Tab Masalah
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   List<Widget> _buildFotoActions(Booking booking) {
//     final afterPhoto = _getBookingAfterPhoto(booking);
    
//     return [
//       const SizedBox(height: 16),
//       const Divider(),
//       const SizedBox(height: 12),
//       Row(
//         children: [
//           Icon(Icons.photo_camera, color: Colors.grey[600], size: 20),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               afterPhoto != null && afterPhoto.isNotEmpty 
//                 ? 'Foto tersedia' 
//                 : 'Belum ada foto',
//               style: TextStyle(
//                 color: Colors.grey[700],
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton.icon(
//             onPressed: () => _showPhotoDialog(afterPhoto),
//             icon: const Icon(Icons.visibility, size: 16),
//             label: const Text('Lihat Foto'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF192965),
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ];
//   }

//   List<Widget> _buildMasalahActions(Booking booking) {
//     return [
//       const SizedBox(height: 16),
//       const Divider(),
//       const SizedBox(height: 12),
//       Row(
//         children: [
//           Icon(Icons.report_problem, color: Colors.orange[600], size: 20),
//           const SizedBox(width: 8),
//           const Expanded(
//             child: Text(
//               'Masalah dilaporkan',
//               style: TextStyle(
//                 color: Colors.orange,
//                 fontSize: 14,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ),
//           ElevatedButton.icon(
//             onPressed: _isLoading ? null : () => _markAsResolved(booking.id),
//             icon: _isLoading 
//               ? const SizedBox(
//                   width: 16,
//                   height: 16,
//                   child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
//                 )
//               : const Icon(Icons.check_circle, size: 16),
//             label: const Text('Terselesaikan'),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.green,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//           ),
//         ],
//       ),
//     ];
//   }
// }

// class BookingDetailScreen extends StatefulWidget {
//   final Booking booking;

//   const BookingDetailScreen({super.key, required this.booking});

//   @override
//   State<BookingDetailScreen> createState() => _BookingDetailScreenState();
// }

// class _BookingDetailScreenState extends State<BookingDetailScreen> {
//   bool _isLoading = false;

//   String _getBookingUserName(Booking booking) {
//     return booking.userName ?? booking.userDisplayName ?? 'Peminjam tidak diketahui';
//   }

//   String _getBookingLocation(Booking booking) {
//     return 'Gedung 24A, Ilmu Komputer';
//   }

//   String _getBookingEmail(Booking booking) {
//     return '232410102000@mail.unej.ac.id';
//   }

//   Future<void> _approveBooking() async {
//     setState(() => _isLoading = true);
//     try {
//       bool success = await ApiService.approveBooking(widget.booking.id, "Disetujui oleh admin");
//       if (success) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text('Booking berhasil disetujui'),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context);
//         }
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal menyetujui booking: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   Future<void> _rejectBooking() async {
//     final reasonController = TextEditingController();
    
//     final reason = await showDialog<String>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16),
//         ),
//         title: const Text('Alasan Penolakan'),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text('Berikan alasan penolakan peminjaman:'),
//             const SizedBox(height: 16),
//             TextField(
//               controller: reasonController,
//               maxLines: 3,
//               decoration: InputDecoration(
//                 hintText: 'Masukkan alasan penolakan...',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 contentPadding: const EdgeInsets.all(12),
//               ),
//             ),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Batal'),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               if (reasonController.text.trim().isNotEmpty) {
//                 Navigator.pop(context, reasonController.text.trim());
//               }
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(8),
//               ),
//             ),
//             child: const Text('Tolak', style: TextStyle(color: Colors.white)),
//           ),
//         ],
//       ),
//     );

//     if (reason != null && reason.isNotEmpty) {
//       setState(() => _isLoading = true);
//       try {
//         bool success = await ApiService.rejectBooking(widget.booking.id, reason);
//         if (success) {
//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text('Booking berhasil ditolak'),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             Navigator.pop(context);
//           }
//         }
//       } catch (e) {
//         if (mounted) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Gagal menolak booking: $e'),
//               backgroundColor: Colors.red,
//             ),
//           );
//         }
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   String formatTime(String time) {
//     try {
//       if (time.contains(':')) {
//         final parts = time.split(':');
//         final hour = int.parse(parts[0]);
//         final minute = int.parse(parts[1]);
//         return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
//       }
//       return time;
//     } catch (e) {
//       return time;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Persetujuan',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         centerTitle: true,
//         elevation: 0,
//         backgroundColor: Colors.white,
//         foregroundColor: Colors.black,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.more_vert),
//             onPressed: () {},
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Room Info Card
//             Container(
//               margin: const EdgeInsets.all(20),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: (widget.booking.roomPhotoUrl != null && widget.booking.roomPhotoUrl!.isNotEmpty)
//                         ? Image.network(
//                             widget.booking.roomPhotoUrl!,
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                             errorBuilder: (context, error, stackTrace) => Container(
//                               width: 80,
//                               height: 80,
//                               color: Colors.grey[300],
//                               child: Icon(Icons.meeting_room, color: Colors.grey[600]),
//                             ),
//                           )
//                         : Image.asset(
//                             'assets/images/default.jpeg',
//                             width: 80,
//                             height: 80,
//                             fit: BoxFit.cover,
//                           ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           widget.booking.roomName,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Row(
//                           children: [
//                             Icon(
//                               Icons.location_on_rounded,
//                               size: 16,
//                               color: Colors.grey[600],
//                             ),
//                             const SizedBox(width: 4),
//                             Expanded(
//                               child: Text(
//                                 _getBookingLocation(widget.booking),
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 14,
//                                 ),
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.orange[100],
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           child: Text(
//                             '50 Orang',
//                             style: TextStyle(
//                               color: Colors.orange[700],
//                               fontSize: 12,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             // Detail Peminjaman
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildDetailRow(
//                     icon: Icons.calendar_today,
//                     label: 'Tanggal',
//                     value: DateFormat('dd MMM yyyy').format(widget.booking.bookingDate),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.person,
//                     label: 'Peminjam',
//                     value: _getBookingUserName(widget.booking),
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.access_time,
//                     label: 'Jam',
//                     value: '${formatTime(widget.booking.startTime)} - ${formatTime(widget.booking.endTime)} WIB',
//                   ),
//                   const SizedBox(height: 16),
//                   _buildDetailRow(
//                     icon: Icons.email,
//                     label: 'Email',
//                     value: _getBookingEmail(widget.booking),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Alasan Peminjaman
//             Container(
//               margin: const EdgeInsets.symmetric(horizontal: 20),
//               padding: const EdgeInsets.all(20),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.05),
//                     blurRadius: 10,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Alasan Peminjaman',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   Text(
//                     widget.booking.purpose,
//                     style: TextStyle(
//                       color: Colors.grey[700],
//                       fontSize: 14,
//                       height: 1.5,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             // Alasan Penolakan (if rejected)
//             if (widget.booking.status == 'rejected') ...[
//               Container(
//                 margin: const EdgeInsets.symmetric(horizontal: 20),
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.red[50],
//                   borderRadius: BorderRadius.circular(16),
//                   border: Border.all(color: Colors.red[200]!),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Alasan Penolakan',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                         color: Colors.red,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     Text(
//                       widget.booking.adminNotes ?? 'Tidak ada alasan yang diberikan.',
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                         height: 1.5,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 20),
//             ],

//             // Action Buttons - Only show for pending status
//             if (widget.booking.status == 'pending') ...[
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Row(
//                   children: [
//                     Expanded(
//                       child: OutlinedButton(
//                         onPressed: _isLoading ? null : _rejectBooking,
//                         style: OutlinedButton.styleFrom(
//                           foregroundColor: Colors.red,
//                           side: const BorderSide(color: Colors.red, width: 2),
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(strokeWidth: 2),
//                               )
//                             : const Text(
//                                 'Ditolak',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                       ),
//                     ),
//                     const SizedBox(width: 16),
//                     Expanded(
//                       child: ElevatedButton(
//                         onPressed: _isLoading ? null : _approveBooking,
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF192965),
//                           foregroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           elevation: 0,
//                         ),
//                         child: _isLoading
//                             ? const SizedBox(
//                                 height: 20,
//                                 width: 20,
//                                 child: CircularProgressIndicator(
//                                   color: Colors.white,
//                                   strokeWidth: 2,
//                                 ),
//                               )
//                             : const Text(
//                                 'Disetujui',
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w600,
//                                   fontSize: 16,
//                                 ),
//                               ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//       backgroundColor: const Color(0xFFF7F7FA),
//     );
//   }

//   Widget _buildDetailRow({
//     required IconData icon,
//     required String label,
//     required String value,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: Colors.grey[600],
//         ),
//         const SizedBox(width: 12),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   color: Colors.grey[600],
//                   fontSize: 14,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               const SizedBox(height: 2),
//               Text(
//                 value,
//                 style: const TextStyle(
//                   color: Colors.black87,
//                   fontSize: 15,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }








import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/models/approval.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/screens/admin/navbar_admin.dart';

class AdminPeminjamanScreen extends StatefulWidget {
  const AdminPeminjamanScreen({super.key});

  @override
  State<AdminPeminjamanScreen> createState() => _AdminPeminjamanScreenState();
}

class _AdminPeminjamanScreenState extends State<AdminPeminjamanScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = [];
  bool _isLoading = false;

  final List<String> _tabs = ['Pengajuan', 'Foto', 'Masalah', 'Selesai'];
  final List<String> _statusMap = ['pending', 'approved', 'in_use', 'done'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final bookings = await ApiService.getBookings();
      setState(() {
        _bookings = bookings;
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

  String _getBookingUserName(Booking booking) {
    return booking.userName ?? booking.userDisplayName ?? 'Peminjam tidak diketahui';
  }

  String _getBookingLocation(Booking booking) {
    return 'Gedung 24A, Ilmu Komputer';
  }

  String? _getBookingAfterPhoto(Booking booking) {
    return booking.afterPhotoUrl ?? booking.roomPhotoAfterUrl;
  }

  Future<void> _markAsResolved(Booking booking) async {
    setState(() => _isLoading = true);
    try {
      // Create updated booking object with 'done' status
      final updatedBooking = Booking(
        id: booking.id,
        roomId: booking.roomId,
        roomName: booking.roomName,
        userId: booking.userId,
        userName: booking.userName,
        bookingDate: booking.bookingDate,
        startTime: booking.startTime,
        endTime: booking.endTime,
        purpose: booking.purpose,
        status: 'done', // Change status to done
        checkinTime: booking.checkinTime,
        checkoutTime: booking.checkoutTime,
        locationGps: booking.locationGps,
        isPresent: booking.isPresent,
        roomPhotoUrl: booking.roomPhotoUrl,
        createdAt: booking.createdAt,
        photoUrls: booking.photoUrls,
      );

      // Use PUT /api/bookings/{id} to update the booking
      bool success = await ApiService.updateBooking(updatedBooking);
      
      if (success) {
        await _refreshBookings();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Masalah berhasil ditandai sebagai terselesaikan'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menandai sebagai terselesaikan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showPhotoDialog(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foto tidak tersedia'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  photoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 200,
                    height: 200,
                    color: Colors.grey[800],
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.white, size: 48),
                        SizedBox(height: 8),
                        Text(
                          'Gagal memuat foto',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.white, size: 30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBookingDetail(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingDetailScreen(booking: booking),
      ),
    ).then((_) => _refreshBookings());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        bottom: TabBar(
          controller: _tabController,
          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
          labelColor: const Color(0xFF192965),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF192965),
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final status = _statusMap[index];
          return _buildBookingList(status, index);
        }).toList(),
      ),
      backgroundColor: const Color(0xFFF7F7FA),
      bottomNavigationBar: const NavBar(currentIndex: 1),
    );
  }

  Widget _buildBookingList(String status, int tabIndex) {
    return RefreshIndicator(
      onRefresh: _refreshBookings,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBookingContent(status, tabIndex),
    );
  }

  Widget _buildBookingContent(String status, int tabIndex) {
    List<Booking> filteredBookings;
    
    // Filter berdasarkan status dan tab
    switch (tabIndex) {
      case 0: // Pengajuan
        filteredBookings = _bookings.where((b) => b.status == 'pending').toList();
        break;
      case 1: // Foto
        filteredBookings = _bookings.where((b) => 
          b.status == 'approved' || b.status == 'in_use').toList();
        break;
      case 2: // Masalah
        filteredBookings = _bookings.where((b) => 
          b.status == 'in_use' || 
          (b.adminNotes != null && b.adminNotes!.isNotEmpty)).toList();
        break;
      case 3: // Selesai
        filteredBookings = _bookings.where((b) => b.status == 'done').toList();
        break;
      default:
        filteredBookings = [];
    }

    if (filteredBookings.isEmpty) {
      String emptyMessage;
      switch (tabIndex) {
        case 0:
          emptyMessage = 'Belum ada pengajuan peminjaman';
          break;
        case 1:
          emptyMessage = 'Belum ada foto yang perlu direview';
          break;
        case 2:
          emptyMessage = 'Tidak ada masalah yang dilaporkan';
          break;
        case 3:
          emptyMessage = 'Belum ada peminjaman yang selesai';
          break;
        default:
          emptyMessage = 'Belum ada peminjaman';
      }

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
              emptyMessage,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredBookings.length,
      itemBuilder: (context, index) {
        return _buildBookingCard(filteredBookings[index], tabIndex);
      },
    );
  }

  Widget _buildBookingCard(Booking booking, int tabIndex) {
    String formatTime(String time) {
      try {
        if (time.contains(':')) {
          final parts = time.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
        }
        return time;
      } catch (e) {
        return time;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _showBookingDetail(booking),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Room Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: (booking.roomPhotoUrl != null && booking.roomPhotoUrl!.isNotEmpty)
                          ? Image.network(
                              booking.roomPhotoUrl!,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                width: 80,
                                height: 80,
                                color: Colors.grey[300],
                                child: Icon(Icons.meeting_room, color: Colors.grey[600]),
                              ),
                            )
                          : Image.asset(
                              'assets/images/default.jpeg',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Booking Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            booking.roomName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  _getBookingLocation(booking),
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('dd MMM yyyy').format(booking.bookingDate),
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)} WIB',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    
                    // Status or Action Indicator
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
                
                // Tab specific actions
                if (tabIndex == 1) ..._buildFotoActions(booking), // Tab Foto
                if (tabIndex == 2) ..._buildMasalahActions(booking), // Tab Masalah
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFotoActions(Booking booking) {
    final afterPhoto = _getBookingAfterPhoto(booking);
    
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.photo_camera, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              afterPhoto != null && afterPhoto.isNotEmpty 
                ? 'Foto tersedia' 
                : 'Belum ada foto',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showPhotoDialog(afterPhoto),
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Lihat Foto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF192965),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildMasalahActions(Booking booking) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.report_problem, color: Colors.orange[600], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Masalah dilaporkan',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _markAsResolved(booking),
            icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.check_circle, size: 16),
            label: const Text('Terselesaikan'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    ];
  }
}

class BookingDetailScreen extends StatefulWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool _isLoading = false;

  String _getBookingUserName(Booking booking) {
    return booking.userName ?? booking.userDisplayName ?? 'Peminjam tidak diketahui';
  }

  String _getBookingLocation(Booking booking) {
    return 'Gedung 24A, Ilmu Komputer';
  }

  String _getBookingEmail(Booking booking) {
    return '232410102000@mail.unej.ac.id';
  }

  Future<void> _approveBooking() async {
    setState(() => _isLoading = true);
    try {
      bool success = await ApiService.approveBooking(widget.booking.id, "Disetujui oleh admin");
      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking berhasil disetujui'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui booking: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _rejectBooking() async {
    final reasonController = TextEditingController();
    
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Alasan Penolakan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Berikan alasan penolakan peminjaman:'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Masukkan alasan penolakan...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isNotEmpty) {
                Navigator.pop(context, reasonController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tolak', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      setState(() => _isLoading = true);
      try {
        bool success = await ApiService.rejectBooking(widget.booking.id, reason);
        if (success) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Booking berhasil ditolak'),
                backgroundColor: Colors.orange,
              ),
            );
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal menolak booking: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  String formatTime(String time) {
    try {
      if (time.contains(':')) {
        final parts = time.split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return '${hour.toString().padLeft(2, '0')}.${minute.toString().padLeft(2, '0')}';
      }
      return time;
    } catch (e) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Persetujuan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Info Card
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: (widget.booking.roomPhotoUrl != null && widget.booking.roomPhotoUrl!.isNotEmpty)
                        ? Image.network(
                            widget.booking.roomPhotoUrl!,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80,
                              height: 80,
                              color: Colors.grey[300],
                              child: Icon(Icons.meeting_room, color: Colors.grey[600]),
                            ),
                          )
                        : Image.asset(
                            'assets/images/default.jpeg',
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.booking.roomName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              size: 16,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _getBookingLocation(widget.booking),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '50 Orang',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Detail Peminjaman
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal',
                    value: DateFormat('dd MMM yyyy').format(widget.booking.bookingDate),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.person,
                    label: 'Peminjam',
                    value: _getBookingUserName(widget.booking),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Jam',
                    value: '${formatTime(widget.booking.startTime)} - ${formatTime(widget.booking.endTime)} WIB',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _getBookingEmail(widget.booking),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Alasan Peminjaman
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Alasan Peminjaman',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.booking.purpose,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Alasan Penolakan (if rejected)
            if (widget.booking.status == 'rejected') ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Alasan Penolakan',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.booking.adminNotes ?? 'Tidak ada alasan yang diberikan.',
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Action Buttons - Only show for pending status
            if (widget.booking.status == 'pending') ...[
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _rejectBooking,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text(
                                'Ditolak',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _approveBooking,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF192965),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Disetujui',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      backgroundColor: const Color(0xFFF7F7FA),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[600],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}