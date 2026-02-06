import 'package:google_maps_flutter/google_maps_flutter.dart';

enum RideStatus {
  requested,
  accepted,
  driverArriving,
  rideStarted,
  rideCompleted,
  cancelled,
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;
  final double? bearing;
  final double? speed;

  LocationData({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.bearing,
    this.speed,
  });

  LatLng toLatLng() => LatLng(latitude, longitude);

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      bearing: json['bearing'] != null ? (json['bearing'] as num).toDouble() : null,
      speed: json['speed'] != null ? (json['speed'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'bearing': bearing,
      'speed': speed,
    };
  }
}

class Ride {
  final String id;
  final String riderId;
  final String riderName;
  final String riderPhone;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final LocationData pickupLocation;
  final LocationData dropLocation;
  final RideStatus status;
  final DateTime requestedAt;
  final DateTime? acceptedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final double? fare;
  final double? distance; // in km
  final String? eta;
  final double? rating;
  final String? feedback;
  final LocationData? driverCurrentLocation;

  Ride({
    required this.id,
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.pickupLocation,
    required this.dropLocation,
    required this.status,
    required this.requestedAt,
    this.acceptedAt,
    this.startedAt,
    this.completedAt,
    this.fare,
    this.distance,
    this.eta,
    this.rating,
    this.feedback,
    this.driverCurrentLocation,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] as String,
      riderId: json['riderId'] as String,
      riderName: json['riderName'] as String,
      riderPhone: json['riderPhone'] as String,
      driverId: json['driverId'] as String?,
      driverName: json['driverName'] as String?,
      driverPhone: json['driverPhone'] as String?,
      pickupLocation: LocationData.fromJson(json['pickupLocation'] as Map<String, dynamic>),
      dropLocation: LocationData.fromJson(json['dropLocation'] as Map<String, dynamic>),
      status: RideStatus.values.firstWhere(
        (e) => e.toString() == 'RideStatus.${json['status']}',
      ),
      requestedAt: DateTime.parse(json['requestedAt'] as String),
      acceptedAt: json['acceptedAt'] != null ? DateTime.parse(json['acceptedAt'] as String) : null,
      startedAt: json['startedAt'] != null ? DateTime.parse(json['startedAt'] as String) : null,
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      fare: json['fare'] != null ? (json['fare'] as num).toDouble() : null,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
      eta: json['eta'] as String?,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      feedback: json['feedback'] as String?,
      driverCurrentLocation: json['driverCurrentLocation'] != null
          ? LocationData.fromJson(json['driverCurrentLocation'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickupLocation': pickupLocation.toJson(),
      'dropLocation': dropLocation.toJson(),
      'status': status.toString().split('.').last,
      'requestedAt': requestedAt.toIso8601String(),
      'acceptedAt': acceptedAt?.toIso8601String(),
      'startedAt': startedAt?.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'fare': fare,
      'distance': distance,
      'eta': eta,
      'rating': rating,
      'feedback': feedback,
      'driverCurrentLocation': driverCurrentLocation?.toJson(),
    };
  }

  Ride copyWith({
    String? id,
    String? riderId,
    String? riderName,
    String? riderPhone,
    String? driverId,
    String? driverName,
    String? driverPhone,
    LocationData? pickupLocation,
    LocationData? dropLocation,
    RideStatus? status,
    DateTime? requestedAt,
    DateTime? acceptedAt,
    DateTime? startedAt,
    DateTime? completedAt,
    double? fare,
    double? distance,
    String? eta,
    double? rating,
    String? feedback,
    LocationData? driverCurrentLocation,
  }) {
    return Ride(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropLocation: dropLocation ?? this.dropLocation,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      fare: fare ?? this.fare,
      distance: distance ?? this.distance,
      eta: eta ?? this.eta,
      rating: rating ?? this.rating,
      feedback: feedback ?? this.feedback,
      driverCurrentLocation: driverCurrentLocation ?? this.driverCurrentLocation,
    );
  }
}
