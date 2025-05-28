import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/screens/admin/room_detail_screen.dart';

class AdminRoomManagementScreen extends StatefulWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  State<AdminRoomManagementScreen> createState() => _AdminRoomManagementScreenState();
}

class _AdminRoomManagementScreenState extends State<AdminRoomManagementScreen> {
  List<Room> _rooms = [];
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  String _name = '';
  int _capacity = 0;
  String _location = '';
  String _description = '';
  String _status = 'available';
  String _imageUrl = ''; 

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

  void _addRoom() async {
    if (_formKey.currentState!.validate()) {
      Room newRoom = Room(
        id: 0,
        name: _name,
        location: _location,
        description: _description,
        capacity: _capacity,
        status: _status, // Added missing required parameter
        photoUrl: _imageUrl, // Assuming imageUrl is optional
        createdAt: DateTime.now(),
        
      );
      
      try {
        // Implement createRoom method since it doesn't exist
        await _apiService.createRoom({
          'name': newRoom.name,
          'location': newRoom.location,
          'description': newRoom.description,
          'capacity': newRoom.capacity,
          'status': newRoom.status,
          'imageUrl': newRoom.photoUrl,
          'createdAt': newRoom.createdAt,
        });
        
        _fetchRooms();
        _formKey.currentState!.reset();
        Fluttertoast.showToast(msg: 'Room created successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to create room: $e');
      }
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
                    decoration: const InputDecoration(labelText: 'Location'),
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
                  const SizedBox(height: 16.0),
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
                          onPressed: () async {
                            try {
                              // Implement deleteRoom method
                              await _apiService.deleteRoom(room.id);
                              _fetchRooms();
                              Fluttertoast.showToast(msg: 'Room deleted successfully');
                            } catch (e) {
                              Fluttertoast.showToast(msg: 'Failed to delete room: $e');
                            }
                          },
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
