import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/screens/admin/room_detail_screen.dart';

// Ganti Google Maps dengan flutter_map
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AdminRoomManagementScreen extends StatefulWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  State<AdminRoomManagementScreen> createState() => _AdminRoomManagementScreenState();
}

class _AdminRoomManagementScreenState extends State<AdminRoomManagementScreen> {
  List<Room> _rooms = [];
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _capacity = 0;
  String _location = '';
  String _description = '';
  String _status = 'available';
  String _imageUrl = '';
  double? _latitude;
  double? _longitude;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _fetchRooms();
  }

  void _fetchRooms() async {
    try {
      List<Room> rooms = await ApiService.getRooms();
      setState(() => _rooms = rooms);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load rooms');
    }
  }

  void _pickLocation() async {
    LatLng initialLatLng = _latitude != null && _longitude != null
        ? LatLng(_latitude!, _longitude!)
        : LatLng(-8.165766246032966, 113.71633087856698); // default -8.165766246032966, 113.71633087856698

    LatLng? picked = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialLatLng: initialLatLng),
      ),
    );
    if (picked != null) {
      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
      });
    }
  }

  void _addRoom() async {
    if (_formKey.currentState!.validate() && _latitude != null && _longitude != null) {
      Room newRoom = Room(
        id: 0,
        name: _name,
        location: _location,
        description: _description,
        capacity: _capacity,
        status: _status,
        photoUrl: _imageUrl,
        createdAt: DateTime.now(),
        facilities: [],
        latitude: _latitude,
        longitude: _longitude,
      );
      try {
        await _apiService.createRoom({
          'name': newRoom.name,
          'location': newRoom.location,
          'description': newRoom.description,
          'capacity': newRoom.capacity,
          'status': newRoom.status,
          'photoUrl': newRoom.photoUrl,
          'latitude': newRoom.latitude,
          'longitude': newRoom.longitude,
          'createdAt': newRoom.createdAt.toIso8601String(),
        });
        _fetchRooms();
        _formKey.currentState!.reset();
        setState(() {
          _latitude = null;
          _longitude = null;
        });
        Fluttertoast.showToast(msg: 'Room created successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to create room: $e');
      }
    } else {
      Fluttertoast.showToast(msg: 'Lengkapi form & lokasi ruangan!');
    }
  }

  void _navigateToRoomDetail(Room room) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminRoomDetailScreen(room: room),
      ),
    ).then((value) {
      if (value == true) {
        _fetchRooms();
      }
    });
  }

  void _deleteRoom(int id) async {
    try {
      await _apiService.deleteRoom(id);
      _fetchRooms();
      Fluttertoast.showToast(msg: 'Room deleted successfully');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to delete room: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Management')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Room Name'),
                    validator: (value) => value!.isEmpty ? 'Enter room name' : null,
                    onChanged: (value) => _name = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Capacity'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Enter capacity' : null,
                    onChanged: (value) => _capacity = int.tryParse(value) ?? 0,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Location (Deskripsi)'),
                    onChanged: (value) => _location = value,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Description'),
                    onChanged: (value) => _description = value,
                  ),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Status'),
                    value: _status,
                    items: const [
                      DropdownMenuItem(value: 'available', child: Text('Available')),
                      DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
                    ],
                    onChanged: (value) => _status = value!,
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    title: Text(_latitude == null
                        ? 'Pilih lokasi di peta'
                        : 'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}'),
                    trailing: ElevatedButton.icon(
                      onPressed: _pickLocation,
                      icon: const Icon(Icons.map),
                      label: const Text('Pilih Lokasi'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _addRoom,
                    child: const Text('Add Room'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _rooms.length,
                itemBuilder: (context, index) {
                  Room room = _rooms[index];
                  return ListTile(
                    title: Text(room.name),
                    subtitle: Text('Capacity: ${room.capacity}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () => _navigateToRoomDetail(room),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () => _deleteRoom(room.id),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Map Picker Screen menggunakan flutter_map (Web Friendly)
class MapPickerScreen extends StatefulWidget {
  final LatLng initialLatLng;
  const MapPickerScreen({super.key, required this.initialLatLng});

  @override
  State<MapPickerScreen> createState() => MapPickerScreenState();
}

class MapPickerScreenState extends State<MapPickerScreen> {
  late LatLng _pickedLatLng;

  @override
  void initState() {
    super.initState();
    _pickedLatLng = widget.initialLatLng;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Pilih Lokasi Room")),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: _pickedLatLng,
              initialZoom: 17,
              onTap: (tapPosition, latlng) {
                setState(() {
                  _pickedLatLng = latlng;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.rom_app',
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    width: 40,
                    height: 40,
                    point: _pickedLatLng,
                    child:  Icon(Icons.location_on, color: Colors.red, size: 40),
                  )
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context, _pickedLatLng);
              },
              icon: const Icon(Icons.check),
              label: const Text("Pilih Lokasi Ini"),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                backgroundColor: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}