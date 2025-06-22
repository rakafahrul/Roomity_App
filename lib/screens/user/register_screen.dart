import 'package:flutter/material.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserRegisterScreen extends StatefulWidget {
  const UserRegisterScreen({super.key});

  @override
  State<UserRegisterScreen> createState() => _UserRegisterScreenState();
}

class _UserRegisterScreenState extends State<UserRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _email = '';
  String _password = '';
  bool _obscure = true;
  bool _isLoading = false;

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() => _isLoading = true);

      try {
        bool success = await AuthService.register(_name, _email, _password, 'admin');
        if (success) {
          Fluttertoast.showToast(msg: 'Registrasi berhasil, silakan login');
          if (mounted) Navigator.pop(context);
        } else {
          Fluttertoast.showToast(msg: 'Registrasi gagal. Email sudah digunakan.');
        }
      } catch (e) {
        Fluttertoast.showToast(msg: 'Error: $e');
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back button
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(height: 16),
              // Title
              Center(
                child: Column(
                  children: const [
                    Text(
                      'Buat Akun Roomity',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF222B45),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Daftarkan dirimu sekarang!',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color(0xFF8F9BB3),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nama Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222B45),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan nama',
                        hintStyle: const TextStyle(color: Color(0xFFBFC6D0)),
                        filled: true,
                        fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator: (value) => value!.isEmpty ? 'Masukkan nama' : null,
                      onSaved: (value) => _name = value!,
                      onChanged: (value) => _name = value,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Email',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222B45),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Masukkan email',
                        hintStyle: const TextStyle(color: Color(0xFFBFC6D0)),
                        filled: true,
                        fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator: (value) => value!.isEmpty ? 'Masukkan email' : null,
                      onSaved: (value) => _email = value!,
                      onChanged: (value) => _email = value,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Password',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF222B45),
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      obscureText: _obscure,
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        hintStyle: const TextStyle(color: Color(0xFFBFC6D0)),
                        filled: true,
                        fillColor: const Color(0xFFF7F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: const Color(0xFF222B45),
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      style: const TextStyle(fontSize: 15),
                      validator: (value) => value!.length < 6 ? 'Password minimal 6 karakter' : null,
                      onSaved: (value) => _password = value!,
                      onChanged: (value) => _password = value,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF192965),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: _submit,
                              child: const Text(
                                'Register',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Center(
                        child: Text.rich(
                          TextSpan(
                            text: 'By signing up you agree to our ',
                            style: const TextStyle(
                              color: Color(0xFF8F9BB3),
                              fontSize: 13,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms',
                                style: const TextStyle(
                                  color: Color(0xFF222B45),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const TextSpan(text: '\nand '),
                              TextSpan(
                                text: 'Conditions of Use',
                                style: const TextStyle(
                                  color: Color(0xFF222B45),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}