
import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/screens/user/room_booking.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});

  // Widget untuk menampilkan gambar ruangan dengan fallback ke default
  Widget _buildRoomImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 220,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 220,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Color(0xFF222B45),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Jika gagal load dari network, gunakan gambar default dari assets
        return Image.asset(
          'assets/images/default.jpeg',
          height: 220,
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
      height: 220,
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
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
              // Table
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              // Chairs
              Positioned(
                left: 20,
                top: 15,
                child: Container(
                  width: 12,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                top: 15,
                child: Container(
                  width: 12,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                bottom: 15,
                child: Container(
                  width: 12,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Positioned(
                right: 20,
                bottom: 15,
                child: Container(
                  width: 12,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Ruang Meeting',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gambar Default',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk mendapatkan icon fasilitas
  IconData _getFacilityIcon(String facilityName) {
    switch (facilityName.toLowerCase()) {
      case 'wifi':
        return Icons.wifi;
      case 'proyektor':
      case 'projector':
        return Icons.videocam;
      case 'ac':
      case 'air conditioning':
        return Icons.ac_unit;
      case 'whiteboard':
      case 'papan tulis':
        return Icons.dashboard;
      case 'sound system':
      case 'sistem suara':
        return Icons.volume_up;
      case 'microphone':
      case 'mikrofon':
        return Icons.mic;
      case 'computer':
      case 'komputer':
        return Icons.computer;
      case 'video conference':
        return Icons.video_call;
      case 'flip chart':
        return Icons.flip_to_front;
      case 'tv':
      case 'television':
        return Icons.tv;
      case 'printer':
        return Icons.print;
      default:
        return Icons.star;
    }
  }

  // Helper method untuk mendapatkan warna status ruangan
  Color _getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return Colors.green;
      case 'maintenance':
        return Colors.orange;
      case 'unavailable':
        return Colors.red;
      default:
        return Colors.green;
    }
  }

  // Helper method untuk mendapatkan text status ruangan
  String _getStatusText(String? status) {
    switch (status?.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'maintenance':
        return 'Maintenance';
      case 'unavailable':
        return 'Tidak Tersedia';
      default:
        return 'Tersedia';
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Detail Ruangan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF222B45),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222B45)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          // Gambar ruangan dengan overlay status
          Stack(
            children: [
              _buildRoomImage(room.photoUrl),
              // Status badge di pojok kanan atas
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(room.status),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    _getStatusText(room.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Info Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama ruangan
                      Text(
                        room.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: Color(0xFF222B45),
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Lokasi
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on, 
                              size: 20, 
                              color: Colors.blueGrey[600],
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                room.location,
                                style: TextStyle(
                                  fontSize: 16, 
                                  color: Colors.blueGrey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      // Kapasitas
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF222B45).withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people, 
                              size: 20, 
                              color: const Color(0xFF222B45),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Kapasitas: ${room.capacity} Orang',
                              style: const TextStyle(
                                fontSize: 16, 
                                color: Color(0xFF222B45),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fasilitas Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: const Color(0xFF222B45),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Fasilitas',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18,
                              color: Color(0xFF222B45),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF222B45).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${room.facilities.length} item',
                              style: const TextStyle(
                                color: Color(0xFF222B45),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      if (room.facilities.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Tidak ada fasilitas khusus',
                                      style: TextStyle(
                                        color: Colors.grey[600],
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    // Debug info - hapus setelah testing
                                    const SizedBox(height: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Column(
                          children: [
                            // Debug info - hapus setelah testing
                            Container(
                              padding: const EdgeInsets.all(8),
                              margin: const EdgeInsets.only(bottom: 8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'DEBUG: Found ${room.facilities.length} facilities: ${room.facilities.join(", ")}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: room.facilities.map((facility) {
                                print('Processing facility: $facility (${facility.runtimeType})');
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF222B45),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF222B45).withOpacity(0.2),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _getFacilityIcon(facility.toString()),
                                        size: 16,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        facility.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Deskripsi Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            color: const Color(0xFF222B45),
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontWeight: FontWeight.bold, 
                              fontSize: 18,
                              color: Color(0xFF222B45),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Text(
                          room.description?.isNotEmpty == true 
                              ? room.description!
                              : 'Tidak ada deskripsi khusus untuk ruangan ini.',
                          style: TextStyle(
                            fontSize: 15, 
                            color: room.description?.isNotEmpty == true 
                                ? Colors.black87 
                                : Colors.grey[600],
                            height: 1.5,
                            fontStyle: room.description?.isNotEmpty == true 
                                ? FontStyle.normal 
                                : FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Tombol Pinjam
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF222B45).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: room.status?.toLowerCase() == 'available' 
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomBookingScreen(
                                  roomId: room.id,
                                  roomName: room.name,
                                  roomCapacity: room.capacity,
                                  roomLocation: room.location,
                                  roomDescription: room.description,
                                  roomPhotoUrl: room.photoUrl,
                                  roomCreatedAt: room.createdAt,
                                  roomFacilities: room.facilities,
                                ),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: room.status?.toLowerCase() == 'available' 
                          ? const Color(0xFF222B45)
                          : Colors.grey[400],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          room.status?.toLowerCase() == 'available' 
                              ? Icons.calendar_month 
                              : Icons.block,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          room.status?.toLowerCase() == 'available' 
                              ? 'Pinjam Ruangan'
                              : 'Tidak Tersedia',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}