class PhotoUsage {
  final int photoId;
  final int bookingId;
  final String photoUrl;

  PhotoUsage({
    required this.photoId,
    required this.bookingId,
    required this.photoUrl,
  });

  factory PhotoUsage.fromJson(Map<String, dynamic> json) {
    return PhotoUsage(
      photoId: json['photo_id'],
      bookingId: json['booking_id'],
      photoUrl: json['photo_url'],
    );
  }
}