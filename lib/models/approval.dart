class Approval {
  final int id;
  final int bookingId;
  final int stage;
  final String status;
  final String note;
  final int approvedBy;
  final DateTime approvedAt;

  Approval({
    required this.id,
    required this.bookingId,
    required this.stage,
    required this.status,
    required this.note,
    required this.approvedBy,
    required this.approvedAt,
  });

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'],
      bookingId: json['booking_id'],
      stage: json['stage'],
      status: json['status'],
      note: json['note'],
      approvedBy: json['approved_by'],
      approvedAt: DateTime.parse(json['approved_at']),
    );
  }
}