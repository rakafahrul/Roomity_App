class Facility {
  final int id;
  final String name;

  Facility({
    required this.id,
    required this.name,
  });

  factory Facility.fromJson(Map<String, dynamic> json) {
    return Facility(
      id: json['id'],
      name: json['name'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }

  // Untuk membuat salinan objek dengan nilai yang diubah
  Facility copyWith({
    int? id,
    String? name,
  }) {
    return Facility(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }
}