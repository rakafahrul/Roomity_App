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

  final tabMap = {
    'pending': 'Pengajuan',
    'approved': 'Disetujui',
    'in_use': 'Pemakaian',
    'done': 'Selesai',
  };

  Future<void> _konfirmasiKehadiran(Booking b) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nyalakan layanan lokasi')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Akses lokasi diperlukan untuk konfirmasi kehadiran')),
        );
        return;
      }
    }

    Position pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Lokasi ruangan statis (contoh) -- sebaiknya dari API
    double roomLat = -8.173736967255216; // Ganti dengan data booking/room -8.173736967255216 -6.3629;
    double roomLng = 113.70799078353119; // Ganti dengan data booking/room 106.8246;
    double distance = Geolocator.distanceBetween(pos.latitude, pos.longitude, roomLat, roomLng);

    if (distance <= 50) {
      // Panggil API konfirmasi kehadiran, lalu refresh
      await ApiService.confirmAttendance(
        b.id,
        "${pos.latitude},${pos.longitude}",
      ); // Implementasikan di ApiService
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Kehadiran berhasil dikonfirmasi!')),
      );
      setState(() {}); // Refresh data
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Anda belum berada di lokasi ruangan!')),
      );
    }
  }

  void _openPertanggungjawaban(Booking booking) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PertanggungjawabanScreen(booking: booking),
      ),
    );
    if (result == true) setState(() {}); // Refresh jika berhasil upload
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
                          ? [BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2))]
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
          Expanded(
            child: FutureBuilder<List<Booking>>(
              future: ApiService.getBookings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Gagal memuat data'));
                }
                final bookings = (snapshot.data ?? [])
                    .where((b) => b.userId == widget.currentUserId && b.status == selectedTab)
                    .toList();
                if (bookings.isEmpty) {
                  return Center(child: Text('Belum ada peminjaman'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: bookings.length,
                  itemBuilder: (context, i) => _bookingCard(context, bookings[i]),
                );
              },
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF7F7FA),
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
                  b.roomPhotoUrl != null && b.roomPhotoUrl!.isNotEmpty
                      ? b.roomPhotoUrl!
                      : 'https://images.unsplash.com/photo-1515378791036-0648a3ef77b2',
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
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
                        Text(
                          b.location,
                          style: const TextStyle(color: Colors.black45, fontSize: 14),
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
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Status badge & tombol aksi
          if (b.status == 'pending')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Menunggu Persetujuan',
                  style: TextStyle(color: Colors.orange, fontWeight: FontWeight.w600)),
            ),
          if (b.status == 'approved')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _konfirmasiKehadiran(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF192965),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Konfirmasi Kehadiran'),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.black26, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Jika tidak melakukan konfirmasi kehadiran > 1 jam dari jadwal, maka peminjaman otomatis dianggap dibatalkan.',
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (b.status == 'in_use')
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _openPertanggungjawaban(b),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.yellow[700],
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      elevation: 0,
                    ),
                    child: const Text('Pertanggungjawaban', style: TextStyle(color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: const [
                    Icon(Icons.info_outline, color: Colors.black26, size: 16),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'Jika tidak melakukan pertanggungjawaban > 3 hari setelah menggunakan ruang, maka peminjam tidak akan bisa meminjam ruangan kembali di kemudian hari.',
                        style: TextStyle(color: Colors.black38, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          if (b.status == 'done')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text('Selesai',
                  style: TextStyle(color: Color(0xFF4DD18B), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }
}

// Halaman pertanggungjawaban (upload foto before-after)
class PertanggungjawabanScreen extends StatefulWidget {
  final Booking booking;
  const PertanggungjawabanScreen({super.key, required this.booking});

  @override
  State<PertanggungjawabanScreen> createState() => _PertanggungjawabanScreenState();
}

class _PertanggungjawabanScreenState extends State<PertanggungjawabanScreen> {
  XFile? beforePhoto;
  XFile? afterPhoto;
  bool loading = false;

  Future<void> pickPhoto(bool isBefore) async {
    final picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        if (isBefore) beforePhoto = photo;
        else afterPhoto = photo;
      });
    }
  }

  Future<void> submit() async {
    if (beforePhoto == null || afterPhoto == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Foto before & after harus diisi!')),
      );
      return;
    }
    setState(() => loading = true);
    // Panggil API upload foto & update status ke done
    await ApiService.uploadPertanggungjawaban(
      bookingId: widget.booking.id,
      beforePhoto: beforePhoto!,
      afterPhoto: afterPhoto!,
    );
    setState(() => loading = false);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pertanggungjawaban')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Upload foto before & after ruangan', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickPhoto(true),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                        image: beforePhoto != null
                          ? DecorationImage(image: FileImage(File(beforePhoto!.path)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: beforePhoto == null
                        ? Center(child: Text('Foto Before'))
                        : null,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () => pickPhoto(false),
                    child: Container(
                      height: 120,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black12),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey[100],
                        image: afterPhoto != null
                          ? DecorationImage(image: FileImage(File(afterPhoto!.path)), fit: BoxFit.cover)
                          : null,
                      ),
                      child: afterPhoto == null
                        ? Center(child: Text('Foto After'))
                        : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : submit,
                child: loading
                  ? CircularProgressIndicator(color: Colors.white)
                  : Text('Kirim Pertanggungjawaban'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}