class Facility {
  final int id;
  final String name;
  final DateTime createdAt;

  Facility({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    print('Parsing facility: ${json['name']} (ID: ${json['id']})');
    
    return Facility(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Facility{id: $id, name: $name}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Facility &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}