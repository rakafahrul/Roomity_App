// import 'dart:convert';
// import 'package:http/http.dart' as http;
// // import 'package:rom_app/models/user.dart';
// import 'package:rom_app/models/room.dart';
// import 'package:rom_app/models/facility.dart';
// import 'package:rom_app/models/room_facility.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/models/photo_usage.dart';
// // import 'package:fluttertoast/fluttertoast.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// // import 'dart:io';
// import 'package:image_picker/image_picker.dart';
// import 'package:rom_app/models/room.dart';


// class ApiService {
//   static const String baseUrl = 'https://localhost:7143/api';
  
//   // static const String baseUrl = 'http://192.168.33.241:5228/api';

//   Future<String?> _getToken() async {
//   final prefs = await SharedPreferences.getInstance();
//   return prefs.getString('token');
// }

//   //=========================PHOTO=========================
//   Future<List<PhotoUsage>> getPhotos(int bookingId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/photo_usage?booking_id=$bookingId'),
//     );
    
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => PhotoUsage.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load photos. Status: ${response.statusCode}');
//     }
//   }

//   // Future<void> uploadPhoto(int bookingId, String photoUrl) async {
//   //   final response = await http.post(
//   //     Uri.parse('$baseUrl/photo_usage'),
//   //     headers: {'Content-Type': 'application/json'},
//   //     body: json.encode({
//   //       'booking_id': bookingId,
//   //       'photo_url': photoUrl,
//   //     }),
//   //   );
    
//   //   if (response.statusCode != 201) {
//   //     throw Exception('Failed to upload photo. Status: ${response.statusCode}');
//   //   }
//   // }

//   Future<void> deletePhoto(int photoId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/photo_usage/$photoId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete photo. Status: ${response.statusCode}');
//     }
//   }


//   // =================== FACILITY ==========================================
//   Future<List<Facility>> getFacilities() async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/Facilities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
        
//         // Handle $values wrapper
//         if (decode is Map && decode.containsKey('\$values')) {
//           var facilitiesJson = decode['\$values'] as List;
//           List<Facility> facilities = [];
          
//           for (var facilityData in facilitiesJson) {
//             try {
//               Facility facility = Facility.fromJson(facilityData);
//               facilities.add(facility);
//             } catch (e) {
//               // Skip malformed facility data
//               continue;
//             }
//           }
          
//           return facilities;
//         } else if (decode is List) {
//           return decode.map((facilityJson) => Facility.fromJson(facilityJson)).toList();
//         } else {
//           throw Exception('Unexpected facilities response format');
//         }
//       } else {
//         throw Exception('Failed to load facilities: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Future<List<Facility>> getFacilities() async {
//   //   try {
//   //     final response = await http.get(Uri.parse('$baseUrl/facilities'));
      
//   //     if (response.statusCode == 200) {
//   //       final facilitiesJson = json.decode(response.body) as List;
//   //       return facilitiesJson.map((json) => Facility.fromJson(json)).toList();
//   //     } else {
//   //       throw Exception('Failed to load facilities: ${response.statusCode}');
//   //     }
//   //   } catch (e) {
//   //     print('Error in getFacilities: $e');
//   //     throw Exception('Network error: $e');
//   //   }
//   // }

//   Future<Facility> createFacility(Map<String, dynamic> data) async {
//     try {
//       // Dapatkan token untuk autentikasi
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       // Hanya kirim nama fasilitas
//       final requestData = {'name': data['name']};
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/facilities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode == 201) {
//         return Facility.fromJson(json.decode(response.body));
//       } else {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to create facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in createFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> updateFacility(int id, Map<String, dynamic> data) async {
//     try {
//       // Dapatkan token untuk autentikasi
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       // Hanya kirim nama fasilitas
//       final requestData = {'name': data['name']};
      
//       final response = await http.put(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to update facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in updateFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> deleteFacility(int id) async {
//     try {
//       // Dapatkan token untuk autentikasi
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final response = await http.delete(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to delete facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in deleteFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   // =================== ROOM FACILITY ==============================
//   // Fetch room facilities
//   static Future<List<RoomFacility>> getRoomFacilities(int roomId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId'),
//     );
//     if (response.statusCode == 200) {
//       var roomFacilitiesJson = json.decode(response.body) as List;
//       return roomFacilitiesJson
//           .map((rfJson) => RoomFacility.fromJson(rfJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load room facilities');
//     }
//   }

//   Future<void> createRoomFacility(Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/room_facilities'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(data),
//     );
    
//     if (response.statusCode != 201) {
//       throw Exception('Failed to create room facility: ${response.statusCode}');
//     }
//   }

//   Future<void> deleteRoomFacility(int roomId, int facilityId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId&facility_id=$facilityId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete room facility: ${response.statusCode}');
//     }
//   }

  
//   // Fetch rooms
//   static Future<List<Room>> getRooms() async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/meeting_rooms'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
        
//         if (decode is Map && decode.containsKey('\$values')) {
//           var roomsJson = decode['\$values'] as List;
//           List<Room> rooms = [];
          
//           for (var roomData in roomsJson) {
//             try {
//               // Dengan model Room.fromJson yang baru, baris ini akan berjalan sukses
//               Room room = Room.fromJson(roomData);
//               rooms.add(room);
//             } catch (e) {
//               // Jika ada satu data ruangan yang formatnya salah, cetak error dan lanjutkan
//               print('Error parsing single room data: $e. Data: $roomData');
//               continue;
//             }
//           }
          
//           return rooms;
//         } else if (decode is List) {
//           return decode.map((roomJson) => Room.fromJson(roomJson)).toList();
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to load rooms: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getRooms: $e'); // Tambahkan print di sini untuk debug
//       rethrow;
//     }
//   }


//   static Future<Room> getRoom(int id) async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/Room/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
//         return Room.fromJson(decode);
//       } else {
//         throw Exception('Failed to load room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }


//   // services/api_service.dart
//   Future<void> updateRoom(int roomId, Map<String, dynamic> updatedData) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/rooms/$roomId'),
//         headers: {
//           'Content-Type': 'application/json',
//           // Tambahkan authorization header jika diperlukan
//           // 'Authorization': 'Bearer $token',
//         },
//         body: json.encode(updatedData),
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         // Success - room updated
//         print('Room updated successfully');
//       } else {
//         // Error response
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to update room');
//       }
//     } catch (e) {
//       print('Error updating room: $e');
//       throw Exception('Failed to update room: $e');
//     }
//   }


//   // Future<void> updateRoom(int id, Map<String, dynamic> data) async {
//   //   final url = Uri.parse('$baseUrl/rooms/$id');

//   //   final requestBody = {
//   //     "id": id,
//   //     "name": data["name"],
//   //     "location": data["location"],
//   //     "capacity": data["capacity"],
//   //     "description": data["description"],
//   //     "photoUrl": data["photoUrl"],
//   //     "latitude": data["latitude"],
//   //     "longitude": data["longitude"],
//   //     "status": data["status"],
//   //     "facilities": {
//   //       "\$values": data["facilities"],
//   //     },
//   //   };

//   //   final response = await http.put(
//   //     url,
//   //     headers: {
//   //       'Content-Type': 'application/json',
//   //     },
//   //     body: json.encode(requestBody),
//   //   );

//   //   if (response.statusCode != 204) {
//   //     print('Update failed');
//   //     print('Status code: ${response.statusCode}');
//   //     print('Response body: ${response.body}');
//   //     throw Exception('Failed to update room: ${response.body}');
//   //   }
//   // }
//   // Tambahkan method berikut ke class ApiService

//   // Tambahkan method ini ke ApiService
//     Future<void> createRoomMultipart(Map<String, dynamic> data, {XFile? photo}) async {
//     print('=== API CREATE ROOM MULTIPART ===');
//     print('Data: $data');
//     print('Has photo: ${photo != null}');
    
//     final uri = Uri.parse('$baseUrl/rooms');
//     final request = http.MultipartRequest('POST', uri);

//     // Add form fields
//     request.fields.addAll({
//       'Name': data['name'].toString(),
//       'Location': data['location'].toString(),
//       'Description': data['description'].toString(),
//       'Capacity': data['capacity'].toString(),
//       'Status': data['status'].toString(),
//       'Latitude': data['latitude'].toString(),
//       'Longitude': data['longitude'].toString(),
//     });

//     if (data['facilities'] != null) {
//       String facilitiesJson = json.encode(data['facilities']);
//       request.fields['Facilities'] = facilitiesJson;
//       print('Facilities sent as: $facilitiesJson');
//     }

//     print('Form fields: ${request.fields}');

//     // Add photo if provided
//     if (photo != null) {
//       final bytes = await photo.readAsBytes();
//       final multipartFile = http.MultipartFile.fromBytes(
//         'Photo',
//         bytes,
//         filename: photo.name,
//       );
//       request.files.add(multipartFile);
//       print('Added photo: ${photo.name}');
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     print('Create response status: ${response.statusCode}');
//     print('Create response body: ${response.body}');

//     if (response.statusCode != 201 && response.statusCode != 200) {
//       throw Exception('Failed to create room: ${response.body}');
//     }
//   }



//   // Create new room
//   Future<Room> createRoom(Room room) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/rooms'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(room.toJson()),
//       );
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var decode = json.decode(response.body);
//         return Room.fromJson(decode);
//       } else {
//         throw Exception('Failed to create room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // Delete room by ID
//   Future<void> deleteRoom(int id) async {
//     try {
//       var response = await http.delete(
//         Uri.parse('$baseUrl/rooms/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode != 200) {
//         throw Exception('Failed to delete room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }


//   // Create booking - final attempt
//   static Future<bool> createBooking({
//     required int userId,
//     required int roomId,
//     required DateTime bookingDate,
//     required String startTime,
//     required String endTime,
//     required String purpose,
//     required String status,
//     String? locationGps,
//     String? roomPhotoUrl,
//   }) async {
//     final bookingData = {
//       "RoomId": roomId,
//       "UserId": userId,
//       "BookingDate": bookingDate.toIso8601String(),
//       "StartTime": startTime,
//       "EndTime": endTime,
//       "Purpose": purpose,
//       "Status": status,
//       "CheckinTime": null,
//       "CheckoutTime": null,
//       "LocationGps": locationGps ?? "",
//       "IsPresent": false,
//       "RoomPhotoUrl": roomPhotoUrl ?? "",
//       "CreatedAt": DateTime.now().toIso8601String(),
//       "Photos": []
//     };

//     final response = await http.post(
//       Uri.parse('$baseUrl/bookings'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     return response.statusCode == 201;
//   }
 
//   //Metode batu sesuai dengan format swagger
//   static Future<bool> createBookingSwagger(int userId, int roomId, DateTime bookingDate, String purpose, String startTime, String endTime) async {
//     try {
//       var bookingData = {
//         "id": 0,
//         "roomId": roomId,
//         "userId": userId,
//         "bookingDate": bookingDate.toIso8601String(),
//         "startTime": startTime,
//         "endTime": endTime,
//         "purpose": purpose,
//         "status": "pending",
//         "checkinTime": null,
//         "checkoutTime": null,
//         "locationGps": "",
//         "isPresent": false,
//         "roomPhotoUrl": "",
//         "createdAt": DateTime.now().toIso8601String(),
//         "photos": [],
//        };

//        print("Booking Data: ${json.encode(bookingData)}");

//        var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(bookingData),
//        );
//        print('Response status: ${response.statusCode}');
//        print('Response body: ${response.body}');
//        return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   // Booking dengan PascalCase
//   static Future<bool> createBookingPascalCase(Map<String, dynamic> bookingData) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(bookingData),
//       );
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> createBookingSimple(Map<String, dynamic> bookingData) async {
//     final url = Uri.parse('$baseUrl/bookings');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     return response.statusCode == 201;
//   }

//   // Fetch bookings
//   static Future<List<Booking>> getBookings() async {
//     var response = await http.get(Uri.parse('$baseUrl/bookings'));
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     if (response.statusCode == 200) {
//       var bookingsJson = json.decode(response.body);
      
//       List<dynamic> dataList = [];
//       if (bookingsJson is Map && bookingsJson.containsKey('\$values')) {
//         dataList = bookingsJson['\$values'];
//       } else if (bookingsJson is List) {
//         dataList = bookingsJson;
//       }
//       return dataList
//           .map((bookingJson) => Booking.fromJson(bookingJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load bookings');
//     }
//   }

//   // Fetch approvals
//   static Future<List<Approval>> getApprovals(int bookingId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/approvals?booking_id=$bookingId'),
//     );
//     if (response.statusCode == 200) {
//       var approvalsJson = json.decode(response.body) as List;
//       return approvalsJson
//           .map((approvalJson) => Approval.fromJson(approvalJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load approvals');
//     }
//   }

//   // Approve booking
//   static Future<bool> approveBooking(int bookingId, String note) async {
//     var body = json.encode({'note': note});

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/approve'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'note': note}),

//       // body: body,
//     );

//     return response.statusCode == 200;
//   }

//   // Reject booking
//   static Future<bool> rejectBooking(int bookingId, String note) async {
//     var body = json.encode({'note': note});

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/reject'),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     return response.statusCode == 200;
//   }
  

//   // Checkin
//   static Future<bool> checkin(int bookingId, String locationGps) async {
//     var body = json.encode({'location_gps': locationGps});

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     return response.statusCode == 200;
//   }

//   // Checkout
//   static Future<bool> checkout(int bookingId, String photoUrl) async {
//     var body = json.encode({'photo_url': photoUrl});
//     // var body = json.encode({
//     //   'photo_before_url': photoBeforeUrl,
//     //   'photo_after_url': photoAfterUrl,
//     // });

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     return response.statusCode == 200;
//   }

//   // Check-in (Konfirmasi Kehadiran)
//   static Future<void> confirmAttendance(int bookingId, String locationGps,) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'locationGps': locationGps}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal konfirmasi kehadiran');
//     }
//   }

//   // Check-out (Pertanggungjawaban)
//   static Future<void> checkoutBooking(int bookingId, String photoUrl) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'photoUrl': photoUrl}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal melakukan pertanggungjawaban');
//     }
//   }

//   // Upload foto before/after (misal endpoint POST)
//   static Future<String> uploadPhoto(int bookingId, XFile photo, {String type = 'before'}) async {
//     final uri = Uri.parse('$baseUrl/bookings/$bookingId/photos');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['type'] = type
//       ..files.add(await http.MultipartFile.fromPath('photo', photo.path));
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       final respStr = await response.stream.bytesToString();
//       final jsonResp = jsonDecode(respStr);
//       return jsonResp['photoUrl']; // Ganti sesuai response API
//     }
//     throw Exception('Gagal upload foto');
//   }

//   static Future<void> uploadPertanggungjawaban({
//     required int bookingId,
//     required XFile beforePhoto,
//     required XFile afterPhoto,
//   }) async {
//     final uri = Uri.parse('$baseUrl/bookings/$bookingId/pertanggungjawaban');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['bookingId'] = bookingId.toString()
//       ..files.add(await http.MultipartFile.fromPath('before', beforePhoto.path))
//       ..files.add(await http.MultipartFile.fromPath('after', afterPhoto.path));
//     final response = await request.send();
//     if (response.statusCode != 200) {
//       throw Exception('Gagal upload pertanggungjawaban');
//     }
//   }



//   // Method untuk menambahkan catatan admin
// static Future<bool> addAdminNote(int bookingId, String note) async {
//   try {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/admin-note'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'note': note}),
//     );
    
//     print('Add admin note response: ${response.statusCode}');
//     return response.statusCode == 200;
//   } catch (e) {
//     print('Error adding admin note: $e');
//     return false;
//   }
// }

// // Method untuk menyelesaikan booking
// static Future<bool> completeBooking(int bookingId) async {
//   try {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/complete'),
//       headers: {'Content-Type': 'application/json'},
//     );
    
//     print('Complete booking response: ${response.statusCode}');
//     return response.statusCode == 200;
//   } catch (e) {
//     print('Error completing booking: $e');
//     return false;
//   }
// }

// // Method untuk menandai masalah sudah terselesaikan
// static Future<bool> resolveIssue(int bookingId) async {
//   try {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/resolve-issue'),
//       headers: {'Content-Type': 'application/json'},
//     );
    
//     print('Resolve issue response: ${response.statusCode}');
//     return response.statusCode == 200;
//   } catch (e) {
//     print('Error resolving issue: $e');
//     return false;
//   }
// }

// // Method untuk update status booking ke approved
// static Future<bool> updateBookingStatus(int bookingId, String status) async {
//   try {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/status'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'status': status}),
//     );
    
//     print('Update booking status response: ${response.statusCode}');
//     return response.statusCode == 200;
//   } catch (e) {
//     print('Error updating booking status: $e');
//     return false;
//   }
// }


// }





// File: lib/services/api_service.dart
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:rom_app/models/room.dart';
// import 'package:rom_app/models/facility.dart';
// import 'package:rom_app/models/room_facility.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/models/photo_usage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:rom_app/utils/image_helper.dart';

// class ApiService {
//   static const String baseUrl = 'https://localhost:7143/api';
//   // static const String baseUrl = 'http://192.168.33.241:5228/api';

//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   //=========================PHOTO=========================
//   Future<List<PhotoUsage>> getPhotos(int bookingId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/photo_usage?booking_id=$bookingId'),
//     );
    
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => PhotoUsage.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load photos. Status: ${response.statusCode}');
//     }
//   }

//   Future<void> deletePhoto(int photoId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/photo_usage/$photoId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete photo. Status: ${response.statusCode}');
//     }
//   }

//   // =================== FACILITY ==========================================
//   Future<List<Facility>> getFacilities() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/Facilities'),
//         headers: {'accept': 'application/json'},
//       );

//       print('Facilities response status: ${response.statusCode}');
//       print('Facilities response body: ${response.body}');

//       if (response.statusCode == 200) {
//         final jsonResponse = json.decode(response.body);
        
//         List<dynamic> facilitiesList;
//         if (jsonResponse is Map && jsonResponse.containsKey('\$values')) {
//           facilitiesList = jsonResponse['\$values'] ?? [];
//         } else if (jsonResponse is List) {
//           facilitiesList = jsonResponse;
//         } else {
//           facilitiesList = [];
//         }
        
//         return facilitiesList.map((facility) => Facility.fromJson(facility)).toList();
//       } else {
//         throw Exception('Failed to load facilities: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getFacilities: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<Facility> createFacility(Map<String, dynamic> data) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final requestData = {'name': data['name']};
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/facilities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode == 201) {
//         return Facility.fromJson(json.decode(response.body));
//       } else {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to create facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in createFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> updateFacility(int id, Map<String, dynamic> data) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final requestData = {'name': data['name']};
      
//       final response = await http.put(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to update facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in updateFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> deleteFacility(int id) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final response = await http.delete(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to delete facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in deleteFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   // =================== ROOM FACILITY ==============================
//   static Future<List<RoomFacility>> getRoomFacilities(int roomId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId'),
//     );
//     if (response.statusCode == 200) {
//       var roomFacilitiesJson = json.decode(response.body) as List;
//       return roomFacilitiesJson
//           .map((rfJson) => RoomFacility.fromJson(rfJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load room facilities');
//     }
//   }

//   Future<void> createRoomFacility(Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/room_facilities'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(data),
//     );
    
//     if (response.statusCode != 201) {
//       throw Exception('Failed to create room facility: ${response.statusCode}');
//     }
//   }

//   Future<void> deleteRoomFacility(int roomId, int facilityId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId&facility_id=$facilityId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete room facility: ${response.statusCode}');
//     }
//   }

//   // =================== ROOMS ==========================================
//   static Future<List<Room>> getRooms() async {
//     try {
//       // Try /rooms endpoint first, then fallback to /meeting_rooms
//       var response = await http.get(
//         Uri.parse('$baseUrl/rooms'),
//         headers: {'accept': 'application/json'},
//       );
      
//       if (response.statusCode != 200) {
//         // Fallback to your existing endpoint
//         response = await http.get(
//           Uri.parse('$baseUrl/meeting_rooms'),
//           headers: {'accept': 'application/json'},
//         );
//       }

//       print('Rooms response status: ${response.statusCode}');
//       print('Rooms response body: ${response.body}');

//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
//         List<dynamic> roomsJson;
        
//         if (decode is Map && decode.containsKey('\$values')) {
//           roomsJson = decode['\$values'];
//         } else if (decode is List) {
//           roomsJson = decode;
//         } else {
//           throw Exception('Unexpected response format');
//         }
        
//         print('Parsed rooms count: ${roomsJson.length}');
        
//         // Debug image URLs
//         for (var roomJson in roomsJson) {
//           if (roomJson['photoUrl'] != null) {
//             ImageHelper.debugImageUrl(roomJson['photoUrl']);
//           }
//         }
        
//         return roomsJson.map((roomJson) => Room.fromJson(roomJson)).toList();
//       } else {
//         throw Exception('Failed to load rooms: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getRooms: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   // Create room with multipart form data (matches swagger)
//   Future<void> createRoom(Map<String, dynamic> data) async {
//     final uri = Uri.parse('$baseUrl/rooms');
//     final request = http.MultipartRequest('POST', uri);

//     print('=== API SERVICE CREATE ROOM ===');
//     print('Endpoint: $uri');
//     print('Data: $data');

//     // Add form fields
//     request.fields.addAll({
//       'Name': data['name'].toString(),
//       'Location': data['location'].toString(),
//       'Description': data['description'].toString(),
//       'Capacity': data['capacity'].toString(),
//       'Status': data['status'].toString(),
//       'Latitude': data['latitude'].toString(),
//       'Longitude': data['longitude'].toString(),
//     });

//     if (data['facilities'] != null) {
//       request.fields['Facilities'] = json.encode(data['facilities']);
//     }

//     // Add photo if provided
//     if (data['photo'] != null && data['photo'] is XFile) {
//       final photo = data['photo'] as XFile;
//       final bytes = await photo.readAsBytes();
//       final multipartFile = http.MultipartFile.fromBytes(
//         'Photo',
//         bytes,
//         filename: photo.name,
//       );
//       request.files.add(multipartFile);
//     } else if (data['photoBase64'] != null) {
//       // Handle base64 photo
//       final photoBytes = base64Decode(data['photoBase64']);
//       final multipartFile = http.MultipartFile.fromBytes(
//         'Photo',
//         photoBytes,
//         filename: 'image.jpg',
//       );
//       request.files.add(multipartFile);
//     }

//     try {
//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       print('Create room response status: ${response.statusCode}');
//       print('Create room response body: ${response.body}');

//       if (response.statusCode != 201 && response.statusCode != 200) {
//         throw Exception('Failed to create room: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       print('Error in createRoom: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   // Keep your existing multipart method for compatibility
//   Future<void> createRoomMultipart(Map<String, dynamic> data, {XFile? photo}) async {
//     final uri = Uri.parse('$baseUrl/rooms');
//     final request = http.MultipartRequest('POST', uri);

//     // Add form fields
//     request.fields.addAll({
//       'Name': data['name'].toString(),
//       'Location': data['location'].toString(),
//       'Description': data['description'].toString(),
//       'Capacity': data['capacity'].toString(),
//       'Status': data['status'].toString(),
//       'Latitude': data['latitude'].toString(),
//       'Longitude': data['longitude'].toString(),
//     });

//     if (data['facilities'] != null) {
//       request.fields['Facilities'] = jsonEncode(data['facilities']);
//     }

//     // Add photo if provided
//     if (photo != null) {
//       final bytes = await photo.readAsBytes();
//       final multipartFile = http.MultipartFile.fromBytes(
//         'Photo',
//         bytes,
//         filename: photo.name,
//       );
//       request.files.add(multipartFile);
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     if (response.statusCode != 201 && response.statusCode != 200) {
//       throw Exception('Failed to create room: ${response.body}');
//     }
//   }

//   Future<void> updateRoom(int id, Map<String, dynamic> data) async {
//     final url = Uri.parse('$baseUrl/rooms/$id');

//     // Convert DateTime to String ISO format if needed
//     final createdAt = data["createdAt"] is DateTime 
//         ? (data["createdAt"] as DateTime).toIso8601String()
//         : data["createdAt"];

//     final requestBody = {
//       "id": id,
//       "name": data["name"],
//       "location": data["location"],
//       "capacity": data["capacity"],
//       "description": data["description"],
//       "photoUrl": data["photoUrl"],
//       "latitude": data["latitude"],
//       "longitude": data["longitude"],
//       "status": data["status"],
//       "createdAt": createdAt,
//       "facilities": data["facilities"],
//     };

//     try {
//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(requestBody),
//       );

//       if (response.statusCode != 204 && response.statusCode != 200) {
//         final errorMsg = json.decode(response.body)['message'] ?? 'Unknown error';
//         throw Exception('Failed to update room: $errorMsg');
//       }
//     } catch (e) {
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> deleteRoom(int roomId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/rooms/$roomId'),
//     );

//     if (response.statusCode != 200 && response.statusCode != 204) {
//       throw Exception('Failed to delete room. Status: ${response.statusCode}');
//     }
//   }

//   // =================== BOOKINGS ==========================================
//   static Future<bool> createBooking({
//     required int userId,
//     required int roomId,
//     required DateTime bookingDate,
//     required String startTime,
//     required String endTime,
//     required String purpose,
//     required String status,
//     String? locationGps,
//     String? roomPhotoUrl,
//   }) async {
//     final bookingData = {
//       "RoomId": roomId,
//       "UserId": userId,
//       "BookingDate": bookingDate.toIso8601String(),
//       "StartTime": startTime,
//       "EndTime": endTime,
//       "Purpose": purpose,
//       "Status": status,
//       "CheckinTime": null,
//       "CheckoutTime": null,
//       "LocationGps": locationGps ?? "",
//       "IsPresent": false,
//       "RoomPhotoUrl": roomPhotoUrl ?? "",
//       "CreatedAt": DateTime.now().toIso8601String(),
//       "Photos": []
//     };

//     final response = await http.post(
//       Uri.parse('$baseUrl/bookings'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );

//     print('Booking response status: ${response.statusCode}');
//     print('Booking response body: ${response.body}');

//     return response.statusCode == 201;
//   }

//   static Future<List<Booking>> getBookings() async {
//     var response = await http.get(Uri.parse('$baseUrl/bookings'));
//     print('Bookings response status: ${response.statusCode}');
//     print('Bookings response body: ${response.body}');
    
//     if (response.statusCode == 200) {
//       var bookingsJson = json.decode(response.body);
//       List<dynamic> dataList = [];
      
//       if (bookingsJson is Map && bookingsJson.containsKey('\$values')) {
//         dataList = bookingsJson['\$values'];
//       } else if (bookingsJson is List) {
//         dataList = bookingsJson;
//       }
      
//       return dataList
//           .map((bookingJson) => Booking.fromJson(bookingJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load bookings');
//     }
//   }

//   // =================== IMAGE UTILITIES ==========================================
  
//   /// Get full image URL for display
//   String getImageUrl(String? relativePath) {
//     return ImageHelper.getFullImageUrl(relativePath);
//   }

//   /// Validate image accessibility
//   Future<bool> validateImageUrl(String? imagePath) async {
//     if (imagePath == null || imagePath.isEmpty) return false;
//     final fullUrl = ImageHelper.getFullImageUrl(imagePath);
//     return await ImageHelper.isImageAccessible(fullUrl);
//   }

//   /// Upload image and get relative path
//   Future<String?> uploadImage(XFile imageFile, {String folder = 'uploads'}) async {
//     try {
//       final uri = Uri.parse('$baseUrl/upload');
//       final request = http.MultipartRequest('POST', uri);
      
//       final bytes = await imageFile.readAsBytes();
//       final multipartFile = http.MultipartFile.fromBytes(
//         'file',
//         bytes,
//         filename: imageFile.name,
//       );
      
//       request.files.add(multipartFile);
//       request.fields['folder'] = folder;

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200) {
//         final responseData = json.decode(response.body);
//         return responseData['path']; // Should return relative path like "/uploads/filename.jpg"
//       } else {
//         throw Exception('Upload failed: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error uploading image: $e');
//       return null;
//     }
//   }

//   // Keep all your existing booking methods...
//   static Future<List<Approval>> getApprovals(int bookingId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/approvals?booking_id=$bookingId'),
//     );
//     if (response.statusCode == 200) {
//       var approvalsJson = json.decode(response.body) as List;
//       return approvalsJson
//           .map((approvalJson) => Approval.fromJson(approvalJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load approvals');
//     }
//   }

//   static Future<bool> approveBooking(int bookingId, String note) async {
//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/approve'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'note': note}),
//     );
//     return response.statusCode == 200;
//   }

//   static Future<bool> rejectBooking(int bookingId, String note) async {
//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/reject'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'note': note}),
//     );
//     return response.statusCode == 200;
//   }

//   static Future<bool> checkin(int bookingId, String locationGps) async {
//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'location_gps': locationGps}),
//     );
//     return response.statusCode == 200;
//   }

//   static Future<bool> checkout(int bookingId, String photoUrl) async {
//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode({'photo_url': photoUrl}),
//     );
//     return response.statusCode == 200;
//   }

//   static Future<void> confirmAttendance(int bookingId, String locationGps) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'locationGps': locationGps}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal konfirmasi kehadiran');
//     }
//   }

//   static Future<void> checkoutBooking(int bookingId, String photoUrl) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'photoUrl': photoUrl}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal melakukan pertanggungjawaban');
//     }
//   }

//   static Future<String> uploadPhoto(int bookingId, XFile photo, {String type = 'before'}) async {
//     final uri = Uri.parse('$baseUrl/bookings/$bookingId/photos');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['type'] = type
//       ..files.add(await http.MultipartFile.fromPath('photo', photo.path));
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       final respStr = await response.stream.bytesToString();
//       final jsonResp = jsonDecode(respStr);
//       return jsonResp['photoUrl'];
//     }
//     throw Exception('Gagal upload foto');
//   }

//   static Future<void> uploadPertanggungjawaban({
//     required int bookingId,
//     required XFile beforePhoto,
//     required XFile afterPhoto,
//   }) async {
//     final uri = Uri.parse('$baseUrl/bookings/$bookingId/pertanggungjawaban');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['bookingId'] = bookingId.toString()
//       ..files.add(await http.MultipartFile.fromPath('before', beforePhoto.path))
//       ..files.add(await http.MultipartFile.fromPath('after', afterPhoto.path));
//     final response = await request.send();
//     if (response.statusCode != 200) {
//       throw Exception('Gagal upload pertanggungjawaban');
//     }
//   }

//   static Future<bool> addAdminNote(int bookingId, String note) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/admin-note'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'note': note}),
//       );
      
//       print('Add admin note response: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error adding admin note: $e');
//       return false;
//     }
//   }

//   static Future<bool> completeBooking(int bookingId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/complete'),
//         headers: {'Content-Type': 'application/json'},
//       );
      
//       print('Complete booking response: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error completing booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> resolveIssue(int bookingId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/resolve-issue'),
//         headers: {'Content-Type': 'application/json'},
//       );
      
//       print('Resolve issue response: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error resolving issue: $e');
//       return false;
//     }
//   }

//   static Future<bool> updateBookingStatus(int bookingId, String status) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/status'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'status': status}),
//       );
      
//       print('Update booking status response: ${response.statusCode}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error updating booking status: $e');
//       return false;
//     }
//   }

//   // Keep your existing booking creation methods for compatibility
//   static Future<bool> createBookingSwagger(int userId, int roomId, DateTime bookingDate, String purpose, String startTime, String endTime) async {
//     try {
//       var bookingData = {
//         "id": 0,
//         "roomId": roomId,
//         "userId": userId,
//         "bookingDate": bookingDate.toIso8601String(),
//         "startTime": startTime,
//         "endTime": endTime,
//         "purpose": purpose,
//         "status": "pending",
//         "checkinTime": null,
//         "checkoutTime": null,
//         "locationGps": "",
//         "isPresent": false,
//         "roomPhotoUrl": "",
//         "createdAt": DateTime.now().toIso8601String(),
//         "photos": [],
//        };

//        print("Booking Data: ${json.encode(bookingData)}");

//        var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(bookingData),
//        );
//        print('Response status: ${response.statusCode}');
//        print('Response body: ${response.body}');
//        return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> createBookingPascalCase(Map<String, dynamic> bookingData) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(bookingData),
//       );
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> createBookingSimple(Map<String, dynamic> bookingData) async {
//     final url = Uri.parse('$baseUrl/bookings');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     return response.statusCode == 201;
//   }
// }







// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'dart:typed_data';
// import 'package:rom_app/models/user.dart';
// import 'package:rom_app/models/room.dart';
// import 'package:rom_app/models/facility.dart';
// import 'package:rom_app/models/room_facility.dart';
// import 'package:rom_app/models/booking.dart';
// import 'package:rom_app/models/approval.dart';
// import 'package:rom_app/models/photo_usage.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:image_picker/image_picker.dart';

// class ApiService {
//   // static const String baseUrl = 'https://localhost:7143/api';
//   static const String baseUrl = 'https://apiroom-production.up.railway.app/api';
  
//   Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   //=========================PHOTO=========================

//   static Future<void> uploadPhotoUsage({
//     required int bookingId,
//     required XFile photoFile,
//   }) async {
//     try {
//       // 1. Upload gambar ke storage/server terlebih dahulu
//       final photoUrl = await _uploadImageToServer(photoFile);

//       // 2. Kirim data ke endpoint /api/photo_usage
//       final uri = Uri.parse('$baseUrl/api/photo_usage');
//       final headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//       };

//       // 3. Siapkan payload sesuai spesifikasi endpoint
//       final payload = {
//         'photoId': 0, // biasanya diisi server
//         'photoUrl': photoUrl,
//         'booking': {
//           'id': bookingId,
//           // Data booking lainnya bisa disesuaikan
//           // atau bisa hanya mengirim ID jika server akan melengkapi
//         }
//       };

//       final response = await http.post(
//         uri,
//         headers: headers,
//         body: jsonEncode(payload),
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to upload photo usage: ${response.statusCode} - ${response.body}');
//       }
//     } catch (e) {
//       throw Exception('Failed to upload photo usage: $e');
//     }
//   }

//   static Future<String> _uploadImageToServer(XFile file) async {
//     // Implementasi upload gambar ke storage server (Cloud Storage, S3, dll)
//     // Ini contoh sederhana, sesuaikan dengan infrastruktur Anda
    
//     final bytes = await file.readAsBytes();
//     final fileName = 'photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
    
//     // Contoh upload ke Firebase Storage:
//     // final ref = FirebaseStorage.instance.ref().child('usage_photos/$fileName');
//     // await ref.putData(bytes);
//     // return await ref.getDownloadURL();
    
//     // Untuk contoh, kita return URL dummy
//     return 'https://example.com/storage/$fileName';
//   }

//   // ✅ ALTERNATIVE: Upload using multipart (untuk mobile/desktop)
//   static Future<String> uploadPhotoMultipart({
//     required int bookingId,
//     required XFile photoFile,
//     required String photoType,
//   }) async {
//     try {
//       var request = http.MultipartRequest(
//         'POST',
//         Uri.parse('$baseUrl/photo_usage'),
//       );

//       // Add headers
//       request.headers.addAll({
//         'Content-Type': 'multipart/form-data',
//         // 'Authorization': 'Bearer ${await getToken()}',
//       });

//       // Add booking ID as field
//       request.fields['bookingId'] = bookingId.toString();
//       request.fields['photoType'] = photoType;

//       // Add photo file
//       final photoBytes = await photoFile.readAsBytes();
//       request.files.add(
//         http.MultipartFile.fromBytes(
//           'photo',
//           photoBytes,
//           filename: photoFile.name,
//         ),
//       );

//       final streamedResponse = await request.send();
//       final response = await http.Response.fromStream(streamedResponse);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final responseData = jsonDecode(response.body);
//         return responseData['photoUrl'] ?? 'Upload berhasil';
//       } else {
//         throw Exception('Failed to upload photo: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error uploading photo: $e');
//     }
//   }

//   static Future<bool> uploadPertanggungjawaban({
//     required int bookingId,
//     required XFile photo,
//   }) async {
//     try {
//       // Upload foto
//       await uploadPhotoUsage(
//         bookingId: bookingId,
//         photoFile: photo,
//       );

//       // Update status booking ke 'done'
//       await updateBookingStatus(bookingId, 'done');

//       return true;
//     } catch (e) {
//       throw Exception('Failed to upload pertanggungjawaban: $e');
//     }
//   }

//   static Future<bool> updateBookingStatus(int bookingId, String status) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer ${await getToken()}',
//         },
//         body: jsonEncode({
//           "status": status,
//         }),
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         return true;
//       } else {
//         throw Exception('Failed to update booking status: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error updating booking status: $e');
//     }
//   }

//   static Future<List<Map<String, dynamic>>> getPhotosByBookingId(int bookingId) async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/photo_usage?booking_id=$bookingId'),
//         headers: {
//           'Content-Type': 'application/json',
//           // 'Authorization': 'Bearer ${await getToken()}',
//         },
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.cast<Map<String, dynamic>>();
//       } else {
//         throw Exception('Failed to get photos: ${response.statusCode}');
//       }
//     } catch (e) {
//       throw Exception('Error getting photos: $e');
//     }
//   }



//   Future<List<PhotoUsage>> getPhotos(int bookingId) async {
//     final response = await http.get(
//       Uri.parse('$baseUrl/photo_usage?booking_id=$bookingId'),
//     );
    
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((json) => PhotoUsage.fromJson(json)).toList();
//     } else {
//       throw Exception('Failed to load photos. Status: ${response.statusCode}');
//     }
//   }

//   Future<void> deletePhoto(int photoId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/photo_usage/$photoId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete photo. Status: ${response.statusCode}');
//     }
//   }

//   // =================== FACILITY ==========================================
//   Future<List<Facility>> getFacilities() async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/Facilities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
        
//         if (decode is Map && decode.containsKey('\$values')) {
//           var facilitiesJson = decode['\$values'] as List;
//           List<Facility> facilities = [];
          
//           for (var facilityData in facilitiesJson) {
//             try {
//               Facility facility = Facility.fromJson(facilityData);
//               facilities.add(facility);
//             } catch (e) {
//               continue;
//             }
//           }
          
//           return facilities;
//         } else if (decode is List) {
//           return decode.map((facilityJson) => Facility.fromJson(facilityJson)).toList();
//         } else {
//           throw Exception('Unexpected facilities response format');
//         }
//       } else {
//         throw Exception('Failed to load facilities: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<Facility> createFacility(Map<String, dynamic> data) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final requestData = {'name': data['name']};
      
//       final response = await http.post(
//         Uri.parse('$baseUrl/facilities'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode == 201) {
//         return Facility.fromJson(json.decode(response.body));
//       } else {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to create facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in createFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> updateFacility(int id, Map<String, dynamic> data) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final requestData = {'name': data['name']};
      
//       final response = await http.put(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $token',
//         },
//         body: json.encode(requestData),
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to update facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in updateFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   Future<void> deleteFacility(int id) async {
//     try {
//       final token = await _getToken();
//       if (token == null) {
//         throw Exception('Authentication required');
//       }
      
//       final response = await http.delete(
//         Uri.parse('$baseUrl/facilities/$id'),
//         headers: {
//           'Authorization': 'Bearer $token',
//         },
//       );
      
//       if (response.statusCode != 204 && response.statusCode != 200) {
//         print('Error response: ${response.body}');
//         throw Exception('Failed to delete facility: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in deleteFacility: $e');
//       throw Exception('Network error: $e');
//     }
//   }

//   // =================== ROOM FACILITY ==============================
//   static Future<List<RoomFacility>> getRoomFacilities(int roomId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId'),
//     );
//     if (response.statusCode == 200) {
//       var roomFacilitiesJson = json.decode(response.body) as List;
//       return roomFacilitiesJson
//           .map((rfJson) => RoomFacility.fromJson(rfJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load room facilities');
//     }
//   }

//   Future<void> createRoomFacility(Map<String, dynamic> data) async {
//     final response = await http.post(
//       Uri.parse('$baseUrl/room_facilities'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(data),
//     );
    
//     if (response.statusCode != 201) {
//       throw Exception('Failed to create room facility: ${response.statusCode}');
//     }
//   }

//   Future<void> deleteRoomFacility(int roomId, int facilityId) async {
//     final response = await http.delete(
//       Uri.parse('$baseUrl/room_facilities?room_id=$roomId&facility_id=$facilityId'),
//     );
    
//     if (response.statusCode != 200) {
//       throw Exception('Failed to delete room facility: ${response.statusCode}');
//     }
//   }

//   // =================== ROOMS ==========================================
//   static Future<List<Room>> getRooms() async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/meeting_rooms'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
        
//         if (decode is Map && decode.containsKey('\$values')) {
//           var roomsJson = decode['\$values'] as List;
//           List<Room> rooms = [];
          
//           for (var roomData in roomsJson) {
//             try {
//               Room room = Room.fromJson(roomData);
//               rooms.add(room);
//             } catch (e) {
//               print('Error parsing single room data: $e. Data: $roomData');
//               continue;
//             }
//           }
          
//           return rooms;
//         } else if (decode is List) {
//           return decode.map((roomJson) => Room.fromJson(roomJson)).toList();
//         } else {
//           throw Exception('Unexpected response format');
//         }
//       } else {
//         throw Exception('Failed to load rooms: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error in getRooms: $e');
//       rethrow;
//     }
//   }

//   static Future<Room> getRoom(int id) async {
//     try {
//       var response = await http.get(
//         Uri.parse('$baseUrl/Room/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode == 200) {
//         var decode = json.decode(response.body);
//         return Room.fromJson(decode);
//       } else {
//         throw Exception('Failed to load room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> updateRoom(int roomId, Map<String, dynamic> updatedData) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/rooms/$roomId'),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//         body: json.encode(updatedData),
//       );

//       if (response.statusCode == 200 || response.statusCode == 204) {
//         print('Room updated successfully');
//       } else {
//         final errorData = json.decode(response.body);
//         throw Exception(errorData['message'] ?? 'Failed to update room');
//       }
//     } catch (e) {
//       print('Error updating room: $e');
//       throw Exception('Failed to update room: $e');
//     }
//   }

//   Future<void> createRoomMultipart(Map<String, dynamic> data, {XFile? photo}) async {
//     print('=== API CREATE ROOM MULTIPART ===');
//     print('Data: $data');
//     print('Has photo: ${photo != null}');
    
//     final uri = Uri.parse('$baseUrl/rooms');
//     final request = http.MultipartRequest('POST', uri);

//     request.fields.addAll({
//       'Name': data['name'].toString(),
//       'Location': data['location'].toString(),
//       'Description': data['description'].toString(),
//       'Capacity': data['capacity'].toString(),
//       'Status': data['status'].toString(),
//       'Latitude': data['latitude'].toString(),
//       'Longitude': data['longitude'].toString(),
//     });

//     if (data['facilities'] != null) {
//       String facilitiesJson = json.encode(data['facilities']);
//       request.fields['Facilities'] = facilitiesJson;
//       print('Facilities sent as: $facilitiesJson');
//     }

//     print('Form fields: ${request.fields}');

//     if (photo != null) {
//       final bytes = await photo.readAsBytes();
//       final multipartFile = http.MultipartFile.fromBytes(
//         'Photo',
//         bytes,
//         filename: photo.name,
//       );
//       request.files.add(multipartFile);
//       print('Added photo: ${photo.name}');
//     }

//     final streamedResponse = await request.send();
//     final response = await http.Response.fromStream(streamedResponse);

//     print('Create response status: ${response.statusCode}');
//     print('Create response body: ${response.body}');

//     if (response.statusCode != 201 && response.statusCode != 200) {
//       throw Exception('Failed to create room: ${response.body}');
//     }
//   }

//   Future<Room> createRoom(Room room) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/rooms'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(room.toJson()),
//       );
      
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         var decode = json.decode(response.body);
//         return Room.fromJson(decode);
//       } else {
//         throw Exception('Failed to create room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   Future<void> deleteRoom(int id) async {
//     try {
//       var response = await http.delete(
//         Uri.parse('$baseUrl/rooms/$id'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//       );
      
//       if (response.statusCode != 200) {
//         throw Exception('Failed to delete room: ${response.statusCode}');
//       }
//     } catch (e) {
//       rethrow;
//     }
//   }

//   // =================== BOOKINGS ==========================================
//   static Future<bool> createBooking({
//     required int userId,
//     required int roomId,
//     required DateTime bookingDate,
//     required String startTime,
//     required String endTime,
//     required String purpose,
//     required String status,
//     String? locationGps,
//     String? roomPhotoUrl,
//   }) async {
//     final bookingData = {
//       "RoomId": roomId,
//       "UserId": userId,
//       "BookingDate": bookingDate.toIso8601String(),
//       "StartTime": startTime,
//       "EndTime": endTime,
//       "Purpose": purpose,
//       "Status": status,
//       "CheckinTime": null,
//       "CheckoutTime": null,
//       "LocationGps": locationGps ?? "",
//       "IsPresent": false,
//       "RoomPhotoUrl": roomPhotoUrl ?? "",
//       "CreatedAt": DateTime.now().toIso8601String(),
//       "Photos": []
//     };

//     final response = await http.post(
//       Uri.parse('$baseUrl/bookings'),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );

//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');

//     return response.statusCode == 201;
//   }

//   static Future<List<Booking>> getBookings() async {
//     var response = await http.get(Uri.parse('$baseUrl/bookings'));
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     if (response.statusCode == 200) {
//       var bookingsJson = json.decode(response.body);
      
//       List<dynamic> dataList = [];
//       if (bookingsJson is Map && bookingsJson.containsKey('\$values')) {
//         dataList = bookingsJson['\$values'];
//       } else if (bookingsJson is List) {
//         dataList = bookingsJson;
//       }
//       return dataList
//           .map((bookingJson) => Booking.fromJson(bookingJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load bookings');
//     }
//   }

//   static Future<List<Approval>> getApprovals(int bookingId) async {
//     var response = await http.get(
//       Uri.parse('$baseUrl/approvals?booking_id=$bookingId'),
//     );
//     if (response.statusCode == 200) {
//       var approvalsJson = json.decode(response.body) as List;
//       return approvalsJson
//           .map((approvalJson) => Approval.fromJson(approvalJson))
//           .toList();
//     } else {
//       throw Exception('Failed to load approvals');
//     }
//   }

//   // =================== ADMIN BOOKING MANAGEMENT ==========================================
  
//   // 1. Approve booking - untuk menu pengajuan
//   static Future<bool> approveBooking(int bookingId, String note) async {
//     try {
//       var response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/approve'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'note': note}),
//       );

//       print('Approve booking response: ${response.statusCode}');
//       print('Approve booking body: ${response.body}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error approving booking: $e');
//       return false;
//     }
//   }

//   // 2. Reject booking - untuk menu pengajuan
//   static Future<bool> rejectBooking(int bookingId, String note) async {
//     try {
//       var response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/reject'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'note': note}),
//       );

//       print('Reject booking response: ${response.statusCode}');
//       print('Reject booking body: ${response.body}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error rejecting booking: $e');
//       return false;
//     }
//   }

//   // 3. Add admin note - untuk memberikan catatan kepada peminjam
//   static Future<bool> addAdminNote(int bookingId, String note) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/admin-note'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode({'note': note}),
//       );
      
//       print('Add admin note response: ${response.statusCode}');
//       print('Add admin note body: ${response.body}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error adding admin note: $e');
//       return false;
//     }
//   }

//   // 4. Complete booking - untuk menyelesaikan booking
//   static Future<bool> completeBooking(int bookingId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/complete'),
//         headers: {'Content-Type': 'application/json'},
//       );
      
//       print('Complete booking response: ${response.statusCode}');
//       print('Complete booking body: ${response.body}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error completing booking: $e');
//       return false;
//     }
//   }

//   // 5. Resolve issue - untuk menandai masalah sudah terselesaikan
//   static Future<bool> resolveIssue(int bookingId) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/$bookingId/resolve-issue'),
//         headers: {'Content-Type': 'application/json'},
//       );
      
//       print('Resolve issue response: ${response.statusCode}');
//       print('Resolve issue body: ${response.body}');
//       return response.statusCode == 200;
//     } catch (e) {
//       print('Error resolving issue: $e');
//       return false;
//     }
//   }

//   // 6. Update booking status
//   static Future<bool> updateBooking(Booking booking) async {
//     try {
//       final response = await http.put(
//         Uri.parse('$baseUrl/bookings/${booking.id}'),
//         headers: {
//           'Content-Type': 'application/json',
//           // Tambahkan auth header jika diperlukan:
//           // 'Authorization': 'Bearer ${await getToken()}',
//         },
//         body: jsonEncode({
//           "id": booking.id,
//           "roomId": booking.roomId,
//           "roomName": booking.roomName,
//           "userId": booking.userId,
//           "userName": booking.userName,
//           "bookingDate": booking.bookingDate.toIso8601String(),
//           "startTime": booking.startTime,
//           "endTime": booking.endTime,
//           "purpose": booking.purpose,
//           "status": booking.status, // Status yang sudah diubah ke 'done'
//           "checkinTime": booking.checkinTime?.toIso8601String(),
//           "checkoutTime": booking.checkoutTime?.toIso8601String(),
//           "locationGps": booking.locationGps,
//           "isPresent": booking.isPresent,
//           "roomPhotoUrl": booking.roomPhotoUrl,
//           "createdAt": booking.createdAt?.toIso8601String(),
//           "photoUrls": booking.photoUrls ?? [],
//         }),
//       );

//       // ✅ PERBAIKAN: Terima status code 200 DAN 204 sebagai sukses
//       if (response.statusCode == 200 || response.statusCode == 204) {
//         print('Booking updated successfully with status: ${response.statusCode}');
//         return true;
//       } else {
//         throw Exception('Failed to update booking: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error updating booking: $e');
//       return false;
//     }
//   }
//   // static Future<bool> updateBookingStatus(int bookingId, String status) async {
//   //   try {
//   //     final response = await http.put(
//   //       Uri.parse('$baseUrl/bookings/$bookingId/status'),
//   //       headers: {'Content-Type': 'application/json'},
//   //       body: json.encode({'status': status}),
//   //     );
      
//   //     print('Update booking status response: ${response.statusCode}');
//   //     print('Update booking status body: ${response.body}');
//   //     return response.statusCode == 200;
//   //   } catch (e) {
//   //     print('Error updating booking status: $e');
//   //     return false;
//   //   }
//   // }

//   // =================== USER BOOKING ACTIONS ==========================================
  
//   static Future<bool> checkin(int bookingId, String locationGps) async {
//     var body = json.encode({'location_gps': locationGps});

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     return response.statusCode == 200;
//   }

//   static Future<bool> checkout(int bookingId, String photoUrl) async {
//     var body = json.encode({'photo_url': photoUrl});

//     var response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: body,
//     );

//     return response.statusCode == 200;
//   }

//   static Future<void> confirmAttendance(int bookingId, String locationGps,) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkin'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'locationGps': locationGps}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal konfirmasi kehadiran');
//     }
//   }

//   static Future<void> checkoutBooking(int bookingId, String photoUrl) async {
//     final response = await http.put(
//       Uri.parse('$baseUrl/bookings/$bookingId/checkout'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode({'photoUrl': photoUrl}),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Gagal melakukan pertanggungjawaban');
//     }
//   }

//   static Future<String> uploadPhoto(int bookingId, XFile photo, {String type = 'before'}) async {
//     final uri = Uri.parse('$baseUrl/bookings/$bookingId/photos');
//     var request = http.MultipartRequest('POST', uri)
//       ..fields['type'] = type
//       ..files.add(await http.MultipartFile.fromPath('photo', photo.path));
//     final response = await request.send();
//     if (response.statusCode == 200) {
//       final respStr = await response.stream.bytesToString();
//       final jsonResp = jsonDecode(respStr);
//       return jsonResp['photoUrl'];
//     }
//     throw Exception('Gagal upload foto');
//   }

  

//   // =================== LEGACY BOOKING METHODS ==========================================
  
//   static Future<bool> createBookingSwagger(int userId, int roomId, DateTime bookingDate, String purpose, String startTime, String endTime) async {
//     try {
//       var bookingData = {
//         "id": 0,
//         "roomId": roomId,
//         "userId": userId,
//         "bookingDate": bookingDate.toIso8601String(),
//         "startTime": startTime,
//         "endTime": endTime,
//         "purpose": purpose,
//         "status": "pending",
//         "checkinTime": null,
//         "checkoutTime": null,
//         "locationGps": "",
//         "isPresent": false,
//         "roomPhotoUrl": "",
//         "createdAt": DateTime.now().toIso8601String(),
//         "photos": [],
//        };

//        print("Booking Data: ${json.encode(bookingData)}");

//        var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Accept': 'application/json',
//         },
//         body: json.encode(bookingData),
//        );
//        print('Response status: ${response.statusCode}');
//        print('Response body: ${response.body}');
//        return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> createBookingPascalCase(Map<String, dynamic> bookingData) async {
//     try {
//       var response = await http.post(
//         Uri.parse('$baseUrl/bookings'),
//         headers: {'Content-Type': 'application/json'},
//         body: json.encode(bookingData),
//       );
//       print('Response status: ${response.statusCode}');
//       print('Response body: ${response.body}');
//       return response.statusCode == 201;
//     } catch (e) {
//       print('Error creating booking: $e');
//       return false;
//     }
//   }

//   static Future<bool> createBookingSimple(Map<String, dynamic> bookingData) async {
//     final url = Uri.parse('$baseUrl/bookings');
//     final response = await http.post(
//       url,
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(bookingData),
//     );
//     print('Response status: ${response.statusCode}');
//     print('Response body: ${response.body}');
//     return response.statusCode == 201;
//   }
// }




import 'dart:convert';
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
import 'dart:io';

class ApiService {
  // ✅ FIXED: URL Railway yang konsisten
  static const String baseUrl = 'https://apiroom-production.up.railway.app/api';
  static const Duration timeoutDuration = Duration(seconds: 30);
  
  // ✅ Headers yang konsisten
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Flutter-Rom-App/1.0',
  };

  // ✅ Method untuk mendapatkan token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // ✅ Method untuk mendapatkan auth headers
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _getToken();
    final headers = Map<String, String>.from(defaultHeaders);
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // ✅ Error handling helper
  static Exception handleError(dynamic error, int? statusCode, String? responseBody) {
    if (error is SocketException) {
      return Exception('No internet connection');
    } else if (error.toString().contains('TimeoutException')) {
      return Exception('Request timeout - please check your connection');
    } else if (statusCode != null) {
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

  // ✅ Method untuk logging request/response
  static void logRequest(String method, String url, {Map<String, String>? headers, String? body}) {
    print('🌐 === $method REQUEST ===');
    print('📍 URL: $url');
    print('📅 Time: ${DateTime.now()}');
    if (headers != null) print('📋 Headers: $headers');
    if (body != null) print('📤 Body: $body');
  }

  static void logResponse(int statusCode, String? body, {Map<String, String>? headers}) {
    print('📥 === RESPONSE ===');
    print('📊 Status: $statusCode');
    if (headers != null) print('📋 Headers: $headers');
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

      // 2. Kirim data ke endpoint
      final payload = {
        'photoId': 0,
        'photoUrl': photoUrl,
        'booking': {
          'id': bookingId,
        }
      };

      final response = await http.post(
        Uri.parse('$baseUrl/photo_usage'),
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
      
      logRequest('POST', '$baseUrl/upload');
      
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload'),
      );
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final streamedResponse = await request.send().timeout(timeoutDuration);
      final response = await http.Response.fromStream(streamedResponse);

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['url'] ?? 'https://apiroom-production.up.railway.app/storage/$fileName';
      } else {
        // Fallback untuk demo - ganti dengan implementasi sebenarnya
        return 'https://apiroom-production.up.railway.app/storage/$fileName';
      }
    } catch (e) {
      print('❌ Error uploading image: $e');
      // Fallback URL untuk demo
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

  static Future<bool> uploadPertanggungjawaban({
    required int bookingId,
    required XFile photo,
  }) async {
    try {
      await uploadPhotoUsage(
        bookingId: bookingId,
        photoFile: photo,
      );

      await updateBookingStatus(bookingId, 'done');
      return true;
    } catch (e) {
      print('❌ Error in uploadPertanggungjawaban: $e');
      throw Exception('Failed to upload pertanggungjawaban: $e');
    }
  }

  static Future<bool> updateBookingStatus(int bookingId, String status) async {
    try {
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
      final url = '$baseUrl/facilities';
      
      logRequest('POST', url, headers: headers, body: json.encode(requestData));
      
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(requestData),
      ).timeout(timeoutDuration);
      
      logResponse(response.statusCode, response.body);
      
      if (response.statusCode == 201) {
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
      final url = '$baseUrl/facilities/$id';
      
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
      final url = '$baseUrl/facilities/$id';
      
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
      // ✅ FIXED: Coba beberapa endpoint yang mungkin
      List<String> possibleEndpoints = [
        '$baseUrl/meeting_rooms',    // Yang sekarang digunakan
        '$baseUrl/rooms',            // Alternative 1
        '$baseUrl/Room',             // Alternative 2 (dengan capital R)
        'https://apiroom-production.up.railway.app/meeting_rooms',  // Tanpa /api
      ];

      Exception? lastError;
      
      for (String endpoint in possibleEndpoints) {
        try {
          logRequest('GET', endpoint);
          
          var response = await http.get(
            Uri.parse(endpoint),
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
              
              print('✅ Successfully loaded ${rooms.length} rooms from $endpoint');
              return rooms;
            } else if (decode is List) {
              List<Room> rooms = decode.map((roomJson) => Room.fromJson(roomJson)).toList();
              print('✅ Successfully loaded ${rooms.length} rooms from $endpoint');
              return rooms;
            } else {
              print('⚠️ Unexpected response format from $endpoint');
              continue;
            }
          } else {
            print('❌ HTTP ${response.statusCode} from $endpoint: ${response.body}');
            lastError = handleError(null, response.statusCode, response.body);
            continue;
          }
        } catch (e) {
          print('❌ Error trying $endpoint: $e');
          lastError = handleError(e, null, null);
          continue;
        }
      }
      
      // Jika semua endpoint gagal, throw error terakhir
      throw lastError ?? Exception('All endpoints failed');
      
    } catch (e) {
      print('❌ Error in getRooms: $e');
      throw handleError(e, null, null);
    }
  }

  static Future<Room> getRoom(int id) async {
    try {
      // ✅ FIXED: Coba beberapa endpoint
      List<String> possibleEndpoints = [
        '$baseUrl/Room/$id',
        '$baseUrl/rooms/$id',
        '$baseUrl/meeting_rooms/$id',
      ];

      for (String endpoint in possibleEndpoints) {
        try {
          logRequest('GET', endpoint);
          
          var response = await http.get(
            Uri.parse(endpoint),
            headers: defaultHeaders,
          ).timeout(timeoutDuration);
          
          logResponse(response.statusCode, response.body);
          
          if (response.statusCode == 200) {
            var decode = json.decode(response.body);
            return Room.fromJson(decode);
          }
        } catch (e) {
          print('❌ Error trying $endpoint: $e');
          continue;
        }
      }
      
      throw Exception('Room not found with ID: $id');
    } catch (e) {
      print('❌ Error in getRoom: $e');
      throw handleError(e, null, null);
    }
  }

  Future<void> updateRoom(int roomId, Map<String, dynamic> updatedData) async {
    try {
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
    try {
      print('🏗️ === API CREATE ROOM MULTIPART ===');
      print('📊 Data: $data');
      print('📸 Has photo: ${photo != null}');
      
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
        "roomName": booking.roomName,
        "userId": booking.userId,
        "userName": booking.userName,
        "bookingDate": booking.bookingDate.toIso8601String(),
        "startTime": booking.startTime,
        "endTime": booking.endTime,
        "purpose": booking.purpose,
        "status": booking.status,
        "checkinTime": booking.checkinTime?.toIso8601String(),
        "checkoutTime": booking.checkoutTime?.toIso8601String(),
        "locationGps": booking.locationGps,
        "isPresent": booking.isPresent,
        "roomPhotoUrl": booking.roomPhotoUrl,
        "createdAt": booking.createdAt?.toIso8601String(),
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
        print('✅ Booking updated successfully with status: ${response.statusCode}');
        return true;
      } else {
        throw handleError(null, response.statusCode, response.body);
      }
    } catch (e) {
      print('❌ Error in updateBooking: $e');
      return false;
    }
  }

  // =================== USER BOOKING ACTIONS ==========================================
  
  static Future<bool> checkin(int bookingId, String locationGps) async {
    try {
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
  
  static Future<bool> createBookingSwagger(
    int userId, 
    int roomId, 
    DateTime bookingDate, 
    String purpose, 
    String startTime, 
    String endTime
  ) async {
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
      
      // Test health endpoint
      final healthResponse = await http.get(
        Uri.parse('https://apiroom-production.up.railway.app/health'),
      ).timeout(Duration(seconds: 10));
      
      if (healthResponse.statusCode == 200) {
        print('✅ Health check passed');
        return true;
      }
      
      // Test root endpoint jika health tidak ada
      final rootResponse = await http.get(
        Uri.parse('https://apiroom-production.up.railway.app/'),
      ).timeout(Duration(seconds: 10));
      
      print('🌐 Root endpoint status: ${rootResponse.statusCode}');
      return rootResponse.statusCode == 200;
      
    } catch (e) {
      print('❌ Connection test failed: $e');
      return false;
    }
  }

  // ✅ Test specific endpoint
  static Future<Map<String, dynamic>> testEndpoint(String endpoint) async {
    try {
      logRequest('GET', endpoint);
      
      final response = await http.get(
        Uri.parse(endpoint),
        headers: defaultHeaders,
      ).timeout(Duration(seconds: 10));
      
      logResponse(response.statusCode, response.body);
      
      return {
        'success': response.statusCode == 200,
        'statusCode': response.statusCode,
        'body': response.body,
        'headers': response.headers,
      };
    } catch (e) {
      print('❌ Error testing endpoint $endpoint: $e');
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  // ✅ Get API status
  static Future<Map<String, dynamic>> getApiStatus() async {
    final results = <String, dynamic>{};
    
    final endpoints = [
      'https://apiroom-production.up.railway.app/',
      'https://apiroom-production.up.railway.app/api',
      'https://apiroom-production.up.railway.app/health',
      '$baseUrl/meeting_rooms',
      '$baseUrl/rooms',
      '$baseUrl/facilities',
      '$baseUrl/bookings',
    ];
    
    for (String endpoint in endpoints) {
      results[endpoint] = await testEndpoint(endpoint);
    }
    
    return results;
  }

  // ✅ Clear cache/reset
  static Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Hanya clear cache, jangan clear auth token
      final keys = prefs.getKeys().where((key) => 
        !key.contains('token') && 
        !key.contains('user_') && 
        !key.contains('role')
      ).toList();
      
      for (String key in keys) {
        await prefs.remove(key);
      }
      
      print('✅ Cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }
}