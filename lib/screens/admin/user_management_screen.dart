// import 'package:flutter/material.dart';
// import 'package:rom_app/models/user.dart';
// import 'package:rom_app/services/auth_service.dart';
// import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class AdminUserManagementScreen extends StatefulWidget {
//   const AdminUserManagementScreen({super.key});

//   @override
//   _AdminUserManagementScreenState createState() => _AdminUserManagementScreenState();
// }

// class _AdminUserManagementScreenState extends State<AdminUserManagementScreen> {
//   final AuthService _authService = AuthService();
//   List<User> _users = [];
//   bool _isLoading = false;
  
//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//   }

//   // Tambahkan fungsi ini untuk menangani error izin
//   void _handlePermissionError(String message) {
//     Fluttertoast.showToast(
//       msg: message,
//       backgroundColor: Colors.red,
//       textColor: Colors.white,
//       toastLength: Toast.LENGTH_LONG,
//     );
    
//     // Kembali ke dashboard jika tidak memiliki izin
//     Navigator.pop(context);
//   }



//   // Modifikasi _loadUsers untuk menangani error izin
//   Future<void> _loadUsers() async {
//     if (!mounted) return;
    
//     setState(() => _isLoading = true);
//     try {
//       final users = await _authService.getAllUsers();
//       if (mounted) {
//         setState(() => _users = users);
//       }
//     } catch (e) {
//       if (mounted) {
//         if (e.toString().contains('Forbidden') || e.toString().contains('403')) {
//           _handlePermissionError('You do not have permission to access user management');
//         } else {
//           Fluttertoast.showToast(
//             msg: 'Failed to load users: $e',
//             backgroundColor: Colors.red,
//             textColor: Colors.white,
//           );
//         }
//       }
//     } finally {
//       if (mounted) {
//         setState(() => _isLoading = false);
//       }
//     }
//   }

//   // Tambahkan fungsi ini untuk memeriksa role sebelum navigasi
//   Future<void> _navigateToUserManagement() async {
//     final prefs = await SharedPreferences.getInstance();
//     final role = prefs.getString('role');
    
//     if (role == 'admin') {
//       Navigator.pushNamed(context, '/admin/user_management');
//     } else {
//       Fluttertoast.showToast(
//         msg: 'You do not have permission to access user management',
//         backgroundColor: Colors.red,
//         textColor: Colors.white,
//       );
//     }
//   }

  
//   // Future<void> _loadUsers() async {
//   //   if (!mounted) return;
    
//   //   setState(() => _isLoading = true);
//   //   try {
//   //     final users = await _authService.getAllUsers();
//   //     if (mounted) {
//   //       setState(() => _users = users);
//   //     }
//   //   } catch (e) {
//   //     if (mounted) {
//   //       Fluttertoast.showToast(
//   //         msg: 'Failed to load users: $e',
//   //         backgroundColor: Colors.red,
//   //         textColor: Colors.white,
//   //       );
//   //     }
//   //   } finally {
//   //     if (mounted) {
//   //       setState(() => _isLoading = false);
//   //     }
//   //   }
//   // }


  
  

  
  
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('User Management'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: _loadUsers,
//           ),
//         ],
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : _users.isEmpty
//               ? const Center(child: Text('No users found'))
//               : ListView.builder(
//                   itemCount: _users.length,
//                   itemBuilder: (context, index) {
//                     final user = _users[index];
//                     return Card(
//                       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundImage: user.photo.isNotEmpty
//                               ? NetworkImage(user.photo)
//                               : null,
//                           child: user.photo.isEmpty
//                               ? Text(user.name[0].toUpperCase())
//                               : null,
//                         ),
//                         title: Text(user.name),
//                         subtitle: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(user.email),
//                             Text('Role: ${user.role}'),
//                           ],
//                         ),
//                         trailing: IconButton(
//                           icon: const Icon(Icons.info),
//                           onPressed: () {
//                             _showUserDetails(user);
//                           },
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
  
//   void _showUserDetails(User user) {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text(user.name),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (user.photo.isNotEmpty)
//               Center(
//                 child: Image.network(
//                   user.photo,
//                   height: 100,
//                   width: 100,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             const SizedBox(height: 16),
//             Text('ID: ${user.id}'),
//             Text('Email: ${user.email}'),
//             Text('Role: ${user.role}'),
//             Text('Created: ${user.createdAt.toString().substring(0, 10)}'),
//           ],
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text('Close'),
//           ),
//           // Gunakan fungsi ini di tombol
//           ElevatedButton(
//             onPressed: _navigateToUserManagement,
//             child: const Text('Manage Users'),
//           ),
  
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Management'),
      ),
      body: const Center(
        child: Text('User Management Screen'),
      ),
    );
  }
}