class Approval {
  final int id;
  final int bookingId;
  final int stage;
  final String status;
  final String note;
  final DateTime approvedAt;
  final String? approverName;

  Approval({
    required this.id,
    required this.bookingId,
    required this.stage,
    required this.status,
    required this.note,
    required this.approvedAt,
    this.approverName,
  });

  
  String get approver => approverName ?? 'Admin';
  DateTime get date => approvedAt;

  factory Approval.fromJson(Map<String, dynamic> json) {
    return Approval(
      id: json['id'] ?? 0,
      bookingId: json['bookingId'] ?? 0,
      stage: json['stage'] ?? 1,
      status: json['status'] ?? 'approved',
      note: json['note'] ?? '',
      approvedAt: json['approvedAt'] != null 
          ? DateTime.parse(json['approvedAt'])
          : DateTime.now(),
      approverName: json['approverName'] ?? json['approver'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bookingId': bookingId,
      'stage': stage,
      'status': status,
      'note': note,
      'approvedAt': approvedAt.toIso8601String(),
      'approverName': approverName,
    };
  }
}