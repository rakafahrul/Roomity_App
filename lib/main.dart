import 'dart:io';
import 'package:flutter/material.dart';
import 'package:rom_app/screens/splash_screen.dart';
import 'screens/user/login_screen.dart';
import 'screens/admin/edit_room_screen.dart';
import 'package:rom_app/screens/admin/user_management_screen.dart';
import 'package:rom_app/screens/admin/dashboard_screen.dart';
import 'package:rom_app/screens/user/home_screen.dart';
import 'screens/admin/facility_management_screen.dart';
import 'screens/user/register_screen.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:rom_app/screens/user/succes_booking.dart';
import 'package:rom_app/screens/user/peminjaman.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:rom_app/screens/admin/room_management_screen.dart';
import 'package:rom_app/screens/user/profile_screen.dart';
import 'package:rom_app/screens/admin/profile_screen.dart';
import 'package:rom_app/screens/admin/booking_approval_screens.dart';
import 'package:rom_app/screens/user/peminjaman.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  HttpOverrides.global = MyHttpOverrides();
  runApp(MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    _loadCurrentUserId();
  }

  Future<void> _loadCurrentUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userDataString = prefs.getString('user_data');
    if (userDataString != null) {
      final userData = json.decode(userDataString);
      setState(() {
        currentUserId = userData['id'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roomity',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const UserLoginScreen(),     
        '/admin/dashboard_screen': (context) => const AdminDashboardScreen(),
        '/admin/user_management': (context) => const UserManagementScreen(),
        '/admin/facility_management': (context) => const AdminFacilityManagementScreen(),
        '/admin/booking_approval_screen' : (context) => const AdminPeminjamanScreen(),
        '/admin/profile_screen' : (context) => const AdminProfilScreen(),
        '/user/home': (context) => const UserHomeScreen(),
        '/user/register_screen': (context) => const UserRegisterScreen(),
        '/admin/room_management_screen': (context) => const AdminRoomManagementScreen(),
        '/user/booking_success': (context) => const BookingSuccessScreen(),
        '/user/profile_screen' :(context) => const UserProfilScreen(),
        '/user/peminjaman': (context) {
          if (currentUserId != null) {
            return PeminjamanScreen(currentUserId: currentUserId!);
          } else {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      },
    );
  }
}