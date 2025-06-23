import 'package:flutter/material.dart';
import 'package:rom_app/services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2)); 
    
    bool isLoggedIn = await AuthService.isLoggedIn();
    
    if (isLoggedIn) {
      String? role = await AuthService.getUserRole();
      
      if (role == 'admin') {
        Navigator.pushReplacementNamed(context, '/admin/dashboard_screen');
      } else {
        Navigator.pushReplacementNamed(context, '/user/home');
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF192F59), 
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              
              SizedBox(
                width: 100,
                height: 100,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/Logo Roomity.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              
              const Text(
                'Roomity',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              
              const Text(
                'Memudahkan peminjaman ruang rapat!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

}
