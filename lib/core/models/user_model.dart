import 'package:quickride/core/models/ride_model.dart';

enum UserRole {
  rider,
  driver,
}

class AppUser {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? profileImage;
  final double? rating;
  final int? totalRides;
  final bool isOnline; // For drivers
  final LocationData? lastLocation; // For drivers
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.rating,
    this.totalRides,
    this.isOnline = false,
    this.lastLocation,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
      ),
      profileImage: json['profileImage'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      totalRides: json['totalRides'] as int?,
      isOnline: json['isOnline'] as bool? ?? false,
      lastLocation: json['lastLocation'] != null
          ? LocationData.fromJson(json['lastLocation'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'profileImage': profileImage,
      'rating': rating,
      'totalRides': totalRides,
      'isOnline': isOnline,
      'lastLocation': lastLocation?.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? profileImage,
    double? rating,
    int? totalRides,
    bool? isOnline,
    LocationData? lastLocation,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      profileImage: profileImage ?? this.profileImage,
      rating: rating ?? this.rating,
      totalRides: totalRides ?? this.totalRides,
      isOnline: isOnline ?? this.isOnline,
      lastLocation: lastLocation ?? this.lastLocation,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
