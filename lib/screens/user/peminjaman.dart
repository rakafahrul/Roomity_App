import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:geolocator/geolocator.dart'; 
import 'package:image_picker/image_picker.dart'; 
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PeminjamanScreen extends StatefulWidget {
  final int currentUserId;
  const PeminjamanScreen({super.key, required this.currentUserId});

  @override
  State<PeminjamanScreen> createState() => _PeminjamanScreenState();
}

class _PeminjamanScreenState extends State<PeminjamanScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = [];
  bool _isLoading = false;

  final List<String> _tabs = ['Pengajuan', 'Disetujui', 'Pemakaian', 'Selesai'];
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
      return json['roomLocation'] ?? 'Gedung 24A, Ilmu Komputer';
    } else if (json.containsKey('room_location')) {
      return json['room_location'] ?? 'Gedung 24A, Ilmu Komputer';
    } else if (json.containsKey('location')) {
      return json['location'] ?? 'Gedung 24A, Ilmu Komputer';
    }
    return 'Gedung 24A, Ilmu Komputer';
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

  Future<void> _konfirmasiKehadiran(Booking booking) async {
    setState(() => _isLoading = true);
    
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

      double roomLat = _getBookingLatitude(booking) ?? -8.165922026829602;
      double roomLng = _getBookingLongitude(booking) ?? 113.7168622702779;
      double distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, roomLat, roomLng);

      if (distance <= 980) {
        // konfirmasi kehadiran
        await ApiService.confirmAttendance(
          booking.id,
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
    } finally {
      setState(() => _isLoading = false);
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

  void _showBookingDetail(Booking booking) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserBookingDetailScreen(booking: booking),
      ),
    ).then((_) => _refreshBookings());
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
    List<Booking> filteredBookings = _bookings.where((b) => b.status == status).toList();

    if (filteredBookings.isEmpty) {
      String emptyMessage;
      IconData emptyIcon;
      switch (tabIndex) {
        case 0:
          emptyMessage = 'Belum ada pengajuan peminjaman';
          emptyIcon = Icons.pending_actions;
          break;
        case 1:
          emptyMessage = 'Belum ada peminjaman yang disetujui';
          emptyIcon = Icons.check_circle_outline;
          break;
        case 2:
          emptyMessage = 'Belum ada peminjaman yang sedang digunakan';
          emptyIcon = Icons.room_outlined;
          break;
        case 3:
          emptyMessage = 'Belum ada peminjaman yang selesai';
          emptyIcon = Icons.done_all;
          break;
        default:
          emptyMessage = 'Belum ada peminjaman';
          emptyIcon = Icons.event_note;
      }

      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
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
                if (tabIndex == 0) ..._buildPengajuanActions(booking), // Tab Pengajuan
                if (tabIndex == 1) ..._buildDisetujuiActions(booking), // Tab Disetujui
                if (tabIndex == 2) ..._buildPemakaianActions(booking), // Tab Pemakaian
                if (tabIndex == 3) ..._buildSelesaiActions(booking), // Tab Selesai
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildPengajuanActions(Booking booking) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.pending_actions, color: Colors.orange[600], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Menunggu persetujuan admin',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'PENDING',
              style: TextStyle(
                color: Colors.orange[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];
  }

  List<Widget> _buildDisetujuiActions(Booking booking) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.location_on, color: Colors.blue[600], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Konfirmasi kehadiran di lokasi',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isLoading ? null : () => _konfirmasiKehadiran(booking),
            icon: _isLoading 
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.location_on, size: 16),
            label: const Text('Check-in'),
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
                'Konfirmasi kehadiran maksimal 1 jam setelah jadwal dimulai',
                style: TextStyle(color: Colors.blue, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildPemakaianActions(Booking booking) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.camera_alt, color: Colors.green[600], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Upload foto pertanggungjawaban',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _openPertanggungjawaban(booking),
            icon: const Icon(Icons.camera_alt, size: 16),
            label: const Text('Upload'),
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
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: const [
            Icon(Icons.warning_outlined, color: Colors.orange, size: 16),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Upload foto maksimal 3 hari setelah menggunakan ruangan',
                style: TextStyle(color: Colors.orange, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildSelesaiActions(Booking booking) {
    return [
      const SizedBox(height: 16),
      const Divider(),
      const SizedBox(height: 12),
      Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Peminjaman selesai',
              style: TextStyle(
                color: Colors.green,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'SELESAI',
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    ];
  }
}

// ✅ USER BOOKING DETAIL SCREEN
class UserBookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const UserBookingDetailScreen({super.key, required this.booking});

  String _getBookingLocation(Booking booking) {
    return 'Gedung 24A, Ilmu Komputer';
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'in_use':
        return Colors.green;
      case 'done':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Menunggu Persetujuan';
      case 'approved':
        return 'Disetujui';
      case 'in_use':
        return 'Sedang Digunakan';
      case 'done':
        return 'Selesai';
      case 'rejected':
        return 'Ditolak';
      default:
        return status.toUpperCase();
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
          'Detail Peminjaman',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          booking.roomName,
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
                                _getBookingLocation(booking),
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
                            color: _getStatusColor(booking.status).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getStatusText(booking.status),
                            style: TextStyle(
                              color: _getStatusColor(booking.status),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
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
                  const Text(
                    'Detail Peminjaman',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.calendar_today,
                    label: 'Tanggal',
                    value: DateFormat('dd MMM yyyy').format(booking.bookingDate),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.access_time,
                    label: 'Waktu',
                    value: '${formatTime(booking.startTime)} - ${formatTime(booking.endTime)} WIB',
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow(
                    icon: Icons.confirmation_number,
                    label: 'ID Booking',
                    value: booking.id.toString(),
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
                    booking.purpose,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Admin Notes (if rejected)
            if (booking.status == 'rejected' && booking.adminNotes != null) ...[
              const SizedBox(height: 20),
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
                      booking.adminNotes!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 20),
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

// ✅ HALAMAN PERTANGGUNGJAWABAN - CAMERA ONLY (Keep as is)
class PertanggungjawabanScreen extends StatefulWidget {
  final Booking booking;
  const PertanggungjawabanScreen({super.key, required this.booking});

  @override
  State<PertanggungjawabanScreen> createState() => _PertanggungjawabanScreenState();
}

class _PertanggungjawabanScreenState extends State<PertanggungjawabanScreen> {
  XFile? photo;
  bool loading = false;
  String loadingMessage = 'Menyiapkan...';

  // ✅ IMPROVED: Better photo capture with validation
  Future<void> pickPhotoFromCamera() async {
    try {
      final picker = ImagePicker();
      
      // ✅ Check camera permission first
      final cameraPermission = await Permission.camera.request();
      if (cameraPermission.isDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Izin kamera diperlukan untuk mengambil foto'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      
      // ✅ Konfirmasi sebelum membuka kamera
      final confirm = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.camera_alt, color: Color(0xFF192965)),
                SizedBox(width: 8),
                Text('Foto Ruangan'),
              ],
            ),
            content: const Text('Ambil foto kondisi ruangan setelah digunakan?'),
            actions: [
              TextButton(
                child: const Text('Batal'),
                onPressed: () => Navigator.pop(context, false),
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt, size: 18),
                label: const Text('Buka Kamera'),
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      // ✅ Show loading while opening camera
      setState(() {
        loadingMessage = 'Membuka kamera...';
        loading = true;
      });

      // ✅ Buka kamera dengan konfigurasi optimal
      final XFile? capturedPhoto = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85, // Balance between quality and file size
        maxWidth: 1920,
        maxHeight: 1080,
        preferredCameraDevice: CameraDevice.rear,
      );
      
      setState(() {
        loading = false;
      });
      
      if (capturedPhoto != null) {
        // ✅ Validate captured photo
        final file = File(capturedPhoto.path);
        final fileSize = await file.length();
        
        if (fileSize == 0) {
          throw Exception('Foto kosong, silakan coba lagi');
        }
        
        if (fileSize > 10 * 1024 * 1024) { // 10MB limit
          throw Exception('Ukuran foto terlalu besar (maksimal 10MB)');
        }
        
        setState(() {
          photo = capturedPhoto;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Foto berhasil diambil'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(child: Text('Gagal mengambil foto: $e')),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  // ✅ IMPROVED: Robust upload with multiple strategies
  Future<void> submit() async {
    if (photo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text('Foto harus diisi!'),
            ],
          ),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
      return;
    }
    
    // ✅ Enhanced confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.send, color: Color(0xFF192965)),
              SizedBox(width: 8),
              Text('Konfirmasi Pengiriman'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Kirim pertanggungjawaban sekarang?'),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
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
                        'Pastikan foto sudah sesuai sebelum mengirim',
                        style: TextStyle(color: Colors.amber, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () => Navigator.pop(context, false),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.send, size: 18),
              label: const Text('Kirim'),
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF192965),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;
    
    setState(() {
      loading = true;
      loadingMessage = 'Menyiapkan upload...';
    });
    
    try {
      // ✅ Validate file exists before upload
      final file = File(photo!.path);
      if (!await file.exists()) {
        throw Exception('File foto tidak ditemukan');
      }
      
      setState(() {
        loadingMessage = 'Mengirim foto...';
      });
      
      // ✅ Use debug upload strategy untuk melihat detail error
      print('🎯 PERTANGGUNGJAWABAN: Starting upload for booking ${widget.booking.id}');
      
      await ApiService.uploadPertanggungjawabanSmart(
        bookingId: widget.booking.id,
        photo: photo!,
      );
      
      setState(() {
        loadingMessage = 'Menyelesaikan...';
      });
      
      // ✅ Small delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (mounted) {
        // ✅ Show success dialog
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 32),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Berhasil!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pertanggungjawaban berhasil dikirim',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context, true); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // ✅ Show detailed error dialog
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 8),
                Text('Gagal Mengirim'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Terjadi kesalahan: ${e.toString()}'),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.lightbulb_outline, color: Colors.blue, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pastikan koneksi internet stabil dan coba lagi',
                          style: TextStyle(color: Colors.blue, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  submit(); // Retry
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                ),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
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
        // ✅ Prevent back during loading
        leading: loading ? null : IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Padding(
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
                    border: Border.all(color: Colors.blue[200]!),
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
                      const SizedBox(height: 4),
                      Text(
                        'ID Booking: ${widget.booking.id}',
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                  onTap: loading ? null : pickPhotoFromCamera,
                  child: Center(
                    child: Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: photo != null ? Colors.green : Colors.grey[300]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: loading ? Colors.grey[100] : Colors.grey[50],
                        image: photo != null && !loading
                          ? DecorationImage(
                              image: FileImage(File(photo!.path)), 
                              fit: BoxFit.cover
                            )
                          : null,
                      ),
                      child: photo == null || loading
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.camera_alt, 
                                size: 48, 
                                color: loading ? Colors.grey : Colors.grey[600]
                              ),
                              const SizedBox(height: 16),
                              Text(
                                loading ? 'Sedang memproses...' : 'Ambil Foto',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: loading ? Colors.grey : Colors.grey[700],
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                loading ? loadingMessage : 'Tap untuk membuka kamera',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                                textAlign: TextAlign.center,
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
                    border: Border.all(color: Colors.amber[200]!),
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
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(loadingMessage),
                          ],
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
          
          // ✅ Loading overlay
          if (loading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Sedang memproses...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}