import 'package:flutter/material.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/user.dart';
import 'package:rom_app/services/api_service.dart';
import 'package:rom_app/services/auth_service.dart';
import 'package:rom_app/screens/navbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'room_detail_screen.dart';

class UserHomeScreen extends StatefulWidget {
  const UserHomeScreen({super.key});

  @override
  State<UserHomeScreen> createState() => _UserHomeScreenState();
}

class _UserHomeScreenState extends State<UserHomeScreen> {
  late Future<List<Room>> _roomsFuture;
  
  String _userName = 'Pengguna'; 
  String _userEmail = '';
  String _userPhoto = '';
  String _userRole = '';
  bool _isLoadingUserData = true;

  @override
  void initState() {
    super.initState();
    _roomsFuture = ApiService.getRooms();
    _loadUserData(); 
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoadingUserData = true);
    
    try {
      await _loadUserFromPreferences();
      
      if (_userName == 'Pengguna') {
        await _loadUserFromAuthService();
      }
      
      if (_userName == 'Pengguna') {
        await _loadUserFromAPI();
      }
      
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      setState(() => _isLoadingUserData = false);
    }
  }

  Future<void> _loadUserFromAuthService() async {
    try {
      print('📱 Loading user from AuthService...');
      
      final User? user = await AuthService.getUserFromPrefs();
      
      if (user != null) {
        setState(() {
          _userName = user.name.isNotEmpty ? user.name : 'Pengguna';
          _userEmail = user.email;
          _userPhoto = user.photo ?? '';
          _userRole = user.role;
        });
        
        print('✅ User data loaded from AuthService: $_userName');
      }
      
    } catch (e) {
      print('❌ Error loading from AuthService: $e');
    }
  }

  Future<void> _loadUserFromPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Gunakan key yang sama dengan AuthService
      final userName = prefs.getString('user_name');
      final userEmail = prefs.getString('user_email');
      final userPhoto = prefs.getString('user_photo');
      final userRole = prefs.getString('role');
      
      print('📱 Loading user from preferences:');
      print('   - user_name: $userName');
      print('   - user_email: $userEmail');
      print('   - user_photo: $userPhoto');
      print('   - role: $userRole');
      
      if (userName != null && userName.isNotEmpty) {
        _userName = userName;
      } else if (userEmail != null && userEmail.isNotEmpty) {
        _userName = userEmail.split('@')[0];
      }
      
      if (userEmail != null) {
        _userEmail = userEmail;
      }
      
      if (userPhoto != null) {
        _userPhoto = userPhoto;
      }
      
      if (userRole != null) {
        _userRole = userRole;
      }
      
      print('✅ User data loaded from preferences: $_userName');
      
    } catch (e) {
      print('❌ Error loading from preferences: $e');
    }
  }

  Future<void> _loadUserFromAPI() async {
    try {
      print('🌐 Loading user data from API...');
      
      final authService = AuthService();
      final User currentUser = await authService.getCurrentUser();
      
      setState(() {
        _userName = currentUser.name.isNotEmpty ? currentUser.name : 'Pengguna';
        _userEmail = currentUser.email;
        _userPhoto = currentUser.photo ?? '';
        _userRole = currentUser.role;
        
        print('✅ User data loaded from API: $_userName');
      });
      
      await _updatePreferencesWithUserData(currentUser);
      
    } catch (e) {
      print('❌ Error loading from API: $e');
    }
  }

  Future<void> _updatePreferencesWithUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      if (user.photo != null && user.photo!.isNotEmpty) {
        await prefs.setString('user_photo', user.photo!);
      }
      print('✅ Preferences updated with fresh user data');
    } catch (e) {
      print('❌ Error updating preferences: $e');
    }
  }

  Future<void> _refreshUserData() async {
    setState(() => _isLoadingUserData = true);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            ),
            SizedBox(width: 12),
            Text('Memperbarui data user...'),
          ],
        ),
        backgroundColor: Color(0xFF0B2447),
        duration: Duration(seconds: 2),
      ),
    );
    
    try {
      _userName = 'Pengguna';
      _userEmail = '';
      _userPhoto = '';
      _userRole = '';
      
      await _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text('Data user berhasil diperbarui'),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error refreshing user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text('Gagal memperbarui data: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Selamat Pagi';
    } else if (hour < 15) {
      return 'Selamat Siang';
    } else if (hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  String _getUserInitials() {
    if (_userName.isEmpty || _userName == 'Pengguna') return 'U';
    
    final names = _userName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    } else {
      return _userName.length >= 2 
          ? _userName.substring(0, 2).toUpperCase()
          : _userName[0].toUpperCase();
    }
  }

  Widget _buildRoomImage(String imageUrl) {
    return Image.network(
      imageUrl,
      height: 180,
      width: double.infinity,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: 180,
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Color(0xFF0A3573),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        // Jika gagal load dari network, gunakan gambar default dari assets
        return Image.asset(
          'assets/images/default.jpeg',
          height: 180,
          width: double.infinity,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Jika default.png juga gagal, tampilkan placeholder
            return _buildDefaultRoomPlaceholder();
          },
        );
      },
    );
  }

  // Widget placeholder jika semua gambar gagal dimuat
  Widget _buildDefaultRoomPlaceholder() {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simple room illustration using icons
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 80,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[400]!, width: 2),
                ),
              ),
              // Table
              Container(
                width: 40,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.brown[300],
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Chairs
              Positioned(
                left: 15,
                top: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 15,
                top: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                left: 15,
                bottom: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Positioned(
                right: 15,
                bottom: 12,
                child: Container(
                  width: 8,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ruang Meeting',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Default',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  // 🎨 Build user avatar dengan foto atau inisial
  Widget _buildUserAvatar() {
    return GestureDetector(
      onTap: () {
        // Optional: buka halaman profile
        _showUserProfile();
      },
      child: _isLoadingUserData
          ? Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF0B2447),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          : _userPhoto.isNotEmpty
              ? CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(_userPhoto),
                  onBackgroundImageError: (exception, stackTrace) {
                    print('Error loading user photo: $exception');
                  },
                  child: _userPhoto.isEmpty
                      ? Text(
                          _getUserInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )
                      : null,
                )
              : CircleAvatar(
                  radius: 24,
                  backgroundColor: const Color(0xFF0B2447),
                  child: Text(
                    _getUserInitials(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
    );
  }

  // 👤 Show user profile info
  void _showUserProfile() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            // Avatar dengan foto atau inisial
            _userPhoto.isNotEmpty
                ? CircleAvatar(
                    radius: 20,
                    backgroundImage: NetworkImage(_userPhoto),
                    onBackgroundImageError: (exception, stackTrace) {
                      print('Error loading user photo in dialog: $exception');
                    },
                  )
                : CircleAvatar(
                    radius: 20,
                    backgroundColor: const Color(0xFF0B2447),
                    child: Text(
                      _getUserInitials(),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _userName,
                    style: const TextStyle(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (_userEmail.isNotEmpty)
                    Text(
                      _userEmail,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  if (_userRole.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _userRole.toLowerCase() == 'admin' 
                            ? Colors.red[100] 
                            : Colors.blue[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _userRole.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _userRole.toLowerCase() == 'admin' 
                              ? Colors.red[700] 
                              : Colors.blue[700],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person, color: Color(0xFF0B2447)),
              title: const Text('Edit Profile'),
              subtitle: const Text('Update nama, email, dan foto'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile edit screen
                _navigateToEditProfile();
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh, color: Color(0xFF0B2447)),
              title: const Text('Refresh Data User'),
              subtitle: const Text('Ambil data terbaru dari server'),
              onTap: () {
                Navigator.pop(context);
                _refreshUserData();
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout'),
              subtitle: const Text('Keluar dari aplikasi'),
              onTap: () {
                Navigator.pop(context);
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  // 📝 Navigate to edit profile (placeholder)
  void _navigateToEditProfile() {
    // TODO: Implement navigation to edit profile screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fitur edit profile akan segera tersedia'),
        backgroundColor: Color(0xFF0B2447),
      ),
    );
  }

  // ⚠️ Show logout confirmation
  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 8),
            Text('Konfirmasi Logout'),
          ],
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // 🚪 Logout method menggunakan AuthService
  Future<void> _logout() async {
    try {
      // Tampilkan loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Logging out...'),
            ],
          ),
          backgroundColor: Color(0xFF0B2447),
          duration: Duration(seconds: 2),
        ),
      );
      
      // Gunakan AuthService untuk logout
      await AuthService.logout();
      
      // Navigate ke login screen dan hapus semua route sebelumnya
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context, 
          '/login', 
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error logout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const NavBar(currentIndex: 0),
      body: SafeArea(
        child: Column(
          children: [
            // 👋 ENHANCED HEADER dengan nama user dynamic
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Row(
                children: [
                  // User Avatar dengan inisial atau foto
                  _buildUserAvatar(),
                  
                  const SizedBox(width: 12),
                  
                  // User info section
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Greeting + nama user
                        Text(
                          _getGreeting(),
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        const SizedBox(height: 2),
                        
                        // Nama user dengan loading state
                        _isLoadingUserData
                            ? Container(
                                width: 120,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              )
                            : Text(
                                _userName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Color(0xFF222B45),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                      ],
                    ),
                  ),
                  
                  // Notification button
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFFE4E9F2)),
                      color: Colors.white,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.notifications_none_rounded, 
                        color: Color(0xFF222B45)
                      ),
                      onPressed: () {
                        // TODO: Implement notifications
                      },
                      iconSize: 22,
                      splashRadius: 22,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8),
            
            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Daftar Ruangan',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 20,
                    color: Color(0xFF222B45),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Grid Ruangan
            Expanded(
              child: FutureBuilder<List<Room>>(
                future: _roomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[300],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Gagal memuat data',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${snapshot.error}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              setState(() {
                                _roomsFuture = ApiService.getRooms();
                              });
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Coba Lagi'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 80,
                            color: Colors.grey,
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Tidak ada ruangan tersedia',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final rooms = snapshot.data!;
                  return RefreshIndicator(
                    onRefresh: () async {
                      setState(() {
                        _roomsFuture = ApiService.getRooms();
                      });
                      await _refreshUserData();
                    },
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: rooms.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 card per row
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 16,
                        childAspectRatio: 0.85, // Sesuaikan agar card proporsional
                      ),
                      itemBuilder: (context, index) {
                        final room = rooms[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RoomDetailScreen(room: room),
                              ),
                            );
                          },
                          child: RoomCard(
                            name: room.name,
                            location: room.location,
                            capacity: '${room.capacity} Orang',
                            imageUrl: room.photoUrl,
                            facilities: room.facilities,
                            buildRoomImage: _buildRoomImage, // Pass the method
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

// Room Card component tetap sama
class RoomCard extends StatelessWidget {
  final String name;
  final String location;
  final String capacity;
  final String imageUrl;
  final List<String> facilities;
  final Widget Function(String) buildRoomImage;

  const RoomCard({
    super.key,
    required this.name,
    required this.location,
    required this.capacity,
    required this.imageUrl,
    required this.facilities,
    required this.buildRoomImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Gambar ruangan dengan fallback
          buildRoomImage(imageUrl),
          
          // Overlay gradient untuk readability text
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
          ),
          
          // Info ruangan
          Positioned(
            left: 12,
            bottom: 12,
            right: 12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.people,
                      color: Colors.white70,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      capacity,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    const Spacer(),
                    // Fasilitas count indicator
                    if (facilities.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.white70,
                              size: 10,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${facilities.length}',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}