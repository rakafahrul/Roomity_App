class User {
  final int id;
  final String name;
  final String email;
  final String? password;
  final String photo;
  final String role;
  final DateTime createdAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.password,
    required this.photo,
    required this.role,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      password: json['password'],
      photo: json['photo'] ?? '',
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'photo': photo,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}