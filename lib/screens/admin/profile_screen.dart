
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/models/user.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:rom_app/screens/admin/navbar_admin.dart';

class AdminProfilScreen extends StatefulWidget {
  const AdminProfilScreen({super.key});

  @override
  _AdminProfilScreenState createState() => _AdminProfilScreenState();
}

class _AdminProfilScreenState extends State<AdminProfilScreen> {
  User? _user;
  bool _loading = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _fetchCurrentUser();
  }

  void _fetchCurrentUser() async {
    try {
      User currentUser = await _authService.getCurrentUser();
      setState(() {
        _user = currentUser;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      Fluttertoast.showToast(msg: 'Failed to load user profile');
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      try {
        String url = await _authService.uploadProfilePhoto(File(picked.path));
        setState(() {
          _user = _user!.copyWith(photo: url);
        });
        Fluttertoast.showToast(
          msg: 'Foto profil berhasil diperbarui',
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Gagal upload foto',
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
        print("Upload failed: $e");
      }
    }
  }

  void _logout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  void _openEditProfile() async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AdminEditProfileScreen(user: _user!)),
    );
    if (updated == true) {
      _fetchCurrentUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_user == null) {
      return const Scaffold(
        body: Center(child: Text("Gagal memuat profil")),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 18),
            // Avatar dengan edit icon
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 54,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _user!.photo.isNotEmpty
                      ? NetworkImage(_user!.photo)
                      : const NetworkImage("https://ui-avatars.com/api/?name=Admin"),
                ),
                Positioned(
                  bottom: 0,
                  right: 100 / 2 - 24,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(Icons.edit, size: 22, color: Color(0xFF192965)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _user!.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 4),
            Text(
              _user!.email,
              style: const TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: const Text(
                'Setting',
                style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF192965)),
              title: const Text('Edit Profil', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: _openEditProfile,
              horizontalTitleGap: 0,
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red)),
              onTap: _logout,
              horizontalTitleGap: 0,
            ),
          ],
        ),
      ),
      bottomNavigationBar: const NavBar(currentIndex: 2),
    );
  }
}

// Edit Profile Screen untuk Admin
class AdminEditProfileScreen extends StatefulWidget {
  final User user;
  const AdminEditProfileScreen({super.key, required this.user});
  
  @override
  State<AdminEditProfileScreen> createState() => _AdminEditProfileScreenState();
}

class _AdminEditProfileScreenState extends State<AdminEditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  String _password = '';
  String _confirmPassword = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _email = widget.user.email;
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.isNotEmpty && _password != _confirmPassword) {
      Fluttertoast.showToast(msg: "Password tidak cocok");
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService().updateProfile(
        name: _name,
        email: _email,
        password: _password.isNotEmpty ? _password : null,
      );
      Fluttertoast.showToast(msg: "Profil berhasil diubah");
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      Fluttertoast.showToast(msg: "Gagal menyimpan profil");
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Informasi Profil"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {}, 
          ),
        ],
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const SizedBox(height: 12),
              const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _name,
                decoration: _inputDecoration(),
                onChanged: (v) => _name = v,
                validator: (v) => v!.isEmpty ? "Nama tidak boleh kosong" : null,
              ),
              const SizedBox(height: 18),
              const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                initialValue: _email,
                decoration: _inputDecoration(),
                onChanged: (v) => _email = v,
                validator: (v) => v!.isEmpty ? "Email tidak boleh kosong" : null,
              ),
              const SizedBox(height: 18),
              const Text("Password", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _inputDecoration(),
                obscureText: true,
                onChanged: (v) => _password = v,
              ),
              const SizedBox(height: 18),
              const Text("Konfirmasi Password", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              TextFormField(
                decoration: _inputDecoration(),
                obscureText: true,
                onChanged: (v) => _confirmPassword = v,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _loading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF192965),
                  minimumSize: const Size.fromHeight(45),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _loading
                  ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text("Save Changes"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
    filled: true,
    fillColor: const Color(0xFFF7F7FA),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
  );
}