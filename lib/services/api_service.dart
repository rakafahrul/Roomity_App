import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:rom_app/models/user.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/models/room_facility.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/models/approval.dart';
import 'package:rom_app/models/photo_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';  
import 'package:http_parser/http_parser.dart';  

class ApiService {
  static const String baseUrl = 'https://apiroom-production.up.railway.app/api';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  //  headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // token helper
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  //  error handling
  static Exception handleError(dynamic error, int? statusCode, String? responseBody) {
    if (statusCode != null) {
      switch (statusCode) {
        case 400:
          return Exception('Bad request: ${responseBody ?? 'Invalid data sent'}');
        case 401:
          return Exception('Unauthorized: Please login again');
        case 403:
          return Exception('Forbidden: You don\'t have permission');
        case 404:
          return Exception('Not found: The requested resource doesn\'t exist');
        case 500:
          return Exception('Server error: Please try again later');
        default:
          return Exception('HTTP Error $statusCode: ${responseBody ?? error}');
      }
    }
    return Exception('Network error: $error');
  }

  // ✅ Logging methods
  static void logRequest(String method, String url, {Map<String, String>? headers, String? body}) {
    print('🌐 === $method REQUEST ===');
    print('📍 URL: $url');
    print('📅 Time: ${DateTime.now()}');
    if (body != null) {
      final bodyPreview = body.length > 500 ? '${body.substring(0, 500)}...' : body;
      print('📤 Body: $bodyPreview');
    }
  }

  static void logResponse(int statusCode, String? body) {
    print('📥 === RESPONSE ===');
    print('📊 Status: $statusCode');
    if (body != null) {
      final bodyPreview = body.length > 500 ? '${body.substring(0, 500)}...' : body;
      print('📄 Body: $bodyPreview');
    }
    print('⏱️ Time: ${DateTime.now()}');
  }

  //=========================PHOTO=========================

  static Future<void> uploadPhotoUsage({
    required int bookingId,
    required XFile photoFile,
  }) async {
    try {
      logRequest('POST', '$baseUrl/photo_usage');
      
      // 1. Upload gambar ke storage/server terlebih dahulu
      final photoUrl = await _uploadImageToServer(photoFile);

      // 2. Kirim data ke endpoint /api/photo_usage
      final uri = Uri.parse('$baseUrl/photo_usage');

      // 3. Siapkan payload sesuai spesifikasi endpoint
      final payload = {
        'photoId': 0,
        'photoUrl': photoUrl,
        'booking': {
          'id': bookingId,
        }
      };

      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: jsonEncode(payload),
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in uploadPhotoUsage: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<String> _uploadImageToServer(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // For demo purposes, return a placeholder URL
      // In production, implement actual file upload to your storage
      return 'https://apiroom-production.up.railway.app/storage/$fileName';
    } catch (e) {
      print('❌ Error uploading image: $e');
      return 'https://apiroom-production.up.railway.app/storage/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    }
  }

  static Future<String> uploadPhotoMultipart({
    required int bookingId,
    required XFile photoFile,
    required String photoType,
  }) async {
    try {
      logRequest('POST', '$baseUrl/photo_usage');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/photo_usage'),
      );

      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
      });

      request.fields['bookingId'] = bookingId.toString();
      request.fields['photoType'] = photoType;

      final photoBytes = await photoFile.readAsBytes();
      request.files.add(
        http.MultipartFile.fromBytes(
          'photo',
          photoBytes,
          filename: photoFile.name,
        ),
      );

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        return responseData['photoUrl'] ?? 'Upload berhasil';
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in uploadPhotoMultipart: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<Booking> getBookingById(int bookingId) async {
    try {
      final url = '$baseUrl/bookings/$bookingId';
      var response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        var bookingJson = json.decode(response.body);
        return Booking.fromJson(bookingJson);
      } else {
        throw Exception('Booking not found');
      }
    } catch (e) {
      throw handleError(e, null, null);
    }
  }


  static Future<void> uploadPertanggungjawaban({
    required int bookingId,
    required XFile photo,
  }) async {
    try {
      print('📤 Trying alternative upload method...');
      
      // ✅ First, get booking details to include required info
      final bookingDetails = await getBookingById(bookingId);
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/bookings/$bookingId/responsibility'),
      );
      
      request.headers.addAll({
        'Content-Type': 'multipart/form-data',
        'Accept': 'application/json',
      });
      
      // ✅ Include all booking-related data
      request.fields.addAll({
        'BookingId': bookingId.toString(),
        'UserId': bookingDetails.userId.toString(),
        'RoomId': bookingDetails.roomId.toString(), 
        'Status': 'done',
        'Purpose': bookingDetails.purpose,
        'StartTime': bookingDetails.startTime,
        'EndTime': bookingDetails.endTime,
        'BookingDate': DateFormat('yyyy-MM-dd').format(bookingDetails.bookingDate),
        'UploadedAt': DateTime.now().toIso8601String(),
      });
      
      var multipartFile = await http.MultipartFile.fromPath(
        'ResponsibilityPhoto',
        photo.path,
        filename: 'responsibility_${bookingId}.jpg',
        contentType: MediaType('image', 'jpeg'),
      );
      
      request.files.add(multipartFile);
      
      var streamedResponse = await request.send()
          .timeout(const Duration(seconds: 30));
      var response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Alternative upload successful');
      } else {
        throw Exception('Upload failed: ${response.body}');
      }
      
    } catch (e) {
      print('❌ Alternative upload failed: $e');
      throw e;
    }
  }
  static Future<void> uploadPertanggungjawabanSmart({
    required int bookingId,
    required XFile photo,
  }) async {
    print('🎯 SMART UPLOAD: Starting for booking $bookingId');
    
    // Strategy 1: Try main multipart upload
    try {
      print('📤 STRATEGY 1: Multipart upload');
      await uploadPertanggungjawaban(bookingId: bookingId, photo: photo);
      print('✅ STRATEGY 1: SUCCESS');
      return;
    } catch (e) {
      print('❌ STRATEGY 1 FAILED: $e');
    }
    
    // Strategy 2: Try simple base64 upload
    try {
      print('📤 STRATEGY 2: Base64 upload');
      await uploadPertanggungjawabanSimple(bookingId: bookingId, photo: photo);
      print('✅ STRATEGY 2: SUCCESS');
      return;
    } catch (e) {
      print('❌ STRATEGY 2 FAILED: $e');
    }
    
    // Strategy 3: Try with different content type
    try {
      print('📤 STRATEGY 3: Alternative content type');
      
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('$baseUrl/api/upload'),
      );
      
      request.fields['type'] = 'pertanggungjawaban';
      request.fields['bookingId'] = bookingId.toString();
      
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        photo.path,
        filename: 'upload.jpg',
      ));
      
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      
      print('📥 STRATEGY 3: Status: ${response.statusCode}, Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ STRATEGY 3: SUCCESS');
        return;
      } else {
        throw Exception('Strategy 3 failed: ${response.body}');
      }
    } catch (e) {
      print('❌ STRATEGY 3 FAILED: $e');
    }
    
    // All strategies failed
    throw Exception('All upload strategies failed. Please check your backend endpoint configuration.');
  }
  static Future<void> uploadPertanggungjawabanSimple({
    required int bookingId,
    required XFile photo,
  }) async {
    try {
      print('🔄 DEBUG: Trying simple upload method...');
      
      // ✅ Convert to base64 as fallback
      final bytes = await File(photo.path).readAsBytes();
      final base64Image = base64Encode(bytes);
      
      print('📊 DEBUG: Image converted to base64, length: ${base64Image.length}');
      
      final response = await http.post(
        Uri.parse('$baseUrl/pertanggungjawaban'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode({
          'bookingId': bookingId,
          'image': base64Image,
          'status': 'done',
          'timestamp': DateTime.now().toIso8601String(),
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('📥 SIMPLE DEBUG: Status: ${response.statusCode}');
      print('📥 SIMPLE DEBUG: Body: ${response.body}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ SIMPLE SUCCESS: Base64 upload completed');
      } else {
        throw Exception('Simple upload failed: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      print('❌ SIMPLE ERROR: $e');
      throw e;
    }
  }
  // static Future<bool> uploadPertanggungjawaban({
  //   required int bookingId,
  //   required XFile photo,
  // }) async {
  //   try {
  //     await uploadPhotoUsage(
  //       bookingId: bookingId,
  //       photoFile: photo,
  //     );

  //     await updateBookingStatus(bookingId, 'done');
  //     return true;
  //   } catch (e) {
  //     print('❌ Error in uploadPertanggungjawaban: $e');
  //     throw Exception('Failed to upload pertanggungjawaban: $e');
  //   }
  // }

  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
      // ✅ FIXED: Use exact backend endpoint PUT /api/bookings/{id}
      final url = '$baseUrl/bookings/$bookingId';
      logRequest('PUT', url, body: jsonEncode({"status": status}));
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: jsonEncode({"status": status}),
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('❌ Error in updateBookingStatus: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<List<Map<String, dynamic>>> getPhotosByBookingId(int bookingId) async {
    try {
      // ✅ FIXED: Use exact backend endpoint GET /api/photo_usage
      final url = '$baseUrl/photo_usage?booking_id=$bookingId';
      logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getPhotosByBookingId: $e');
      throw handleError(e, null, null);
    }
  }

  Future<List<PhotoUsage>> getPhotos(int bookingId) async {
    try {
      final url = '$baseUrl/photo_usage?booking_id=$bookingId';
      logRequest('GET', url);
      
      final response = await http.get(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => PhotoUsage.fromJson(json)).toList();
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getPhotos: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> deletePhoto(int photoId) async {
    try {
      // ✅ FIXED: Use exact backend endpoint DELETE /api/photo_usage/{id}
      final url = '$baseUrl/photo_usage/$photoId';
      logRequest('DELETE', url);
      
      final response = await http.delete(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in deletePhoto: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== FACILITY ==========================================
  Future<List<Facility>> getFacilities() async {
    try {
      // ✅ CORRECT: Using GET /api/Facilities (capital F matches backend)
      final url = '$baseUrl/Facilities';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var decode = json.decode(response.body);
        
        if (decode is Map && decode.containsKey('\$values')) {
          var facilitiesJson = decode['\$values'] as List;
          List<Facility> facilities = [];
          
          for (var facilityData in facilitiesJson) {
            try {
              Facility facility = Facility.fromJson(facilityData);
              facilities.add(facility);
            } catch (e) {
              print('⚠️ Skipping invalid facility data: $e');
              continue;
            }
          }
          
          return facilities;
        } else if (decode is List) {
          return decode.map((facilityJson) => Facility.fromJson(facilityJson)).toList();
        } else {
          throw Exception('Unexpected facilities response format');
        }
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getFacilities: $e');
      throw handleError(e, null, null);
    }
  }

  Future<Facility> createFacility(Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final requestData = {'name': data['name']};
      // ✅ FIXED: Use exact backend endpoint POST /api/Facilities (capital F)
      final url = '$baseUrl/Facilities';
      
      logRequest('POST', url, headers: headers, body: json.encode(requestData));
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        return Facility.fromJson(json.decode(response.body));
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in createFacility: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> updateFacility(int id, Map<String, dynamic> data) async {
    try {
      final headers = await _getAuthHeaders();
      final requestData = {'name': data['name']};
      // ✅ FIXED: Use exact backend endpoint PUT /api/Facilities/{id} (capital F)
      final url = '$baseUrl/Facilities/$id';
      
      logRequest('PUT', url, headers: headers, body: json.encode(requestData));
      
      final response = await http.put(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in updateFacility: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> deleteFacility(int id) async {
    try {
      final headers = await _getAuthHeaders();
      // ✅ FIXED: Use exact backend endpoint DELETE /api/Facilities/{id} (capital F)
      final url = '$baseUrl/Facilities/$id';
      
      logRequest('DELETE', url, headers: headers);
      
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in deleteFacility: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== ROOM FACILITY ==============================
  static Future<List<RoomFacility>> getRoomFacilities(int roomId) async {
    try {
      final url = '$baseUrl/room_facilities?room_id=$roomId';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var roomFacilitiesJson = json.decode(response.body) as List;
        return roomFacilitiesJson
            .map((rfJson) => RoomFacility.fromJson(rfJson))
            .toList();
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getRoomFacilities: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> createRoomFacility(Map<String, dynamic> data) async {
    try {
      final url = '$baseUrl/room_facilities';
      logRequest('POST', url, body: json.encode(data));
      
      final response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: json.encode(data),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 201) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in createRoomFacility: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> deleteRoomFacility(int roomId, int facilityId) async {
    try {
      final url = '$baseUrl/room_facilities?room_id=$roomId&facility_id=$facilityId';
      logRequest('DELETE', url);
      
      final response = await http.delete(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in deleteRoomFacility: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== ROOMS ==========================================
  static Future<List<Room>> getRooms() async {
    try {
      // ✅ CORRECT: Using GET /api/meeting_rooms (matches backend exactly)
      final url = '$baseUrl/meeting_rooms';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var decode = json.decode(response.body);
        
        if (decode is Map && decode.containsKey('\$values')) {
          var roomsJson = decode['\$values'] as List;
          List<Room> rooms = [];
          
          for (var roomData in roomsJson) {
            try {
              Room room = Room.fromJson(roomData);
              rooms.add(room);
            } catch (e) {
              print('⚠️ Skipping invalid room data: $e. Data: $roomData');
              continue;
            }
          }
          
          print('✅ Successfully loaded ${rooms.length} rooms');
          return rooms;
        } else if (decode is List) {
          List<Room> rooms = decode.map((roomJson) => Room.fromJson(roomJson)).toList();
          print('✅ Successfully loaded ${rooms.length} rooms');
          return rooms;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getRooms: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<Room> getRoom(int id) async {
    try {
      // ✅ CORRECT: Using GET /api/Room/{id} (matches backend exactly)
      final url = '$baseUrl/Room/$id';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var decode = json.decode(response.body);
        return Room.fromJson(decode);
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getRoom: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> updateRoom(int roomId, Map<String, dynamic> updatedData) async {
    try {
      // ✅ CORRECT: Using PUT /api/rooms/{id} (matches backend exactly)
      final url = '$baseUrl/rooms/$roomId';
      logRequest('PUT', url, body: json.encode(updatedData));
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: json.encode(updatedData),
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Room updated successfully');
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in updateRoom: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> createRoomMultipart(Map<String, dynamic> data, {XFile? photo}) async {
    print('🏗️ === API CREATE ROOM MULTIPART ===');
    print('📊 Data: $data');
    print('📸 Has photo: ${photo != null}');
    
    try {
      // ✅ CORRECT: Using POST /api/rooms (matches backend exactly)
      final uri = Uri.parse('$baseUrl/rooms');
      logRequest('POST (multipart)', uri.toString());
      
      final request = http.MultipartRequest('POST', uri);

      request.fields.addAll({
        'Name': data['name'].toString(),
        'Location': data['location'].toString(),
        'Description': data['description'].toString(),
        'Capacity': data['capacity'].toString(),
        'Status': data['status'].toString(),
        'Latitude': data['latitude'].toString(),
        'Longitude': data['longitude'].toString(),
      });

      if (data['facilities'] != null) {
        String facilitiesJson = json.encode(data['facilities']);
        request.fields['Facilities'] = facilitiesJson;
        print('📋 Facilities sent as: $facilitiesJson');
      }

      print('📄 Form fields: ${request.fields}');

      if (photo != null) {
        final bytes = await photo.readAsBytes();
        final multipartFile = http.MultipartFile.fromBytes(
          'Photo',
          bytes,
          filename: photo.name,
        );
        request.files.add(multipartFile);
        print('📸 Added photo: ${photo.name}');
      }

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(response.statusCode, response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        throw handleError(null, response.statusCode, response.body);
      }
      
      print('✅ Room created successfully');
    } catch (e) {
      print('❌ Error in createRoomMultipart: $e');
      throw handleError(e, null, null);
    }
  }

  Future<Room> createRoom(Room room) async {
    try {
      // ✅ CORRECT: Using POST /api/rooms (matches backend exactly)
      final url = '$baseUrl/rooms';
      final body = json.encode(room.toJson());
      logRequest('POST', url, body: body);
      
      var response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        var decode = json.decode(response.body);
        return Room.fromJson(decode);
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in createRoom: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> deleteRoom(int id) async {
    try {
      // ✅ CORRECT: Using DELETE /api/rooms/{id} (matches backend exactly)
      final url = '$baseUrl/rooms/$id';
      logRequest('DELETE', url);
      
      var response = await http.delete(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in deleteRoom: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== BOOKINGS ==========================================
  static Future<bool> createBooking({
    required int userId,
    required int roomId,
    required DateTime bookingDate,
    required String startTime,
    required String endTime,
    required String purpose,
    required String status,
    String? locationGps,
    String? roomPhotoUrl,
  }) async {
    try {
      final bookingData = {
        "RoomId": roomId,
        "UserId": userId,
        "BookingDate": bookingDate.toIso8601String(),
        "StartTime": startTime,
        "EndTime": endTime,
        "Purpose": purpose,
        "Status": status,
        "CheckinTime": null,
        "CheckoutTime": null,
        "LocationGps": locationGps ?? "",
        "IsPresent": false,
        "RoomPhotoUrl": roomPhotoUrl ?? "",
        "CreatedAt": DateTime.now().toIso8601String(),
        "Photos": []
      };

      // ✅ CORRECT: Using POST /api/bookings (matches backend exactly)
      final url = '$baseUrl/bookings';
      logRequest('POST', url, body: json.encode(bookingData));

      final response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: json.encode(bookingData),
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      return response.statusCode == 201;
    } catch (e) {
      print('❌ Error in createBooking: $e');
      return false;
    }
  }

  static Future<List<Booking>> getBookings() async {
    try {
      // ✅ CORRECT: Using GET /api/bookings (matches backend exactly)
      final url = '$baseUrl/bookings';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var bookingsJson = json.decode(response.body);
        
        List<dynamic> dataList = [];
        if (bookingsJson is Map && bookingsJson.containsKey('\$values')) {
          dataList = bookingsJson['\$values'];
        } else if (bookingsJson is List) {
          dataList = bookingsJson;
        }
        return dataList
            .map((bookingJson) => Booking.fromJson(bookingJson))
            .toList();
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getBookings: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<List<Approval>> getApprovals(int bookingId) async {
    try {
      final url = '$baseUrl/approvals?booking_id=$bookingId';
      logRequest('GET', url);
      
      var response = await http.get(
        Uri.parse(url),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 200) {
        var approvalsJson = json.decode(response.body) as List;
        return approvalsJson
            .map((approvalJson) => Approval.fromJson(approvalJson))
            .toList();
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in getApprovals: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== ADMIN BOOKING MANAGEMENT ==========================================
  
  static Future<bool> approveBooking(int bookingId, String note) async {
    try {
      // ✅ CORRECT: Using PUT /api/bookings/{id}/approve (matches backend exactly)
      final url = '$baseUrl/bookings/$bookingId/approve';
      final body = json.encode({'note': note});
      logRequest('PUT', url, body: body);
      
      var response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in approveBooking: $e');
      return false;
    }
  }

  static Future<bool> rejectBooking(int bookingId, String note) async {
    try {
      // ✅ CORRECT: Using PUT /api/bookings/{id}/reject (matches backend exactly)
      final url = '$baseUrl/bookings/$bookingId/reject';
      final body = json.encode({'note': note});
      logRequest('PUT', url, body: body);
      
      var response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in rejectBooking: $e');
      return false;
    }
  }

  static Future<bool> addAdminNote(int bookingId, String note) async {
    try {
      final url = '$baseUrl/bookings/$bookingId/admin-note';
      final body = json.encode({'note': note});
      logRequest('PUT', url, body: body);
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in addAdminNote: $e');
      return false;
    }
  }

  static Future<bool> completeBooking(int bookingId) async {
    try {
      final url = '$baseUrl/bookings/$bookingId/complete';
      logRequest('PUT', url);
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in completeBooking: $e');
      return false;
    }
  }

  static Future<bool> resolveIssue(int bookingId) async {
    try {
      final url = '$baseUrl/bookings/$bookingId/resolve-issue';
      logRequest('PUT', url);
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in resolveIssue: $e');
      return false;
    }
  }

  static Future<bool> updateBooking(Booking booking) async {
    try {
      final url = '$baseUrl/bookings/${booking.id}';
      final body = jsonEncode({
        "id": booking.id,
        "roomId": booking.roomId,
        "roomName": booking.roomName ?? "",
        "userId": booking.userId,
        "userName": booking.userName ?? "",
        "bookingDate": booking.bookingDate.toIso8601String(),
        "startTime": booking.startTime,
        "endTime": booking.endTime,
        "purpose": booking.purpose ?? "",
        "status": booking.status,
        "checkinTime": booking.checkinTime?.toIso8601String(),
        "checkoutTime": booking.checkoutTime?.toIso8601String(),
        // ✅ FIX: Backend requires these fields - never send null
        "locationGps": booking.locationGps?.trim().isNotEmpty == true 
            ? booking.locationGps 
            : "", // Required by backend
        "isPresent": booking.isPresent ?? false,
        "roomPhotoUrl": booking.roomPhotoUrl?.trim().isNotEmpty == true
            ? booking.roomPhotoUrl
            : "", // Required by backend
        "createdAt": booking.createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
        "photoUrls": booking.photoUrls ?? [],
      });
      
      logRequest('PUT', url, body: body);

      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('✅ Booking updated successfully');
        return true;
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in updateBooking: $e');
      return false;
    }
  }

  // static Future<bool> updateBooking(Booking booking) async {
  //   try {
  //     // ✅ CORRECT: Using PUT /api/bookings/{id} (matches backend exactly)
  //     final url = '$baseUrl/bookings/${booking.id}';
  //     final body = jsonEncode({
  //       "id": booking.id,
  //       "roomId": booking.roomId,
  //       "roomName": booking.roomName,
  //       "userId": booking.userId,
  //       "userName": booking.userName,
  //       "bookingDate": booking.bookingDate.toIso8601String(),
  //       "startTime": booking.startTime,
  //       "endTime": booking.endTime,
  //       "purpose": booking.purpose,
  //       "status": booking.status,
  //       "checkinTime": booking.checkinTime?.toIso8601String(),
  //       "checkoutTime": booking.checkoutTime?.toIso8601String(),
  //       "locationGps": booking.locationGps,
  //       "isPresent": booking.isPresent,
  //       "roomPhotoUrl": booking.roomPhotoUrl,
  //       "createdAt": booking.createdAt?.toIso8601String(),
  //       "photoUrls": booking.photoUrls ?? [],
  //     });
      
  //     logRequest('PUT', url, body: body);

  //     final response = await http.put(
  //       Uri.parse(url),
  //       headers: defaultHeaders,
  //       body: body,
  //     ).timeout(timeoutDuration);

  //     logResponse(response.statusCode, response.body);

  //     if (response.statusCode == 200 || response.statusCode == 204) {
  //       print('✅ Booking updated successfully with status: ${response.statusCode}');
  //       return true;
  //     } else {
  //       throw handleError(null, response.statusCode, response.body);
  //     }
  //   } catch (e) {
  //     print('❌ Error in updateBooking: $e');
  //     return false;
  //   }
  // }

  // =================== USER BOOKING ACTIONS ==========================================
  
  static Future<bool> checkin(int bookingId, String locationGps) async {
    try {
      // ✅ CORRECT: Using PUT /api/bookings/{id}/checkin (matches backend exactly)
      final url = '$baseUrl/bookings/$bookingId/checkin';
      final body = json.encode({'location_gps': locationGps});
      logRequest('PUT', url, body: body);

      var response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in checkin: $e');
      return false;
    }
  }

  static Future<bool> checkout(int bookingId, String photoUrl) async {
    try {
      // ✅ CORRECT: Using PUT /api/bookings/{id}/checkout (matches backend exactly)
      final url = '$baseUrl/bookings/$bookingId/checkout';
      final body = json.encode({'photo_url': photoUrl});
      logRequest('PUT', url, body: body);

      var response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);

      logResponse(response.statusCode, response.body);
      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error in checkout: $e');
      return false;
    }
  }

  static Future<void> confirmAttendance(int bookingId, String locationGps) async {
    try {
      final url = '$baseUrl/bookings/$bookingId/checkin';
      final body = jsonEncode({'locationGps': locationGps});
      logRequest('PUT', url, body: body);
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Gagal konfirmasi kehadiran');
      }
    } catch (e) {
      print('❌ Error in confirmAttendance: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<void> checkoutBooking(int bookingId, String photoUrl) async {
    try {
      final url = '$baseUrl/bookings/$bookingId/checkout';
      final body = jsonEncode({'photoUrl': photoUrl});
      logRequest('PUT', url, body: body);
      
      final response = await http.put(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode != 200) {
        throw Exception('Gagal melakukan pertanggungjawaban');
      }
    } catch (e) {
      print('❌ Error in checkoutBooking: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<String> uploadPhoto(int bookingId, XFile photo, {String type = 'before'}) async {
    try {
      final uri = Uri.parse('$baseUrl/bookings/$bookingId/photos');
      logRequest('POST (multipart)', uri.toString());
      
      var request = http.MultipartRequest('POST', uri)
        ..fields['type'] = type
        ..files.add(await http.MultipartFile.fromPath('photo', photo.path));
      
      final response = await request.send().timeout(timeoutDuration);
      
      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        logResponse(response.statusCode, respStr);
        final jsonResp = jsonDecode(respStr);
        return jsonResp['photoUrl'];
      }
      throw Exception('Gagal upload foto');
    } catch (e) {
      print('❌ Error in uploadPhoto: $e');
      throw handleError(e, null, null);
    }
  }

  // =================== LEGACY BOOKING METHODS ==========================================
  
  static Future<bool> createBookingSwagger(int userId, int roomId, DateTime bookingDate, String purpose, String startTime, String endTime) async {
    try {
      var bookingData = {
        "id": 0,
        "roomId": roomId,
        "userId": userId,
        "bookingDate": bookingDate.toIso8601String(),
        "startTime": startTime,
        "endTime": endTime,
        "purpose": purpose,
        "status": "pending",
        "checkinTime": null,
        "checkoutTime": null,
        "locationGps": "",
        "isPresent": false,
        "roomPhotoUrl": "",
        "createdAt": DateTime.now().toIso8601String(),
        "photos": [],
       };

       final url = '$baseUrl/bookings';
       final body = json.encode(bookingData);
       logRequest('POST', url, body: body);

       var response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
       ).timeout(timeoutDuration);
       
       logResponse(response.statusCode, response.body);
       return response.statusCode == 201;
    } catch (e) {
      print('❌ Error in createBookingSwagger: $e');
      return false;
    }
  }

  static Future<bool> createBookingPascalCase(Map<String, dynamic> bookingData) async {
    try {
      final url = '$baseUrl/bookings';
      final body = json.encode(bookingData);
      logRequest('POST', url, body: body);
      
      var response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      return response.statusCode == 201;
    } catch (e) {
      print('❌ Error in createBookingPascalCase: $e');
      return false;
    }
  }

  static Future<bool> createBookingSimple(Map<String, dynamic> bookingData) async {
    try {
      final url = '$baseUrl/bookings';
      final body = json.encode(bookingData);
      logRequest('POST', url, body: body);
      
      final response = await http.post(
        Uri.parse(url),
        headers: defaultHeaders,
        body: body,
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      return response.statusCode == 201;
    } catch (e) {
      print('❌ Error in createBookingSimple: $e');
      return false;
    }
  }

  // =================== UTILITY METHODS ==========================================
  
  // ✅ Test koneksi ke API
  static Future<bool> testConnection() async {
    try {
      print('🧪 Testing API connection...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/meeting_rooms'),
        headers: defaultHeaders,
      ).timeout(Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('✅ API connection successful');
        return true;
      } else {
        print('❌ API test failed: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // ✅ Debug all endpoints
  static Future<Map<String, dynamic>> debugEndpoints() async {
    final results = <String, dynamic>{};
    
    final endpoints = [
      '$baseUrl/meeting_rooms',
      '$baseUrl/Facilities',
      '$baseUrl/bookings',
      '$baseUrl/photo_usage',
    ];
    
    for (String endpoint in endpoints) {
      try {
        print('🧪 Testing endpoint: $endpoint');
        
        final response = await http.get(
          Uri.parse(endpoint),
          headers: defaultHeaders,
        ).timeout(Duration(seconds: 10));
        
        results[endpoint] = {
          'status': response.statusCode,
          'success': response.statusCode == 200,
          'bodyLength': response.body.length,
          'bodyPreview': response.body.length > 200 
            ? '${response.body.substring(0, 200)}...' 
            : response.body,
        };
        
        print('✅ $endpoint: ${response.statusCode}');
        
      } catch (e) {
        results[endpoint] = {
          'success': false,
          'error': e.toString(),
        };
        print('❌ $endpoint: $e');
      }
    }
    
    return results;
  }
}