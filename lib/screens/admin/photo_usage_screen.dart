import 'package:flutter/material.dart';
import 'package:rom_app/models/photo_usage.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminPhotoUsageScreen extends StatefulWidget {
  final int bookingId;

  const AdminPhotoUsageScreen({required this.bookingId, super.key});

  @override
  _AdminPhotoUsageScreenState createState() => _AdminPhotoUsageScreenState();
}

class _AdminPhotoUsageScreenState extends State<AdminPhotoUsageScreen> {
  List<PhotoUsage> _photos = [];
  final TextEditingController _photoUrlController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final photos = await _apiService.getPhotos(widget.bookingId);
      if (mounted) {
        setState(() => _photos = photos);
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memuat foto: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _uploadPhoto() async {
    final photoUrl = _photoUrlController.text.trim();
    if (photoUrl.isEmpty) {
      _showError('Masukkan URL foto');
      return;
    }

    if (!mounted) return;
    setState(() => _isLoading = true);
    
    try {
      await _apiService.uploadPhoto(widget.bookingId, photoUrl);
      await _loadPhotos();
      _photoUrlController.clear();
      if (mounted) {
        _showSuccess('Foto berhasil diupload');
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal upload foto: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deletePhoto(PhotoUsage photo) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: const Text('Yakin ingin menghapus foto ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isLoading = true);
      try {
        await _apiService.deletePhoto(photo.photoId);
        await _loadPhotos();
        if (mounted) {
          _showSuccess('Foto berhasil dihapus');
        }
      } catch (e) {
        if (mounted) {
          _showError('Gagal menghapus foto: $e');
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
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

  void _previewPhoto(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Preview Foto')),
          body: Center(
            child: Image.network(
              url,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Center(
                child: Text('Gagal memuat gambar'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Foto')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextFormField(
                    controller: _photoUrlController,
                    decoration: InputDecoration(
                      labelText: 'URL Foto',
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: _photoUrlController.clear,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _uploadPhoto,
                    child: const Text('Upload Foto'),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _photos.isEmpty
                        ? const Center(child: Text('Tidak ada foto'))
                        : ListView.builder(
                            itemCount: _photos.length,
                            itemBuilder: (context, index) {
                              final photo = _photos[index];
                              return Card(
                                child: ListTile(
                                  title: Text('Foto ${index + 1}'),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(photo.photoUrl),
                                      const SizedBox(height: 4),
                                      InkWell(
                                        onTap: () => _previewPhoto(photo.photoUrl),
                                        child: const Text(
                                          'Lihat Foto',
                                          style: TextStyle(
                                            color: Colors.blue,
                                            decoration: TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: _isLoading 
                                        ? null 
                                        : () => _deletePhoto(photo),
                                  ),
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

  @override
  void dispose() {
    _photoUrlController.dispose();
    super.dispose();
  }
}