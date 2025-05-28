import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:rom_app/models/user.dart';
import 'package:rom_app/models/room.dart';
import 'package:rom_app/models/facility.dart';
import 'package:rom_app/models/room_facility.dart';
import 'package:rom_app/models/booking.dart';
import 'package:rom_app/models/approval.dart';
import 'package:rom_app/models/photo_usage.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'https://localhost:7143/api';

  Future<String?> _getToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('token');
}



  //=========================PHOTO=========================
  Future<List<PhotoUsage>> getPhotos(int bookingId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/photo_usage?booking_id=$bookingId'),
    );
    
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => PhotoUsage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load photos. Status: ${response.statusCode}');
    }
  }

  Future<void> uploadPhoto(int bookingId, String photoUrl) async {
    final response = await http.post(
      Uri.parse('$baseUrl/photo_usage'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'booking_id': bookingId,
        'photo_url': photoUrl,
      }),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to upload photo. Status: ${response.statusCode}');
    }
  }

  Future<void> deletePhoto(int photoId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/photo_usage/$photoId'),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete photo. Status: ${response.statusCode}');
    }
  }


  // Fetch rooms
  static Future<List<Room>> getRooms() async {
    var response = await http.get(Uri.parse('$baseUrl/meeting_rooms'));
    if (response.statusCode == 200) {
      var decode = json.decode(response.body);
      var roomsJson = decode[('\$values')] as List;
      print('Rooms JSON: $roomsJson');
      return roomsJson.map((roomJson) => Room.fromJson(roomJson)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  // =================== FACILITY ==========================================
  Future<List<Facility>> getFacilities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/facilities'));
      
      if (response.statusCode == 200) {
        final facilitiesJson = json.decode(response.body) as List;
        return facilitiesJson.map((json) => Facility.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load facilities: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getFacilities: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Facility> createFacility(Map<String, dynamic> data) async {
    try {
      // Dapatkan token untuk autentikasi
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      // Hanya kirim nama fasilitas
      final requestData = {'name': data['name']};
      
      final response = await http.post(
        Uri.parse('$baseUrl/facilities'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );
      
      if (response.statusCode == 201) {
        return Facility.fromJson(json.decode(response.body));
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to create facility: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in createFacility: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> updateFacility(int id, Map<String, dynamic> data) async {
    try {
      // Dapatkan token untuk autentikasi
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      // Hanya kirim nama fasilitas
      final requestData = {'name': data['name']};
      
      final response = await http.put(
        Uri.parse('$baseUrl/facilities/$id'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestData),
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception('Failed to update facility: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateFacility: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<void> deleteFacility(int id) async {
    try {
      // Dapatkan token untuk autentikasi
      final token = await _getToken();
      if (token == null) {
        throw Exception('Authentication required');
      }
      
      final response = await http.delete(
        Uri.parse('$baseUrl/facilities/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );
      
      if (response.statusCode != 204 && response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception('Failed to delete facility: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteFacility: $e');
      throw Exception('Network error: $e');
    }
  }

  // =================== ROOM FACILITY ==============================
  // Fetch room facilities
  static Future<List<RoomFacility>> getRoomFacilities(int roomId) async {
    var response = await http.get(
      Uri.parse('$baseUrl/room_facilities?room_id=$roomId'),
    );
    if (response.statusCode == 200) {
      var roomFacilitiesJson = json.decode(response.body) as List;
      return roomFacilitiesJson
          .map((rfJson) => RoomFacility.fromJson(rfJson))
          .toList();
    } else {
      throw Exception('Failed to load room facilities');
    }
  }

  Future<void> createRoomFacility(Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$baseUrl/room_facilities'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(data),
    );
    
    if (response.statusCode != 201) {
      throw Exception('Failed to create room facility: ${response.statusCode}');
    }
  }

  Future<void> deleteRoomFacility(int roomId, int facilityId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/room_facilities?room_id=$roomId&facility_id=$facilityId'),
    );
    
    if (response.statusCode != 200) {
      throw Exception('Failed to delete room facility: ${response.statusCode}');
    }
  }


  // services/api_service.dart
  Future<void> updateRoom(int id, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$baseUrl/rooms/$id'),
      body: json.encode(data),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to update room');
    }
  }
  
  // Tambahkan method berikut ke class ApiService

  // Create new room
  Future<Room> createRoom(Map<String, dynamic> roomData) async {
    final response = await http.post(
      Uri.parse('$baseUrl/rooms'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(roomData),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create room. Status: ${response.statusCode}');
    }
  }

  // Delete room by ID
  Future<void> deleteRoom(int roomId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/rooms/$roomId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete room. Status: ${response.statusCode}');
    }
  }

  // Create booking
  static Future<bool> createBooking(Booking booking) async {
    var body = json.encode({
      'user_id': booking.userId,
      'room_id': booking.roomId,
      'booking_date': booking.bookingDate.toIso8601String(),
      'start_time': booking.startTime,
      'end_time': booking.endTime,
      'purpose': booking.purpose,
      'status': booking.status,
    });

    var response = await http.post(
      Uri.parse('$baseUrl/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 201;
  }

  // Fetch bookings
  static Future<List<Booking>> getBookings() async {
    var response = await http.get(Uri.parse('$baseUrl/bookings'));
    if (response.statusCode == 200) {
      var bookingsJson = json.decode(response.body) as List;
      return bookingsJson
          .map((bookingJson) => Booking.fromJson(bookingJson))
          .toList();
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  // Fetch approvals
  static Future<List<Approval>> getApprovals(int bookingId) async {
    var response = await http.get(
      Uri.parse('$baseUrl/approvals?booking_id=$bookingId'),
    );
    if (response.statusCode == 200) {
      var approvalsJson = json.decode(response.body) as List;
      return approvalsJson
          .map((approvalJson) => Approval.fromJson(approvalJson))
          .toList();
    } else {
      throw Exception('Failed to load approvals');
    }
  }

  // Approve booking
  static Future<bool> approveBooking(int bookingId, String note) async {
    var body = json.encode({'note': note});

    var response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/approve'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  // Reject booking
  static Future<bool> rejectBooking(int bookingId, String note) async {
    var body = json.encode({'note': note});

    var response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/reject'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  // Checkin
  static Future<bool> checkin(int bookingId, String locationGps) async {
    var body = json.encode({'location_gps': locationGps});

    var response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  // Checkout
  static Future<bool> checkout(int bookingId, String photoUrl) async {
    var body = json.encode({'photo_url': photoUrl});

    var response = await http.put(
      Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

}
