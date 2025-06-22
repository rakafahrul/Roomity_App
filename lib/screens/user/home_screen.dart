

import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/screens/navbar.dart';
import 'room_detail_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late Future<List<Room>> _roomsFuture;

  @override
  void initState() {
    super.initState();
    _roomsFuture = ApiService.getRooms();
  }

  // Widget untuk menampilkan gambar ruangan dengan fallback ke default
  Widget _buildRoomImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
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
          height: 180,
          width: double.infinity,
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
      height: 180,
      width: double.infinity,
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
            // Header
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
                      'Peminjam',
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
                  'Daftar Ruangan',
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
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada ruangan tersedia',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final rooms = snapshot.data!;
                  return GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: rooms.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // 2 card per row
                      mainAxisSpacing: 18,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85, // Sesuaikan agar card proporsional
                    ),
                    itemBuilder: (context, index) {
                      final room = rooms[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => RoomDetailScreen(room: room),
                            ),
                          );
                        },
                        child: RoomCard(
                          name: room.name,
                          location: room.location,
                          capacity: '${room.capacity} Orang',
                          imageUrl: room.photoUrl,
                          facilities: room.facilities,
                          buildRoomImage: _buildRoomImage, // Pass the method
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
    );
  }
}

class RoomCard extends StatelessWidget {
  final String name;
  final String location;
  final String capacity;
  final String imageUrl;
  final List<String> facilities;
  final Widget Function(String) buildRoomImage; // Add this parameter

  const RoomCard({
    super.key,
    required this.name,
    required this.location,
    required this.capacity,
    required this.imageUrl,
    required this.facilities,
    required this.buildRoomImage, // Add this parameter
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Gambar ruangan dengan fallback
          buildRoomImage(imageUrl),
          
          // Overlay gradient untuk readability text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
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
          
          // Info ruangan
          Positioned(
            left: 12,
            bottom: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
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
                      capacity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    // Fasilitas count indicator
                    if (facilities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white70,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${facilities.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}