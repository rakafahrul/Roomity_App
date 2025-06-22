import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/services/api_service.dart';

class EditRoomScreen extends StatefulWidget {
  final Room room;

  const EditRoomScreen({Key? key, required this.room}) : super(key: key);

  @override
  State<EditRoomScreen> createState() => _EditRoomScreenState();
}

class _EditRoomScreenState extends State<EditRoomScreen> {
  final _formKey = GlobalKey<FormState>();
  final _primaryColor = const Color(0xFF222B45);
  final _backgroundColor = const Color(0xFFF8F9FA);

  late TextEditingController _nameController;
  late TextEditingController _locationController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;

  List<Facility> _availableFacilities = [];
  late List<String> _selectedFacilities;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room.name);
    _locationController = TextEditingController(text: widget.room.location);
    _capacityController = TextEditingController(text: widget.room.capacity.toString());
    _descriptionController = TextEditingController(text: widget.room.description);
    _selectedFacilities = List<String>.from(widget.room.facilities);
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await ApiService().getFacilities();
      setState(() {
        _availableFacilities = facilities;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal memuat fasilitas: $e');
    }
  }

  void _toggleFacility(String facilityName) {
    setState(() {
      if (_selectedFacilities.contains(facilityName)) {
        _selectedFacilities.remove(facilityName);
      } else {
        _selectedFacilities.add(facilityName);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedRoom = {
        "id": widget.room.id,
        "name": _nameController.text.trim(),
        "location": _locationController.text.trim(),
        "capacity": int.parse(_capacityController.text.trim()),
        "description": _descriptionController.text.trim(),
        "photoUrl": widget.room.photoUrl,
        "latitude": widget.room.latitude,
        "longitude": widget.room.longitude,
        "status": widget.room.status,
        "createdAt": widget.room.createdAt is DateTime 
          ? (widget.room.createdAt as DateTime).toIso8601String()
          : widget.room.createdAt,
        "facilities": _selectedFacilities,
      };

      await ApiService().updateRoom(widget.room.id, updatedRoom);

      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Sukses'),
          content: const Text('Ruangan berhasil diperbarui'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context, true);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Gagal Memperbarui'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
        return Image.asset(
          'assets/images/default.jpeg',
          height: 220,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultRoomPlaceholder();
          },
        );
      },
    );
  }

  Widget _buildDefaultRoomPlaceholder() {
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.meeting_room, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Gambar Tidak Tersedia',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFacilityIcon(String facilityName) {
    switch (facilityName.toLowerCase()) {
      case 'wifi': return Icons.wifi;
      case 'proyektor': return Icons.videocam;
      case 'ac': return Icons.ac_unit;
      case 'whiteboard': return Icons.dashboard;
      case 'sound system': return Icons.volume_up;
      case 'microphone': return Icons.mic;
      case 'computer': return Icons.computer;
      case 'video conference': return Icons.video_call;
      case 'tv': return Icons.tv;
      case 'printer': return Icons.print;
      case 'kamera': return Icons.camera_alt;
      default: return Icons.star;
    }
  }

  Widget _buildFacilityChip(Facility facility) {
    final isSelected = _selectedFacilities.contains(facility.name);
    return GestureDetector(
      onTap: () => _toggleFacility(facility.name),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? _primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected ? [
            BoxShadow(
              color: _primaryColor.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getFacilityIcon(facility.name),
              size: 16,
              color: isSelected ? Colors.white : _primaryColor,
            ),
            const SizedBox(width: 6),
            Text(
              facility.name,
              style: TextStyle(
                color: isSelected ? Colors.white : _primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
      ),
      style: TextStyle(color: _primaryColor),
      validator: (value) => value == null || value.isEmpty ? 'Field tidak boleh kosong' : null,
    );
  }

  Widget _buildFormSection(String label, TextEditingController controller, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _primaryColor,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(controller, 'Masukkan $label', maxLines: maxLines),
        const SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Edit Ruangan",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF222B45),
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: _primaryColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF222B45)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              children: [
                _buildRoomImage(widget.room.photoUrl),
                Positioned(
                  right: 20,
                  bottom: 10,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(Icons.edit, color: _primaryColor),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFormSection('Nama Ruang', _nameController),
                    _buildFormSection('Lokasi', _locationController),
                    _buildFormSection('Kapasitas', _capacityController),
                    
                    Text(
                      "Fasilitas", 
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: _primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableFacilities
                          .map((facility) => _buildFacilityChip(facility))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    
                    _buildFormSection('Deskripsi', _descriptionController, maxLines: 4),
                    const SizedBox(height: 32),
                    
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.save, size: 20),
                                  SizedBox(width: 8),
                                  Text('Simpan Perubahan', style: TextStyle(fontSize: 16)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}