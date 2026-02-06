import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  StreamSubscription<Position>? _positionStreamSubscription;

  // Check and request location permissions
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  // Check if location service is enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Get current location
  Future<LatLng?> getCurrentLocation() async {
    try {
      final hasPermission = await requestLocationPermission();
      if (!hasPermission) {
        print('Location permission denied');
        return null;
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        print('Location service disabled');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Get current location error: $e');
      return null;
    }
  }

  // Get address from coordinates
  Future<String> getAddressFromCoordinates(LatLng location) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea} ${place.postalCode}';
      }
      return 'Unknown location';
    } catch (e) {
      print('Get address error: $e');
      return 'Unknown location';
    }
  }

  // Get coordinates from address
  Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      print('Get coordinates error: $e');
      return null;
    }
  }

  // Stream location updates
  Stream<Position> streamLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5, // Update every 5 meters for smoother tracking
      timeLimit: Duration(seconds: 3),
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  // Calculate distance between two points (in km)
  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
          start.latitude,
          start.longitude,
          end.latitude,
          end.longitude,
        ) /
        1000; // Convert to km
  }

  // Calculate bearing between two points
  double calculateBearing(LatLng start, LatLng end) {
    return Geolocator.bearingBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  // Stop location updates
  void stopLocationUpdates() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }
}
