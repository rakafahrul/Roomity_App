
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:rom_app/models/user.dart';
import 'dart:io';

class AuthService {
  
  static const String baseUrl = 'https://apiroom-production.up.railway.app/api/Auth';
  
  static const Duration timeoutDuration = Duration(seconds: 30);

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

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = json.decode(response.body);
        return usersJson.map((json) => User.fromJson(json)).toList();
      } else if (response.statusCode == 403) {
        throw Exception('Forbidden: You do not have permission to access this resource');
      } else {
        throw Exception('Failed to get users. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout');
      }
      rethrow;
    }
  }

  // Method untuk mendapatkan user yang sedang login
  Future<User> getCurrentUser() async {
    final token = await _getToken();
    
    if (token == null) {
      throw Exception('No authentication token found');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to get user. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout');
      }
      rethrow;
    }
  }

  Future<User> updateProfile({
    required String name,
    required String email,
    String? photo,
    String? password,
  }) async {
    final token = await _getToken();

    if (token == null) {
      throw Exception('No authentication token found');
    }

    final bodyMap = {
      'name': name,
      'email': email,
      if (photo != null) 'photo': photo,
      if (password != null && password.isNotEmpty) 'password': password,
    };

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/user/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(bodyMap),
      ).timeout(timeoutDuration);

      if (response.statusCode == 200) {
        if (photo != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_photo', photo);
        }
        return User.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update profile. Status: ${response.statusCode}');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout');
      }
      rethrow;
    }
  }

  Future<String> uploadProfilePhoto(File file) async {
    final token = await _getToken();
    if (token == null) throw Exception('No authentication token found');

    try {
      var uri = Uri.parse('$baseUrl/user/upload_photo');
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('photo', file.path));

      var response = await request.send().timeout(timeoutDuration);
      final respStr = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return json.decode(respStr)['photoUrl'];
      } else {
        print("Upload error: $respStr");
        throw Exception('Failed to upload photo: $respStr');
      }
    } catch (e) {
      if (e is SocketException) {
        throw Exception('No internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        throw Exception('Request timeout');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
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
      ).timeout(timeoutDuration);
      
      print('Respon status: ${response.statusCode}');
      print('Respon body: ${response.body}');
      
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
        
        return data['user'];
      } else {
        print('Login failed with status: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch(e) {
      print('Login error: $e');
      if (e is SocketException) {
        print('No internet connection');
      } else if (e.toString().contains('TimeoutException')) {
        print('Request timeout');
      }
      return null;
    }
  }

  static Future<bool> register(String name, String email, String password, String role) async {
    try {
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
      ).timeout(timeoutDuration);
      
      print('Register response status: ${response.statusCode}');
      print('Register response body: ${response.body}');
      
      if (response.statusCode == 201) {
        return true;
      } else {
        print('Register failed: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Register error: $e');
      return false;
    }
  }

  static Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}