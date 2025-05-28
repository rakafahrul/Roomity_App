class Room {
  final int id;
  final String name;
  final String location;
  final String description;
  final int capacity;
  final String status;
  final String photoUrl;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.capacity,
    required this.status,
    required this.photoUrl,
    required this.createdAt,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    print('Parsing Room: $json');
    return Room(
      id: json['id'] ?? 0,
      name: json['name'] ?? '-',
      location: json['location'] ?? '-',
      description: json['description'] ?? '-',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? 'available',
      photoUrl: json['photoUrl'] ?? 'https://pin.it/7jmxYwP83',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
