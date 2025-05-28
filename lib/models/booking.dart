// import 'dart:convert';

class Booking {
  final int id;
  final int userId;
  final int roomId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String purpose;
  final String status;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final String locationGps;
  final bool isPresent;
  final String? roomPhotoUrl;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    required this.checkinTime,
    required this.checkoutTime,
    required this.locationGps,
    required this.isPresent,
    this.roomPhotoUrl
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      userId: json['user_id'],
      roomId: json['room_id'],
      bookingDate: DateTime.parse(json['booking_date']),
      startTime: json['start_time'],
      endTime: json['end_time'],
      purpose: json['purpose'],
      status: json['status'],
      checkinTime: json['checkin_time'] != null ? DateTime.parse(json['checkin_time']) : null,
      checkoutTime: json['checkout_time'] != null ? DateTime.parse(json['checkout_time']) : null,
      locationGps: json['location_gps'],
      isPresent: json['is_present'] ?? false,
    );
  }
}