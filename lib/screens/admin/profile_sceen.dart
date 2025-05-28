import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/models/user.dart'; // Pastikan model User diimport
import 'package:rom_app/services/auth_service.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  _AdminProfilScreenState createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends State<AdminProfilScreen> {
  User? _user;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _photoController = TextEditingController();
  bool _isLoading = false;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    if (!mounted) return;
    
    setState(() => _isLoading = true);
    try {
      final user = await _authService.getCurrentUser();
      if (mounted) {
        setState(() {
          _user = user;
          _nameController.text = user.name;
          _emailController.text = user.email;
          _photoController.text = user.photo;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Gagal memuat profil: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      if (!mounted) return;
      setState(() => _isLoading = true);
      
      try {
        await _authService.updateProfile(
          name: _nameController.text,
          email: _emailController.text,
          photo: _photoController.text,
        );
        //   _nameController.text,
        //   _emailController.text,
        //   _photoController.text,
        // );
        if (mounted) {
          _showSuccess('Profil berhasil diperbarui');
          await _loadUserProfile(); // Reload data terbaru
        }
      } catch (e) {
        if (mounted) {
          _showError('Gagal memperbarui profil: $e');
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

  void _previewPhoto() {
    if (_photoController.text.isEmpty) return;
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Preview Foto Profil')),
          body: Center(
            child: Image.network(
              _photoController.text,
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
      appBar: AppBar(title: const Text('Profil Admin')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    if (_photoController.text.isNotEmpty)
                      GestureDetector(
                        onTap: _previewPhoto,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(_photoController.text),
                          child: _photoController.text.isEmpty
                              ? const Icon(Icons.person, size: 50)
                              : null,
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nama',
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) => value!.isEmpty ? 'Masukkan nama' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) return 'Masukkan email';
                        if (!value.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _photoController,
                      decoration: InputDecoration(
                        labelText: 'URL Foto Profil',
                        prefixIcon: const Icon(Icons.photo),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _previewPhoto,
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          setState(() {}); // Untuk update preview
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateProfile,
                        child: const Text('Simpan Perubahan'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _photoController.dispose();
    super.dispose();
  }
}