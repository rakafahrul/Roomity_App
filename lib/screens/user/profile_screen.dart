import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:rom_app/models/user.dart';

class UserProfilScreen extends StatefulWidget {
  const UserProfilScreen({super.key});

  @override
  _UserProfilScreenState createState() => _UserProfilScreenState();
}

class _UserProfilScreenState extends State<UserProfilScreen> {
  late User _user;
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _photo = '';
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
        _name = _user.name;
        _email = _user.email;
        _photo = _user.photo;
      });
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to load user profile');
    }
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _authService.updateProfile(
          name: _name,
          email: _email,
          photo: _photo,
        );
        Fluttertoast.showToast(msg: 'Profile updated successfully');
      } catch (e) {
        Fluttertoast.showToast(msg: 'Failed to update profile');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Name'),
                initialValue: _name,
                onChanged: (value) => _name = value,
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                initialValue: _email,
                onChanged: (value) => _email = value,
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Photo URL'),
                initialValue: _photo,
                onChanged: (value) => _photo = value,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _updateProfile,
                child: const Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
