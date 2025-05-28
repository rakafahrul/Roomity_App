import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rom_app/models/user.dart';
// import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  static const String baseUrl = 'https://localhost:7143/api/Auth';
   
  // static const String baseUrl = 'https://10.0.2.2:7143/api/Auth';


  // Metode untuk mendapatkan user dari SharedPreferences
static Future<User?> getUserFromPrefs() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? userData = prefs.getString('user_data');
  
  if (userData != null) {
    Map<String, dynamic> userMap = json.decode(userData);
    return User.fromJson(userMap);
  }
  
  return null;
}

// Metode untuk memeriksa apakah user sudah login
static Future<bool> isLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('token') != null;
}

// Metode untuk memeriksa role user
static Future<String?> getUserRole() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('role');
}

  // Method untuk mendapatkan token dari SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Method untuk mendapatkan semua pengguna (hanya untuk admin)
Future<List<User>> getAllUsers() async {
  final token = await _getToken();
  
  if (token == null) {
    throw Exception('No authentication token found');
  }

  final response = await http.get(
    Uri.parse('$baseUrl/users'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );
  
  if (response.statusCode == 200) {
    final List<dynamic> usersJson = json.decode(response.body);
    return usersJson.map((json) => User.fromJson(json)).toList();
  } else if (response.statusCode == 403) {
    throw Exception('Forbidden: You do not have permission to access this resource');
  } else {
    throw Exception('Failed to get users. Status: ${response.statusCode}');
  }
}

  // Method untuk mendapatkan user yang sedang login
  Future<User> getCurrentUser() async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to get user. Status: ${response.statusCode}');
    }
  }

  // Future<User> getCurrentUser() async {
  //   final response = await http.get(
  //     Uri.parse('$baseUrl/user/me'),
  //     headers: {'Authorization': 'Bearer YOUR_TOKEN'}, // Sesuaikan
  //   );
    
  //   if (response.statusCode == 200) {
  //     return User.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to get user. Status: ${response.statusCode}');
  //   }
  // }

  // Method untuk update profil user
  Future<User> updateProfile({
    required String name,
    required String email,
    String? photo,
  }) async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final response = await http.put(
      Uri.parse('$baseUrl/user/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': name,
        'email': email,
        if (photo != null) 'photo': photo,
      }),
    );
    
    if (response.statusCode == 200) {
      // Update data di SharedPreferences jika perlu
      if (photo != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_photo', photo);
      }
      
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update profile. Status: ${response.statusCode}');
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      // Format JSON yang benar sesuai dengan yang diterima API
      var body = json.encode({
        'email': email,
        'password': password
      });
      
      print('Mencoba login dengan email: $email');
      print('URL: $baseUrl/login');
      
      var response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      print('Respon status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        SharedPreferences prefs = await SharedPreferences.getInstance();
        
        // Simpan token JWT
        await prefs.setString('token', data['token']);
        
        // Simpan role user
        await prefs.setString('role', data['role']);
        
        // Simpan data user
        if (data['user'] != null) {
          await prefs.setString('user_data', json.encode(data['user']));
          await prefs.setString('user_id', data['user']['id'].toString());
          await prefs.setString('user_name', data['user']['name']);
          await prefs.setString('user_email', data['user']['email']);
          if (data['user']['photo'] != null && data['user']['photo'].isNotEmpty) {
            await prefs.setString('user_photo', data['user']['photo']);
          }
        }
        
        return true;
      }
      return false;
    } catch(e) {
      print('Login error: $e');
      return false;
    }
  }

  static Future<bool> register(String name, String email, String password, String role) async {
    var body = json.encode({
      'name': name,
      'email': email,
      'password': password,
      'role': role,
    });
    var response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 201) {

      print('Register failed: ${response.body}');
      // Simpan data user di SharedPreferences
      // SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('user_email', email);
      // await prefs.setString('user_name', name);
      // await prefs.setString('role', role);
      // return true;
    }

    return response.statusCode == 201;
  }

  // static Future<User> getCurrentUser() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   String? token = prefs.getString('token');
  //   String? role = prefs.getString('role');

  //   var response = await http.get(
  //     Uri.parse('$baseUrl/user'),
  //     headers: {'Authorization': 'Bearer $token'},
  //   );

  //   if (response.statusCode == 200) {
  //     return User.fromJson(json.decode(response.body));
  //   } else {
  //     throw Exception('Failed to load user');
  //   }
  // }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}