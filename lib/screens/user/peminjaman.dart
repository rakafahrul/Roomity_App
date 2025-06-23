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
// class PertanggungjawabanScreen extends StatefulWidget {
//   final Booking booking;
//   const PertanggungjawabanScreen({super.key, required this.booking});

//   @override
//   State<PertanggungjawabanScreen> createState() => _PertanggungjawabanScreenState();
// }

// class _PertanggungjawabanScreenState extends State<PertanggungjawabanScreen> {
//   XFile? photo;
//   bool loading = false;

//   Future<void> pickPhotoFromCamera() async {
//     try {
//       final picker = ImagePicker();
      
//       // ✅ Konfirmasi sebelum membuka kamera
//       final confirm = await showDialog<bool>(
//         context: context,
//         builder: (BuildContext context) {
//           return AlertDialog(
//             title: const Text('Foto Ruangan'),
//             content: const Text('Ambil foto kondisi ruangan setelah digunakan?'),
//             actions: [
//               TextButton(
//                 child: const Text('Batal'),
//                 onPressed: () => Navigator.pop(context, false),
//               ),
//               ElevatedButton.icon(
//                 icon: const Icon(Icons.camera_alt),
//                 label: const Text('Buka Kamera'),
//                 onPressed: () => Navigator.pop(context, true),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: const Color(0xFF192965),
//                   foregroundColor: Colors.white,
//                 ),
//               ),
//             ],
//           );
//         },
//       );

//       if (confirm != true) return;

//       // ✅ Buka kamera langsung
//       final XFile? capturedPhoto = await picker.pickImage(
//         source: ImageSource.camera,
//         imageQuality: 80,
//         maxWidth: 1024,
//         maxHeight: 1024,
//         preferredCameraDevice: CameraDevice.rear,
//       );
      
//       if (capturedPhoto != null) {
//         setState(() {
//           photo = capturedPhoto;
//         });
        
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Foto berhasil diambil'),
//             backgroundColor: Colors.green,
//             duration: const Duration(seconds: 2),
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Gagal mengambil foto: $e'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     }
//   }

//   Future<void> submit() async {
//     if (photo == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Foto harus diisi!'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
    
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Konfirmasi'),
//           content: const Text('Kirim pertanggungjawaban sekarang?'),
//           actions: [
//             TextButton(
//               child: const Text('Batal'),
//               onPressed: () => Navigator.pop(context, false),
//             ),
//             ElevatedButton(
//               child: const Text('Kirim'),
//               onPressed: () => Navigator.pop(context, true),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF192965),
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirm != true) return;
    
//     setState(() => loading = true);
    
//     try {
//       await ApiService.uploadPertanggungjawaban(
//         bookingId: widget.booking.id,
//         photo: photo!,
//       );
      
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
//               'Ambil foto ruangan setelah digunakan',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             const Text(
//               'Gunakan kamera untuk mengambil foto kondisi ruangan setelah digunakan',
//               style: TextStyle(color: Colors.grey),
//             ),
            
//             const SizedBox(height: 24),
            
//             // Photo area
//             GestureDetector(
//               onTap: pickPhotoFromCamera,
//               child: Center(
//                 child: Container(
//                   height: 200,
//                   width: double.infinity,
//                   decoration: BoxDecoration(
//                     border: Border.all(color: photo != null ? Colors.green : Colors.grey[300]!),
//                     borderRadius: BorderRadius.circular(12),
//                     color: Colors.grey[50],
//                     image: photo != null
//                       ? DecorationImage(
//                           image: FileImage(File(photo!.path)), 
//                           fit: BoxFit.cover
//                         )
//                       : null,
//                   ),
//                   child: photo == null
//                     ? Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.camera_alt, size: 48, color: Colors.grey[600]),
//                           const SizedBox(height: 16),
//                           Text(
//                             'Ambil Foto',
//                             style: TextStyle(
//                               fontWeight: FontWeight.w600,
//                               color: Colors.grey[700],
//                               fontSize: 18,
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             'Tap untuk membuka kamera',
//                             style: TextStyle(
//                               fontSize: 14,
//                               color: Colors.grey[500],
//                             ),
//                           ),
//                         ],
//                       )
//                     : Container(
//                         decoration: BoxDecoration(
//                           borderRadius: BorderRadius.circular(12),
//                           color: Colors.black.withOpacity(0.3),
//                         ),
//                         child: const Center(
//                           child: Icon(
//                             Icons.check_circle,
//                             color: Colors.white,
//                             size: 48,
//                           ),
//                         ),
//                       ),
//                 ),
//               ),
//             ),
            
//             // Info tambahan
//             const SizedBox(height: 16),
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.amber[50],
//                 borderRadius: BorderRadius.circular(8),
//               ),
//               child: Row(
//                 children: const [
//                   Icon(Icons.info_outline, color: Colors.amber, size: 16),
//                   SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Pastikan foto jelas dan kondisi ruangan terlihat dengan baik',
//                       style: TextStyle(color: Colors.amber, fontSize: 12),
//                     ),
//                   ),
//                 ],
//               ),
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