class RoomFacility {
  final int roomId;
  final int facilityId;

  RoomFacility({
    required this.roomId,
    required this.facilityId,
  });

  factory RoomFacility.fromJson(Map<String, dynamic> json) {
    return RoomFacility(
      roomId: json['room_id'],
      facilityId: json['facility_id'],
    );
  }
}