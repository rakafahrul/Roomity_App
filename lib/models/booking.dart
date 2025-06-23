
















  




















































































class Booking {
  final int id;
  final int roomId;
  final String roomName;
  final int userId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final String purpose;
  final String status;
  final DateTime? checkinTime;
  final DateTime? checkoutTime;
  final String? locationGps;
  final bool isPresent;
  final String? roomPhotoUrl;
  final DateTime createdAt;
  final List<String> photoUrls;
  
  
  final String? userName;
  final String? userDisplayName;
  final String? adminNotes;
  final String? notes;
  final String? afterPhotoUrl;
  final String? roomPhotoAfterUrl;
  final DateTime? updatedAt;
  final DateTime? modifiedAt;

  Booking({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.userId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    this.checkinTime,
    this.checkoutTime,
    this.locationGps,
    required this.isPresent,
    this.roomPhotoUrl,
    required this.createdAt,
    required this.photoUrls,
    this.userName,
    this.userDisplayName,
    this.adminNotes,
    this.notes,
    this.afterPhotoUrl,
    this.roomPhotoAfterUrl,
    this.updatedAt,
    this.modifiedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    
    List<String> photoUrls = [];
    if (json['photos'] != null) {
      if (json['photos'] is List) {
        photoUrls = List<String>.from(json['photos']);
      } else if (json['photos'] is Map && json['photos']['\$values'] != null) {
        photoUrls = List<String>.from(json['photos']['\$values']);
      }
    } else if (json['photoUrls'] != null) {
      if (json['photoUrls'] is List) {
        photoUrls = List<String>.from(json['photoUrls']);
      }
    }

    
    DateTime parseDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is String) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    DateTime? parseOptionalDateTime(dynamic value) {
      if (value == null) return null;
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          return null;
        }
      }
      return null;
    }

    return Booking(
      id: json['id'] ?? 0,
      roomId: json['roomId'] ?? json['room_id'] ?? 0,
      roomName: json['roomName'] ?? json['room_name'] ?? 'Unknown Room',
      userId: json['userId'] ?? json['user_id'] ?? 0,
      bookingDate: parseDateTime(json['bookingDate'] ?? json['booking_date']),
      startTime: json['startTime'] ?? json['start_time'] ?? '',
      endTime: json['endTime'] ?? json['end_time'] ?? '',
      purpose: json['purpose'] ?? '',
      status: json['status'] ?? 'pending',
      checkinTime: parseOptionalDateTime(json['checkinTime'] ?? json['checkin_time']),
      checkoutTime: parseOptionalDateTime(json['checkoutTime'] ?? json['checkout_time']),
      locationGps: json['locationGps'] ?? json['location_gps'],
      isPresent: json['isPresent'] ?? json['is_present'] ?? false,
      roomPhotoUrl: json['roomPhotoUrl'] ?? json['room_photo_url'],
      createdAt: parseDateTime(json['createdAt'] ?? json['created_at']),
      photoUrls: photoUrls,
      userName: json['userName'] ?? json['user_name'] ?? json['userDisplayName'],
      userDisplayName: json['userDisplayName'] ?? json['user_display_name'],
      adminNotes: json['adminNotes'] ?? json['admin_notes'] ?? json['notes'],
      notes: json['notes'],
      afterPhotoUrl: json['afterPhotoUrl'] ?? json['after_photo_url'] ?? json['roomPhotoAfterUrl'],
      roomPhotoAfterUrl: json['roomPhotoAfterUrl'] ?? json['room_photo_after_url'],
      updatedAt: parseOptionalDateTime(json['updatedAt'] ?? json['updated_at']),
      modifiedAt: parseOptionalDateTime(json['modifiedAt'] ?? json['modified_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'roomId': roomId,
      'roomName': roomName,
      'userId': userId,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'purpose': purpose,
      'status': status,
      'checkinTime': checkinTime?.toIso8601String(),
      'checkoutTime': checkoutTime?.toIso8601String(),
      'locationGps': locationGps,
      'isPresent': isPresent,
      'roomPhotoUrl': roomPhotoUrl,
      'createdAt': createdAt.toIso8601String(),
      'photos': photoUrls,
      'photoUrls': photoUrls,
      'userName': userName,
      'userDisplayName': userDisplayName,
      'adminNotes': adminNotes,
      'notes': notes,
      'afterPhotoUrl': afterPhotoUrl,
      'roomPhotoAfterUrl': roomPhotoAfterUrl,
      'updatedAt': updatedAt?.toIso8601String(),
      'modifiedAt': modifiedAt?.toIso8601String(),
    };
  }

  Booking copyWith({
    int? id,
    int? roomId,
    String? roomName,
    int? userId,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    String? purpose,
    String? status,
    DateTime? checkinTime,
    DateTime? checkoutTime,
    String? locationGps,
    bool? isPresent,
    String? roomPhotoUrl,
    DateTime? createdAt,
    List<String>? photoUrls,
    String? userName,
    String? userDisplayName,
    String? adminNotes,
    String? notes,
    String? afterPhotoUrl,
    String? roomPhotoAfterUrl,
    DateTime? updatedAt,
    DateTime? modifiedAt,
  }) {
    return Booking(
      id: id ?? this.id,
      roomId: roomId ?? this.roomId,
      roomName: roomName ?? this.roomName,
      userId: userId ?? this.userId,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      checkinTime: checkinTime ?? this.checkinTime,
      checkoutTime: checkoutTime ?? this.checkoutTime,
      locationGps: locationGps ?? this.locationGps,
      isPresent: isPresent ?? this.isPresent,
      roomPhotoUrl: roomPhotoUrl ?? this.roomPhotoUrl,
      createdAt: createdAt ?? this.createdAt,
      photoUrls: photoUrls ?? this.photoUrls,
      userName: userName ?? this.userName,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      adminNotes: adminNotes ?? this.adminNotes,
      notes: notes ?? this.notes,
      afterPhotoUrl: afterPhotoUrl ?? this.afterPhotoUrl,
      roomPhotoAfterUrl: roomPhotoAfterUrl ?? this.roomPhotoAfterUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      modifiedAt: modifiedAt ?? this.modifiedAt,
    );
  }
}