import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/services/ride_service.dart';
import 'package:quickride/core/services/location_service.dart';
import 'package:quickride/core/models/user_model.dart';

// Service providers
final rideServiceProvider = Provider<RideService>((ref) {
  return RideService();
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

// Current location provider
final currentLocationProvider = FutureProvider<LatLng?>((ref) async {
  final locationService = ref.read(locationServiceProvider);
  return await locationService.getCurrentLocation();
});

// Active ride provider for rider
final riderActiveRideProvider = StreamProvider.family<Ride?, String>((
  ref,
  riderId,
) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamRiderActiveRide(riderId);
});

// Active ride provider for driver
final driverActiveRideProvider = StreamProvider.family<Ride?, String>((
  ref,
  driverId,
) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamDriverActiveRide(driverId);
});

// Nearby ride requests for driver
final nearbyRideRequestsProvider = StreamProvider.family<List<Ride>, LatLng>((
  ref,
  location,
) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamNearbyRideRequests(location, 5.0); // 5km radius
});

// Single ride stream provider
final rideStreamProvider = StreamProvider.family<Ride?, String>((ref, rideId) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamRide(rideId);
});

// Available drivers provider
final availableDriversProvider = StreamProvider<List<AppUser>>((ref) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamAvailableDrivers();
});

// Ride history provider
final rideHistoryProvider = StreamProvider.family<List<Ride>, ({String userId, bool isDriver})>((ref, params) {
  final rideService = ref.read(rideServiceProvider);
  return rideService.streamRideHistory(params.userId, params.isDriver);
});
