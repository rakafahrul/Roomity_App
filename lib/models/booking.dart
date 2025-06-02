class Booking {
  final int id;
  final int userId;
  final int roomId;
  final String roomName;
  final String location;
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
  final List<dynamic> photos;

  Booking({
    required this.id,
    required this.userId,
    required this.roomId,
    required this.roomName,
    required this.location,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.purpose,
    required this.status,
    required this.checkinTime,
    required this.checkoutTime,
    required this.locationGps,
    required this.isPresent,
    this.roomPhotoUrl,
    this.photos = const [],
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle photos with $values
    List<dynamic> photosList = [];
    var photosJson = json['photos'];
    if (photosJson != null) {
      if (photosJson is Map && photosJson.containsKey('\$values')) {
        photosList = photosJson['\$values'] ?? [];
      } else if (photosJson is List) {
        photosList = photosJson;
      }
    }

    return Booking(
      id: json['id'],
      userId: json['user']?['id'] ?? json['userId'] ?? 0,
      roomId: json['room']?['id'] ?? json['roomId'] ?? 0,
      roomName: json['roomName'] ?? json['room']?['name'] ?? 'Co-Working Space', // fallback
      location: json['location'] ?? json['room']?['location'] ?? 'Gedung 24A, Ilmu Komputer',
      bookingDate: DateTime.parse(json['bookingDate']),
      startTime: json['startTime'],
      endTime: json['endTime'],
      purpose: json['purpose'],
      status: json['status'],
      checkinTime: json['checkinTime'] != null && json['checkinTime'] != ""
          ? DateTime.tryParse(json['checkinTime'] ?? "")
          : null,
      checkoutTime: json['checkoutTime'] != null && json['checkoutTime'] != ""
          ? DateTime.tryParse(json['checkoutTime'] ?? "")
          : null,
      locationGps: json['locationGps'] ?? '',
      isPresent: json['isPresent'] ?? false,
      roomPhotoUrl: json['roomPhotoUrl'] ?? json['room']?['photoUrl'],
      photos: photosList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'roomId': roomId,
      'roomName': roomName,
      'location': location,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'purpose': purpose,
      'status': status,
      'checkinTime': checkinTime?.toIso8601String(),
      'checkoutTime': checkoutTime?.toIso8601String(),
      'locationGps': locationGps,
      'isPresent': isPresent,
      'roomPhotoUrl': roomPhotoUrl ?? '',
      'photos': photos,
    };
  }
}