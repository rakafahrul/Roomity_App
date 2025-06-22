
import 'package:flutter/material.dart';
import 'package:rom_app/screens/admin/room_management_screen.dart';
import 'room_detail_screen.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/screens/admin/room_detail_screen.dart';
import 'package:rom_app/screens/admin/navbar_admin.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late Future<List<Room>> futureRooms;

  @override
  void initState() {
    super.initState();
    futureRooms = ApiService.getRooms();
    fetchRooms();
  }

  void fetchRooms() {
    setState(() {
      futureRooms = ApiService.getRooms();
    });
  }

  // Widget untuk menampilkan gambar ruangan dengan fallback ke default
  Widget _buildRoomImage(Room room) {
    return Image.network(
      room.photoUrl,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0A3573),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Jika gagal load dari network, gunakan gambar default dari assets
        return Image.asset(
          'assets/images/default.jpeg',
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Jika default.png juga gagal, tampilkan placeholder
            return _buildDefaultRoomPlaceholder();
          },
        );
      },
    );
  }

  // Widget placeholder jika semua gambar gagal dimuat
  Widget _buildDefaultRoomPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple room illustration using icons
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
              // Table
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Chairs
              Positioned(
                left: 15,
                top: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                bottom: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 15,
                bottom: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ruang Meeting',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Default',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavBar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            // Header - sama seperti code pertama
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 24,
                    backgroundImage: AssetImage('assets/images/profile.png'), 
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Admin', // Ubah dari 'Peminjam' ke 'Admin'
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Color(0xFF222B45),
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Color(0xFFE4E9F2)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.notifications_none_rounded, color: Color(0xFF222B45)),
                      onPressed: () {},
                      iconSize: 22,
                      splashRadius: 22,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Dashboard Admin', // Ubah title sesuai halaman admin
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Grid Ruangan
            Expanded(
              child: FutureBuilder<List<Room>>(
                future: futureRooms,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final rooms = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: rooms.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 18, // Sesuaikan dengan code pertama
                      crossAxisSpacing: 16, // Sesuaikan dengan code pertama
                      childAspectRatio: 0.85, // Sesuaikan dengan code pertama
                    ),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return GestureDetector(
                        onTap: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AdminRoomDetailScreen(room: room),
                            ),
                          );

                          if (result == true) {
                            fetchRooms();
                            setState(() {
                              futureRooms = ApiService.getRooms();
                            });
                          }
                        },
                        child: Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          child: Stack(
                            children: [
                              // Gunakan method _buildRoomImage untuk handle gambar
                              _buildRoomImage(room),
                              
                              // Gradient overlay untuk readability text
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  height: 80,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              
                              // Room information
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        room.name,
                                        style: const TextStyle(
                                          color: Colors.white, 
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        room.location,
                                        style: const TextStyle(
                                          color: Colors.white70, 
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.people,
                                            color: Colors.white70,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${room.capacity} Orang',
                                            style: const TextStyle(
                                              color: Colors.white70, 
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              
                              // Status badge di pojok kanan atas
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(room.status),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    _getStatusText(room.status),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
      // Tombol "+" di kanan bawah
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0A3573),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          final result = await Navigator.push(
            context, 
            MaterialPageRoute(
              builder: (_) => AdminRoomManagementScreen(),
            ),
          );
          
          // Refresh data jika ada perubahan
          if (result == true) {
            fetchRooms();
          }
        },
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }

  // Helper method untuk mendapatkan warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method untuk mendapatkan text status
  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'maintenance':
        return 'Maintenance';
      case 'unavailable':
        return 'Tidak Tersedia';
      default:
        return status;
    }
  }
}