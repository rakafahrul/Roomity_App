import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/utils/image_helper.dart';

class AdminRoomManagementScreen extends StatefulWidget {
  const AdminRoomManagementScreen({super.key});

  @override
  State<AdminRoomManagementScreen> createState() => _AdminRoomManagementScreenState();
}

class _AdminRoomManagementScreenState extends State<AdminRoomManagementScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _capacityController = TextEditingController();
  
  String _status = 'available';
  double? _latitude;
  double? _longitude;
  List<String> _selectedFacilities = [];
  final ApiService _apiService = ApiService();
  List<Facility> _availableFacilities = [];
  XFile? _pickedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadFacilities();
  }

  Future<void> _loadFacilities() async {
    try {
      final facilities = await _apiService.getFacilities();
      setState(() {
        _availableFacilities = facilities;
      });
    } catch (e) {
      print('Error loading facilities: $e');
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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _pickedFile = pickedFile;
        });
        Fluttertoast.showToast(msg: 'Foto dipilih: ${pickedFile.name}');
      }
    } catch (e) {
      print('Error picking image: $e');
      Fluttertoast.showToast(msg: 'Gagal memilih gambar: $e');
    }
  }

  Future<String?> _convertImageToBase64(XFile? imageFile) async {
    if (imageFile == null) return null;

    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      print('Error converting image to base64: $e');
      return null;
    }
  }

  Future<void> _addRoomWithMultipart() async {
    final uri = Uri.parse('${ApiService.baseUrl}/rooms');
    final request = http.MultipartRequest('POST', uri);

    print('=== DEBUG ===');
    print('Endpoint: $uri');
    print('Name: ${_nameController.text.trim()}');
    print('Location: ${_locationController.text.trim()}');
    print('Capacity: ${_capacityController.text.trim()}');
    print('Selected Facilities: $_selectedFacilities');
    print('Facilities Count: ${_selectedFacilities.length}');
    print('Facilities JSON: ${jsonEncode(_selectedFacilities)}');
    print('Has Photo: ${_pickedFile != null}');

    request.fields.addAll({
      'Name': _nameController.text.trim(),
      'Location': _locationController.text.trim(),
      'Description': _descriptionController.text.trim(),
      'Capacity': _capacityController.text.trim(),
      'Status': _status,
      'Latitude': _latitude.toString(),
      'Longitude': _longitude.toString(),
    });

    
    String facilitiesJson = jsonEncode(_selectedFacilities);
    request.fields['Facilities'] = facilitiesJson;
    print('Facilities sent to server: $facilitiesJson');
    
    
    try {
      if (_pickedFile != null) {
        
        final bytes = await _pickedFile!.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'Photo',
          bytes,
          filename: _pickedFile!.name.isNotEmpty ? _pickedFile!.name : 'image.jpg',
        );
        request.files.add(multipartFile);
        print('Added user photo: ${_pickedFile!.name}');
      } else {
        
        await _addDefaultPhoto(request);
      }
    } catch (e) {
      print('Error adding photo, using default: $e');
      await _addDefaultPhoto(request);
    }

    print('Request fields: ${request.fields}');
    print('Request files: ${request.files.length}');

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== RESPONSE DEBUG ===');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');
      print('Headers: ${response.headers}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Room created successfully');
        
        
        try {
          final responseData = jsonDecode(response.body);
          print('Created room response: $responseData');
          if (responseData['facilities'] != null) {
            print('Server stored facilities as: ${responseData['facilities']}');
            print('Facilities type in response: ${responseData['facilities'].runtimeType}');
          }
        } catch (e) {
          print('Could not parse create response: $e');
        }
        
        await _handleSuccessResponse();
      } else {
        String errorMessage = 'Gagal menambah ruangan';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            
            if (errorData.containsKey('errors')) {
              final errors = errorData['errors'];
              List<String> errorMessages = [];
              
              if (errors is Map) {
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMessages.addAll(value.map((e) => '$key: $e'));
                  }
                });
              }
              
              if (errorMessages.isNotEmpty) {
                errorMessage = errorMessages.join(', ');
              }
            } else {
              errorMessage = errorData['message'] ?? 
                            errorData['error'] ?? 
                            errorData['title'] ?? 
                            'Status: ${response.statusCode}';
            }
          }
        } catch (e) {
          errorMessage = 'Status: ${response.statusCode}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Multipart request failed: $e');
      rethrow;
    }
  }

  Future<void> _addDefaultPhoto(http.MultipartRequest request) async {
    try {
      
      final defaultImageBytes = await _loadDefaultRoomImage();
      
      final multipartFile = http.MultipartFile.fromBytes(
        'Photo',
        defaultImageBytes,
        filename: 'default.png',
      );
      request.files.add(multipartFile);
      print('Added default room image from assets');
    } catch (e) {
      print('Error loading default room image: $e');
      
      final placeholderBytes = _createPlaceholderImage();
      final multipartFile = http.MultipartFile.fromBytes(
        'Photo',
        placeholderBytes,
        filename: 'placeholder.png',
      );
      request.files.add(multipartFile);
      print('Added generated placeholder image');
    }
  }

  Future<List<int>> _loadDefaultRoomImage() async {
    try {
      
      final byteData = await rootBundle.load('assets/images/default.jpeg');
      return byteData.buffer.asUint8List();
    } catch (e) {
      print('Error loading default.png: $e');
      
      try {
        final byteData = await rootBundle.load('assets/images/default_room.jpg');
        return byteData.buffer.asUint8List();
      } catch (e2) {
        try {
          final byteData = await rootBundle.load('assets/images/default.jpeg');
          return byteData.buffer.asUint8List();
        } catch (e3) {
          
          print('All default images failed, using generated placeholder');
          return _createDefaultRoomImageBytes();
        }
      }
    }
  }

  List<int> _createDefaultRoomImageBytes() {
    
    final svgString = '''
    <svg width="400" height="300" xmlns="http://www.w3.org/2000/svg">
      <!-- Background -->
      <rect width="400" height="300" fill="#f5f5f5"/>
      
      <!-- Floor -->
      <rect x="0" y="250" width="400" height="50" fill="#d0d0d0"/>
      
      <!-- Back wall -->
      <rect x="0" y="0" width="400" height="250" fill="#e8e8e8"/>
      
      <!-- Table -->
      <rect x="150" y="180" width="100" height="60" fill="#8b4513" rx="5"/>
      <rect x="140" y="175" width="120" height="10" fill="#654321"/>
      
      <!-- Chairs -->
      <rect x="120" y="160" width="25" height="40" fill="#333" rx="3"/>
      <rect x="255" y="160" width="25" height="40" fill="#333" rx="3"/>
      <rect x="120" y="220" width="25" height="40" fill="#333" rx="3"/>
      <rect x="255" y="220" width="25" height="40" fill="#333" rx="3"/>
      
      <!-- Window -->
      <rect x="50" y="50" width="80" height="60" fill="#87ceeb" stroke="#666" stroke-width="2"/>
      <line x1="90" y1="50" x2="90" y2="110" stroke="#666" stroke-width="1"/>
      <line x1="50" y1="80" x2="130" y2="80" stroke="#666" stroke-width="1"/>
      
      <!-- Door -->
      <rect x="320" y="200" width="60" height="50" fill="#8b4513" stroke="#654321" stroke-width="2"/>
      <circle cx="360" cy="225" r="3" fill="#ffd700"/>
      
      <!-- Text -->
      <text x="200" y="40" text-anchor="middle" fill="#666" font-family="Arial" font-size="16">Meeting Room</text>
    </svg>
    ''';
    
    
    return utf8.encode(svgString);
  }

  List<int> _createPlaceholderImage() {
    
    return [
      137, 80, 78, 71, 13, 10, 26, 10, 
      0, 0, 0, 13, 
      73, 72, 68, 82, 
      0, 0, 0, 1, 
      0, 0, 0, 1, 
      8, 6, 
      0, 0, 0, 
      31, 21, 196, 164, 
      0, 0, 0, 13, 
      73, 68, 65, 84, 
      120, 156, 99, 248, 15, 0, 0, 1, 0, 1, 
      94, 96, 130, 52, 
      0, 0, 0, 0, 
      73, 69, 78, 68, 
      174, 66, 96, 130 
    ];
  }

  Future<void> _handleSuccessResponse() async {
    Fluttertoast.showToast(
      msg: 'Ruangan berhasil ditambahkan',
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
    
    
    print('=== CHECKING NEWLY CREATED ROOM ===');
    try {
      final updatedRooms = await ApiService.getRooms();
      print('Total rooms after creation: ${updatedRooms.length}');
      
      
      final newRoomName = _nameController.text.trim();
      final newRoom = updatedRooms.where((room) => room.name == newRoomName).lastOrNull;
      
      if (newRoom != null) {
        print('Found newly created room:');
        print('- ID: ${newRoom.id}');
        print('- Name: ${newRoom.name}');
        print('- Facilities: ${newRoom.facilities}');
        print('- Facilities count: ${newRoom.facilities.length}');
      } else {
        print('Could not find newly created room with name: $newRoomName');
      }
    } catch (e) {
      print('Error fetching updated rooms: $e');
    }
    
    
    _nameController.clear();
    _locationController.clear();
    _descriptionController.clear();
    _capacityController.clear();
    setState(() {
      _selectedFacilities.clear();
      _pickedFile = null;
      _latitude = null;
      _longitude = null;
      _status = 'available';
    });
    
    Navigator.pop(context, true);
  }

  Future<void> _addRoom() async {
    if (!_formKey.currentState!.validate()) {
      Fluttertoast.showToast(msg: 'Lengkapi semua form yang diperlukan');
      return;
    }

    if (_latitude == null || _longitude == null) {
      Fluttertoast.showToast(msg: 'Pilih lokasi ruangan pada peta');
      return;
    }

    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah data berikut sudah benar?'),
            const SizedBox(height: 12),
            Text('• Nama: ${_nameController.text}'),
            Text('• Lokasi: ${_locationController.text}'),
            Text('• Kapasitas: ${_capacityController.text} orang'),
            Text('• Status: ${_getStatusText(_status)}'),
            Text('• Fasilitas: ${_selectedFacilities.length} item (${_selectedFacilities.join(", ")})'),
            Text('• Foto: ${_pickedFile != null ? "Upload baru" : "Default"}'),
            Text('• Koordinat: ${_latitude?.toStringAsFixed(4)}, ${_longitude?.toStringAsFixed(4)}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B2447),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ya, Tambah', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _isLoading = true;
    });

    try {
      
      await _addRoomWithMultipart();
    } catch (e) {
      print('Room creation failed: $e');
      
      String errorMessage = 'Gagal menambah ruangan';
      final errorString = e.toString();
      
      if (errorString.contains('photo field is required')) {
        errorMessage = 'Foto wajib diisi. Silakan pilih foto atau coba lagi.';
      } else if (errorString.contains('validation errors')) {
        errorMessage = 'Data tidak valid. Periksa kembali form Anda.';
      } else if (errorString.contains('connection')) {
        errorMessage = 'Koneksi ke server gagal. Periksa jaringan Anda.';
      } else {
        errorMessage = errorString.replaceAll('Exception: ', '');
      }
      
      Fluttertoast.showToast(
        msg: errorMessage,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        toastLength: Toast.LENGTH_LONG,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getStatusText(String status) {
    switch (status) {
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

  void _openMapPicker() async {
    LatLng defaultLatLng = const LatLng(-8.165766, 113.716330); 
    LatLng selectedLatLng = _latitude != null && _longitude != null 
        ? LatLng(_latitude!, _longitude!) 
        : defaultLatLng;

    final picked = await showDialog<LatLng>(
      context: context,
      builder: (context) {
        LatLng tempLatLng = selectedLatLng;

        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text("Pilih Lokasi Ruangan"),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: selectedLatLng,
                  initialZoom: 16,
                  onTap: (tapPos, latlng) {
                    setDialogState(() => tempLatLng = latlng);
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 40,
                        height: 40,
                        point: tempLatLng,
                        child: const Icon(
                          Icons.location_on, 
                          color: Colors.red, 
                          size: 40
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context), 
                child: const Text('Batal')
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B2447),
                ),
                onPressed: () => Navigator.pop(context, tempLatLng), 
                child: const Text('Pilih Lokasi Ini', style: TextStyle(color: Colors.white))
              ),
            ],
          ),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _latitude = picked.latitude;
        _longitude = picked.longitude;
      });
      Fluttertoast.showToast(msg: 'Lokasi dipilih: ${picked.latitude.toStringAsFixed(4)}, ${picked.longitude.toStringAsFixed(4)}');
    }
  }

  Widget _buildImageSection() {
    return Column(
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _pickedFile == null ? Colors.orange : Colors.green,
              width: 2,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: _pickedFile != null
                ? FutureBuilder<Uint8List>(
                    future: _pickedFile!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      } else if (snapshot.hasError) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error, size: 50),
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : Stack(
                    children: [
                      
                      Image.asset(
                        'assets/images/default.jpeg',
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading default.png: $error');
                          return _buildDefaultRoomPlaceholder();
                        },
                      ),
                      Positioned(
                        bottom: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Gambar Default',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 8),
        if (_pickedFile == null)
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.orange[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Menggunakan gambar default ruangan. Tap kamera untuk mengubah.',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            if (_pickedFile != null)
              CircleAvatar(
                backgroundColor: Colors.red,
                radius: 18,
                child: IconButton(
                  icon: const Icon(Icons.delete, size: 16, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _pickedFile = null;
                    });
                    Fluttertoast.showToast(msg: 'Foto dihapus, akan menggunakan gambar default');
                  },
                ),
              ),
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF0B2447),
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultRoomPlaceholder() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 120,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
              
              Container(
                width: 60,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              
              Positioned(
                left: 20,
                top: 15,
                child: Container(
                  width: 12,
                  height: 15,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
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
                    borderRadius: BorderRadius.circular(2),
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
                    borderRadius: BorderRadius.circular(2),
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
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ruang Meeting',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Gambar Default',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? hintText,
    IconData? prefixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            filled: true, 
            fillColor: const Color(0xFFF5F5F5),
            hintText: hintText ?? 'Masukkan $label',
            prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: const Color(0xFF0B2447)) : null,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          validator: validator,
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF0B2447)),
            const SizedBox(width: 8),
            const Text('Koordinat Lokasi', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _openMapPicker,
              icon: const Icon(Icons.map, size: 16),
              label: Text(_latitude != null && _longitude != null 
                  ? 'Ubah Lokasi' 
                  : 'Pilih Lokasi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B2447),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_latitude != null && _longitude != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Lokasi Dipilih',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Latitude: ${_latitude!.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
                Text(
                  'Longitude: ${_longitude!.toStringAsFixed(6)}',
                  style: TextStyle(color: Colors.green[600], fontSize: 12),
                ),
              ],
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red[700], size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Lokasi belum dipilih. Tap "Pilih Lokasi" untuk memilih koordinat ruangan.',
                    style: TextStyle(
                      color: Colors.red[700],
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildFacilitiesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.star, color: Color(0xFF0B2447)),
            const SizedBox(width: 8),
            const Text('Fasilitas', style: TextStyle(fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(
              '${_selectedFacilities.length} dipilih',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_availableFacilities.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _availableFacilities.map((facility) {
              final isSelected = _selectedFacilities.contains(facility.name);
              return GestureDetector(
                onTap: () => _toggleFacility(facility.name),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        backgroundColor: isSelected 
                            ? const Color(0xFF0B2447) 
                            : const Color(0xFFEAF2FB),
                        radius: 28,
                        child: Icon(
                          _getFacilityIcon(facility.name), 
                          color: isSelected ? Colors.white : const Color(0xFF0B2447),
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 70,
                        child: Text(
                          facility.name, 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected ? const Color(0xFF0B2447) : Colors.grey[600],
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  IconData _getFacilityIcon(String facilityName) {
    switch (facilityName.toLowerCase()) {
      case 'projector':
      case 'proyektor':
        return Icons.videocam;
      case 'ac':
      case 'air conditioning':
        return Icons.ac_unit;
      case 'wifi':
        return Icons.wifi;
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

  Widget _buildStatusDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF0B2447)),
            const SizedBox(width: 8),
            const Text('Status Ruangan', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _status,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF0B2447)),
              items: const [
                DropdownMenuItem(
                  value: 'available', 
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 8),
                      Text('Tersedia'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'maintenance', 
                  child: Row(
                    children: [
                      Icon(Icons.build, color: Colors.orange, size: 16),
                      SizedBox(width: 8),
                      Text('Maintenance'),
                    ],
                  ),
                ),
                DropdownMenuItem(
                  value: 'unavailable', 
                  child: Row(
                    children: [
                      Icon(Icons.cancel, color: Colors.red, size: 16),
                      SizedBox(width: 8),
                      Text('Tidak Tersedia'),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _status = value;
                  });
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8EDF1),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE8EDF1),
        elevation: 0,
        leading: const BackButton(color: Color(0xFF0B2447)),
        centerTitle: true,
        title: const Text(
          'Tambah Ruangan', 
          style: TextStyle(color: Color(0xFF0B2447), fontWeight: FontWeight.bold)
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Color(0xFF0B2447)),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Row(
                    children: [
                      Icon(Icons.info, color: Color(0xFF0B2447)),
                      SizedBox(width: 8),
                      Text('Panduan'),
                    ],
                  ),
                  content: const Text(
                    'Pastikan semua data telah diisi dengan benar:\n\n'
                    '• Nama ruangan harus unik\n'
                    '• Pilih lokasi di peta dengan tap\n'
                    '• Upload foto ruangan (opsional)\n'
                    '• Pilih fasilitas yang tersedia\n'
                    '• Set status ruangan\n\n'
                    'Foto akan menggunakan gambar default jika tidak dipilih.'
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Mengerti'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildImageSection(),
              const SizedBox(height: 16),
              
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFormField(
                        label: 'Nama Ruang',
                        controller: _nameController,
                        prefixIcon: Icons.meeting_room,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Masukkan nama ruangan';
                          if (value!.length < 3) return 'Nama ruangan minimal 3 karakter';
                          return null;
                        },
                        hintText: 'Contoh: Meeting Room A',
                      ),
                      
                      _buildFormField(
                        label: 'Lokasi',
                        controller: _locationController,
                        prefixIcon: Icons.location_city,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Masukkan lokasi ruangan';
                          if (value!.length < 5) return 'Lokasi minimal 5 karakter';
                          return null;
                        },
                        hintText: 'Contoh: Lantai 2, Gedung A',
                      ),
                      
                      _buildFormField(
                        label: 'Kapasitas',
                        controller: _capacityController,
                        prefixIcon: Icons.people,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Masukkan kapasitas ruangan';
                          final capacity = int.tryParse(value!);
                          if (capacity == null) return 'Masukkan angka yang valid';
                          if (capacity <= 0) return 'Kapasitas harus lebih dari 0';
                          if (capacity > 1000) return 'Kapasitas terlalu besar';
                          return null;
                        },
                        hintText: 'Contoh: 20',
                      ),
                      
                      _buildStatusDropdown(),
                      
                      _buildLocationSection(),
                      
                      _buildFacilitiesSection(),
                      
                      _buildFormField(
                        label: 'Deskripsi',
                        controller: _descriptionController,
                        prefixIcon: Icons.description,
                        maxLines: 3,
                        validator: (value) {
                          if (value?.isEmpty == true) return 'Masukkan deskripsi ruangan';
                          if (value!.length < 10) return 'Deskripsi minimal 10 karakter';
                          return null;
                        },
                        hintText: 'Deskripsi detail tentang ruangan, fasilitas, dan kegunaan...',
                      ),
                      
                      const SizedBox(height: 8),
                      
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0B2447),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 2,
                          ),
                          onPressed: _isLoading ? null : _addRoom,
                          child: _isLoading 
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Menambahkan...', style: TextStyle(fontSize: 16)),
                                  ],
                                )
                              : const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, size: 20),
                                    SizedBox(width: 8),
                                    Text('Tambah Ruangan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _capacityController.dispose();
    super.dispose();
  }
}