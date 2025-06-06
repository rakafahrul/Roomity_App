import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/screens/user/room_booking.dart';

class RoomDetailScreen extends StatelessWidget {
  final Room room;
  const RoomDetailScreen({super.key, required this.room});




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView(
        children: [
          // Gambar ruangan
          Image.network(
            room.photoUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              height: 220,
              color: Colors.grey[300],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18, color: Colors.blueGrey),
                    const SizedBox(width: 4),
                    Text(
                      room.location,
                      style: const TextStyle(fontSize: 15, color: Colors.black54),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Kapasitas: ${room.capacity} Orang',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                SizedBox(height: 6),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: room.facilities.map((f) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Chip(
                        label: Text(f, style: TextStyle(color: Colors.white, fontSize: 12)),
                        backgroundColor: Colors.blueGrey,
                        padding: EdgeInsets.zero,
                      ),
                    )).toList(),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Deskripsi',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  room.description ?? '-',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RoomBookingScreen(roomId: room.id,
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
                      
                      // Navigator.pushNamed(context, '/user/room_booking');
                      // Aksi pinjam, bisa diarahkan ke halaman booking
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF222B45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    
                    ),
                    child: const Text('Pinjam', selectionColor: Colors.white,style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}