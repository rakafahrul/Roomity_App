import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/models/room_facility.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminRoomDetailScreen extends StatefulWidget {
  final Room room;

  const AdminRoomDetailScreen({required this.room, super.key});

  @override
  _AdminRoomDetailScreenState createState() => _AdminRoomDetailScreenState();
}

class _AdminRoomDetailScreenState extends State<AdminRoomDetailScreen> {
  List<Facility> _facilities = [];
  List<RoomFacility> _roomFacilities = [];
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  int _capacity = 0;
  String _location = '';
  String _description = '';
  String _status = 'available';
  String _imageUrl = '';
  int? _selectedFacilityId;
  bool _isLoading = false;
  final ApiService _apiService = ApiService(); // Instance of ApiService

  @override
  void initState() {
    super.initState();
    _loadRoomData();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final facilities = await _apiService.getFacilities();
      final roomFacilities = await ApiService.getRoomFacilities(widget.room.id);
      if (mounted) {
        setState(() {
          _facilities = facilities;
          _roomFacilities = roomFacilities;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to load data: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _loadRoomData() {
    setState(() {
      _name = widget.room.name;
      _capacity = widget.room.capacity;
      _location = widget.room.location;
      _description = widget.room.description ?? '';
      _status = widget.room.status;
    });
  }

  Future<void> _updateRoom() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedRoom = Room(
          id: widget.room.id,
          name: _name,
          location: _location,
          description: _description,
          capacity: _capacity,
          status: _status, // Tambahkan status
          photoUrl: widget.room.photoUrl, // Assuming imageUrl is not editable
          createdAt: widget.room.createdAt,
        );
        
        await _apiService.updateRoom(updatedRoom.id, {
          'name': updatedRoom.name,
          'location': updatedRoom.location,
          'description': updatedRoom.description,
          'capacity': updatedRoom.capacity,
          'status': updatedRoom.status,
          'image_url': updatedRoom.photoUrl, // Assuming imageUrl is not editable
          'created_at': updatedRoom.createdAt,
        });
        
        if (mounted) {
          _showSuccess('Room updated successfully');
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          _showError('Failed to update room: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _addRoomFacility() async {
    if (_selectedFacilityId == null) {
      _showError('Select a facility');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await _apiService.createRoomFacility({
        'room_id': widget.room.id,
        'facility_id': _selectedFacilityId!,
      });
      await _fetchData();
      if (mounted) {
        _showSuccess('Facility added successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to add facility: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _removeRoomFacility(int facilityId) async {
    setState(() => _isLoading = true);
    try {
      await _apiService.deleteRoomFacility(widget.room.id, facilityId);
      await _fetchData();
      if (mounted) {
        _showSuccess('Facility removed successfully');
      }
    } catch (e) {
      if (mounted) {
        _showError('Failed to remove facility: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  void _showSuccess(String message) {
    Fluttertoast.showToast(
      msg: message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Room Name'),
                          initialValue: _name,
                          onChanged: (value) => _name = value,
                          validator: (value) => value!.isEmpty ? 'Enter room name' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Capacity'),
                          initialValue: _capacity.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => _capacity = int.tryParse(value) ?? 0,
                          validator: (value) => value!.isEmpty ? 'Enter capacity' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Location'),
                          initialValue: _location,
                          onChanged: (value) => _location = value,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Description'),
                          initialValue: _description,
                          onChanged: (value) => _description = value,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField(
                          decoration: const InputDecoration(labelText: 'Status'),
                          value: _status,
                          items: const [
                            DropdownMenuItem(value: 'available', child: Text('Available')),
                            DropdownMenuItem(value: 'unavailable', child: Text('Unavailable')),
                          ],
                          onChanged: (value) => setState(() => _status = value!),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _updateRoom,
                            child: const Text('Update Room'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text('Room Facilities', style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField(
                    decoration: const InputDecoration(labelText: 'Add Facility'),
                    value: _selectedFacilityId,
                    items: _facilities.map((facility) => DropdownMenuItem(
                      value: facility.id,
                      child: Text(facility.name),
                    )).toList(),
                    onChanged: (value) => setState(() => _selectedFacilityId = value),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _addRoomFacility,
                      child: const Text('Add Facility'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_roomFacilities.isNotEmpty)
                    ..._roomFacilities.map((roomFacility) {
                      final facility = _facilities.firstWhere(
                        (f) => f.id == roomFacility.facilityId,
                        orElse: () => Facility(id: 0, name: 'Unknown'),
                      );
                      return Card(
                        child: ListTile(
                          title: Text(facility.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: _isLoading 
                                ? null 
                                : () => _removeRoomFacility(roomFacility.facilityId),
                          ),
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}