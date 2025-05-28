import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rom_app/screens/splash_screen.dart';
import 'screens/user/login_screen.dart';
import 'screens/admin/login_screen.dart';
import 'package:rom_app/screens/admin/user_management_screen.dart';
import 'package:rom_app/screens/admin/dashboard_screen.dart';
import 'package:rom_app/screens/user/home_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'screens/admin/facility_management_screen.dart';
import 'screens/user/register_screen.dart';
void main() {
  // ini untuk mengizinkan koneksi HTTPS tidak aman
  HttpOverrides.global = MyHttpOverrides();
  runApp(const MyApp());

}

// Kelas untuk mengizinkan koneksi HTTP tidak aman
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roomity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {

        '/': (context) => const SplashScreen(),
        '/login': (context) => const UserLoginScreen(),
        '/admin/login': (context) => const AdminLoginScreen(),
        '/admin/dashboard_screen': (context) => const AdminDashboardScreen(),
        '/admin/user_management': (context) => const UserManagementScreen(),
        '/admin/facility_management': (context) => const AdminFacilityManagementScreen(),
        '/user/home': (context) => const UserHomeScreen(),
        '/user/register_screen': (context) => const UserRegisterScreen(),
      },
    );
  }
}