import 'package:flutter/material.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  _AdminLoginScreenState createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      bool success = await AuthService.login(_email, _password);
      if (success) {
        Navigator.pushReplacementNamed(context, '/admin/dashboard');
      } else {
        Fluttertoast.showToast(msg: 'Login failed');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) => value!.isEmpty ? 'Enter email' : null,
                onChanged: (value) => _email = value,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Password too short' : null,
                onChanged: (value) => _password = value,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submit,
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}