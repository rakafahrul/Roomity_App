// File: lib/models/room.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:rom_app/utils/image_helper.dart';

class Room {
  final int id;
  final String name;
  final String location;
  final String description;
  final int capacity;
  final String status;
  final String photoUrl;
  final DateTime createdAt;
  final List<String> facilities;
  final double? latitude;
  final double? longitude;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.description,
    required this.capacity,
    required this.status,
    required this.photoUrl,
    required this.createdAt,
    required this.facilities,
    this.latitude,
    this.longitude,
  });

  // Get full image URL using ImageHelper
  String get fullImageUrl => ImageHelper.getFullImageUrl(photoUrl);
  
  // Check if has custom image (not default Pinterest URL)
  bool get hasCustomImage => 
    photoUrl.isNotEmpty && 
    !photoUrl.contains('pin.it') && 
    !photoUrl.contains('pinterest.com') &&
    photoUrl != 'https://pin.it/7jmxYwP83';

  // Get status color
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'available':
        return const Color(0xFF4CAF50); // Green
      case 'maintenance':
        return const Color(0xFFFF9800); // Orange
      case 'unavailable':
        return const Color(0xFFF44336); // Red
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  // Get status text in Indonesian
  String get statusText {
    switch (status.toLowerCase()) {
      case 'available':
        return 'Tersedia';
      case 'maintenance':
        return 'Maintenance';
      case 'unavailable':
        return 'Tidak Tersedia';
      default:
        return 'Unknown';
    }
  }

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['id'] ?? 0,
      name: json['name'] ?? '-',
      location: json['location'] ?? '-',
      description: json['description'] ?? '-',
      capacity: json['capacity'] ?? 0,
      status: json['status'] ?? 'available',
      photoUrl: json['photoUrl'] ?? 'https://pin.it/7jmxYwP83',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      facilities: _parseFacilities(json['facilities']),
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
    );
  }

  // Helper untuk parsing facilities - keep your existing logic
  static List<String> _parseFacilities(dynamic facilitiesData) {
    if (facilitiesData == null) return [];

    // Handle format {"$values": [...]}
    if (facilitiesData is Map && facilitiesData.containsKey('\$values')) {
      return List<String>.from(facilitiesData['\$values'] ?? []);
    }
    // Handle format langsung [...]
    else if (facilitiesData is List) {
      return List<String>.from(facilitiesData);
    }
    // Handle JSON string
    else if (facilitiesData is String) {
      try {
        final decoded = json.decode(facilitiesData);
        if (decoded is List) {
          return List<String>.from(decoded);
        }
      } catch (e) {
        // Jika string tidak bisa di-decode sebagai JSON,
        // diasumsikan string itu sendiri adalah nama fasilitas tunggal.
        // Anda perlu memastikan apakah ini perilaku yang diinginkan.
        // Jika tidak, bisa dikembalikan [] atau log error.
        return [facilitiesData];
      }
    }

    return []; // Default jika format tidak dikenali
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'description': description,
      'capacity': capacity,
      'status': status,
      'photoUrl': photoUrl,
      'createdAt': createdAt.toIso8601String(),
      'facilities': {
        '\$values': facilities, // Keep your existing format
      },
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // For API requests (multipart form data)
  Map<String, String> toFormData() {
    return {
      'Name': name,
      'Location': location,
      'Description': description,
      'Capacity': capacity.toString(),
      'Status': status,
      'Latitude': latitude?.toString() ?? '0',
      'Longitude': longitude?.toString() ?? '0',
      'Facilities': json.encode(facilities),
    };
  }

  Room copyWith({
    int? id,
    String? name,
    String? location,
    String? description,
    int? capacity,
    String? status,
    String? photoUrl,
    DateTime? createdAt,
    List<String>? facilities,
    double? latitude,
    double? longitude,
  }) {
    return Room(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      description: description ?? this.description,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      facilities: facilities ?? this.facilities,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  @override
  String toString() {
    return 'Room{id: $id, name: $name, location: $location, photoUrl: $photoUrl}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Room &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

