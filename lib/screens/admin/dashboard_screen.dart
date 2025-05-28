import 'package:flutter/material.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rom_app/screens/admin/room_management_screen.dart';
import 'package:rom_app/screens/admin/facility_management_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _userName = '';
  String _userEmail = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }


  

  Future<void> _loadUserData() async {
    try{
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _userName = prefs.getString('user_name') ?? 'Admin';
        _userEmail = prefs.getString('user_email') ?? '';
      });
      print('User data loaded: $_userName, $_userEmail');

    }catch (e){
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userName),
              accountEmail: Text(_userEmail),
              currentAccountPicture: const CircleAvatar(
                child: Icon(Icons.person),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.pushNamed(context, '/admin/user_management');
              },
            ),
            ListTile(
              leading: const Icon(Icons.meeting_room),
              title: const Text('Room Management'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminRoomManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Facility Management'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminFacilityManagementScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.pop(context); // Tutup drawer
                // Navigate to settings
              },
            ),
          ],
        ),
      ),
      body: const Center(
        child: Text('Welcome to Admin Dashboard'),
      ),
    );
  }
}
