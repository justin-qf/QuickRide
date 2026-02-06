import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:uuid/uuid.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Create a new ride request
  Future<Ride> createRide({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required LocationData pickupLocation,
    required LocationData dropLocation,
  }) async {
    try {
      final rideId = _uuid.v4();
      final ride = Ride(
        id: rideId,
        riderId: riderId,
        riderName: riderName,
        riderPhone: riderPhone,
        pickupLocation: pickupLocation,
        dropLocation: dropLocation,
        status: RideStatus.requested,
        requestedAt: DateTime.now(),
      );

      await _firestore.collection('rides').doc(rideId).set(ride.toJson());
      return ride;
    } catch (e) {
      print('Create ride error: $e');
      rethrow;
    }
  }

  // Get ride by ID
  Future<Ride?> getRide(String rideId) async {
    try {
      final doc = await _firestore.collection('rides').doc(rideId).get();
      if (doc.exists) {
        return Ride.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      print('Get ride error: $e');
      return null;
    }
  }

  // Stream ride updates
  Stream<Ride?> streamRide(String rideId) {
    return _firestore.collection('rides').doc(rideId).snapshots().map((doc) {
      if (doc.exists) {
        return Ride.fromJson(doc.data()!);
      }
      return null;
    });
  }

  // Update ride status
  Future<void> updateRideStatus(String rideId, RideStatus status) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.toString().split('.').last,
      };

      // Add timestamp based on status
      switch (status) {
        case RideStatus.accepted:
          updateData['acceptedAt'] = DateTime.now().toIso8601String();
          break;
        case RideStatus.rideStarted:
          updateData['startedAt'] = DateTime.now().toIso8601String();
          break;
        case RideStatus.rideCompleted:
          updateData['completedAt'] = DateTime.now().toIso8601String();
          break;
        default:
          break;
      }

      await _firestore.collection('rides').doc(rideId).update(updateData);
    } catch (e) {
      print('Update ride status error: $e');
      rethrow;
    }
  }

  // Accept ride (driver)
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': RideStatus.accepted.toString().split('.').last,
        'acceptedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Accept ride error: $e');
      rethrow;
    }
  }

  // Update driver location
  Future<void> updateDriverLocation(
    String rideId,
    LocationData location,
  ) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'driverCurrentLocation': location.toJson(),
      });
    } catch (e) {
      print('Update driver location error: $e');
      rethrow;
    }
  }

  // Update ride fare and distance
  Future<void> updateRideFare(
    String rideId,
    double fare,
    double distance,
  ) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'fare': fare,
        'distance': distance,
      });
    } catch (e) {
      print('Update ride fare error: $e');
      rethrow;
    }
  }

  // Submit rating
  Future<void> submitRating(
    String rideId,
    double rating,
    String? feedback,
  ) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'rating': rating,
        'feedback': feedback,
      });
    } catch (e) {
      print('Submit rating error: $e');
      rethrow;
    }
  }

  // Get available drivers nearby
  Stream<List<AppUser>> streamAvailableDrivers() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: UserRole.driver.name)
        .where('isOnline', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromJson(doc.data())).toList();
    });
  }

  // Get nearby ride requests (for drivers)
  Stream<List<Ride>> streamNearbyRideRequests(
    LatLng driverLocation,
    double radiusKm,
  ) {
    // Simple implementation - in production, use GeoFlutterFire or similar
    return _firestore
        .collection('rides')
        .where(
          'status',
          isEqualTo: RideStatus.requested.toString().split('.').last,
        )
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
        });
  }

  // Get rider's active ride
  Stream<Ride?> streamRiderActiveRide(String riderId) {
    return _firestore
        .collection('rides')
        .where('riderId', isEqualTo: riderId)
        .where(
          'status',
          whereIn: [
            RideStatus.requested.toString().split('.').last,
            RideStatus.accepted.toString().split('.').last,
            RideStatus.driverArriving.toString().split('.').last,
            RideStatus.rideStarted.toString().split('.').last,
          ],
        )
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return Ride.fromJson(snapshot.docs.first.data());
          }
          return null;
        });
  }

  // Get driver's active ride
  Stream<Ride?> streamDriverActiveRide(String driverId) {
    return _firestore
        .collection('rides')
        .where('driverId', isEqualTo: driverId)
        .where(
          'status',
          whereIn: [
            RideStatus.accepted.toString().split('.').last,
            RideStatus.driverArriving.toString().split('.').last,
            RideStatus.rideStarted.toString().split('.').last,
          ],
        )
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return Ride.fromJson(snapshot.docs.first.data());
          }
          return null;
        });
  }

  // Cancel ride
  Future<void> cancelRide(String rideId) async {
    try {
      await _firestore.collection('rides').doc(rideId).update({
        'status': RideStatus.cancelled.toString().split('.').last,
      });
    } catch (e) {
      print('Cancel ride error: $e');
      rethrow;
    }
  }

  // Get ride history
  Future<List<Ride>> getRideHistory(String userId, bool isDriver) async {
    try {
      final field = isDriver ? 'driverId' : 'riderId';
      final snapshot = await _firestore
          .collection('rides')
          .where(field, isEqualTo: userId)
          .where(
            'status',
            isEqualTo: RideStatus.rideCompleted.toString().split('.').last,
          )
          .orderBy('completedAt', descending: true)
          .limit(20)
          .get();

      return snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
    } catch (e) {
      print('Get ride history error: $e');
      return [];
    }
  }

  // Get ride history as stream
  Stream<List<Ride>> streamRideHistory(String userId, bool isDriver) {
    final field = isDriver ? 'driverId' : 'riderId';
    return _firestore
        .collection('rides')
        .where(field, isEqualTo: userId)
        .where(
          'status',
          isEqualTo: RideStatus.rideCompleted.toString().split('.').last,
        )
        .snapshots()
        .map((snapshot) {
          final rides = snapshot.docs.map((doc) => Ride.fromJson(doc.data())).toList();
          // Sort in memory to avoid composite index requirement
          rides.sort((a, b) {
            if (a.completedAt == null) return 1;
            if (b.completedAt == null) return -1;
            return b.completedAt!.compareTo(a.completedAt!);
          });
          return rides;
        });
  }
}
