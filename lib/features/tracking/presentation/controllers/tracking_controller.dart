import 'dart:async';
import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:quickride/features/tracking/domain/repositories/tracking_repository.dart';
import 'package:quickride/features/tracking/presentation/controllers/tracking_state.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  return TrackingRepositoryImpl();
});

final trackingControllerProvider =
    StateNotifierProvider<TrackingController, TrackingState>((ref) {
      return TrackingController(ref.read(trackingRepositoryProvider));
    });

class TrackingController extends StateNotifier<TrackingState> {
  final TrackingRepository _repository;
  Timer? _simulationTimer;
  int _currentPolylineIndex = 0;

  // Placeholder coordinates (San Francisco) if location fetch fails
  static const LatLng _defaultLocation = LatLng(37.7749, -122.4194);

  TrackingController(this._repository) : super(TrackingState());

  Future<void> initialize() async {
    state = state.copyWith(isLoading: true);

    // 1. Get User Location (Destination)
    LatLng customerPos = await _getUserLocation();

    // 2. Set Driver Location (Source) - Simulating a restaurant nearby
    // For demo, we put the driver at a fixed offset or a random nearby point
    LatLng driverPos = LatLng(
      customerPos.latitude + 0.01,
      customerPos.longitude + 0.01,
    );

    state = state.copyWith(
      customerLocation: customerPos,
      driverLocation: driverPos,
      isLoading: false,
    );

    // 3. Get Route
    fetchRoute();
  }

  Future<LatLng> _getUserLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _defaultLocation;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _defaultLocation;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _defaultLocation;
    }

    final pos = await Geolocator.getCurrentPosition();
    return LatLng(pos.latitude, pos.longitude);
  }

  Future<void> fetchRoute() async {
    if (state.customerLocation == null || state.driverLocation == null) return;

    final route = await _repository.getRoute(
      state.driverLocation!,
      state.customerLocation!,
    );

    state = state.copyWith(
      polylineCoordinates: route,
      eta: '10 mins', // Placeholder, typically calculated from Distance/Speed
    );

    // Start Simulation after route is ready
    startSimulation();
  }

  void startSimulation() {
    _simulationTimer?.cancel();
    _currentPolylineIndex = 0;

    if (state.polylineCoordinates.isEmpty) return;

    // Ticking every 1000ms to move the driver
    _simulationTimer = Timer.periodic(const Duration(milliseconds: 1000), (
      timer,
    ) {
      if (_currentPolylineIndex >= state.polylineCoordinates.length - 1) {
        timer.cancel();
        state = state.copyWith(eta: 'Arrived');
        return;
      }

      final currentPos = state.polylineCoordinates[_currentPolylineIndex];
      final nextPos = state.polylineCoordinates[_currentPolylineIndex + 1];

      // Calculate heading
      final heading = _calculateHeading(currentPos, nextPos);

      state = state.copyWith(
        driverLocation: nextPos,
        driverHeading: heading,
        eta: _calculateDummyEta(
          _currentPolylineIndex,
          state.polylineCoordinates.length,
        ),
      );

      _currentPolylineIndex++;
    });
  }

  double _calculateHeading(LatLng start, LatLng end) {
    // Basic bearing calculation
    var lat1 = start.latitude * pi / 180;
    var lat2 = end.latitude * pi / 180;
    var dLon = (end.longitude - start.longitude) * pi / 180;

    var y = sin(dLon) * cos(lat2);
    var x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    var brng = atan2(y, x);
    return (brng * 180 / pi + 360) % 360;
  }

  String _calculateDummyEta(int currentIndex, int totalPoints) {
    int remaining = totalPoints - currentIndex;
    int seconds = remaining;

    if (seconds > 60) {
      return '${(seconds / 60).ceil()} mins';
    } else {
      return '$seconds sec';
    }
  }

  @override
  void dispose() {
    _simulationTimer?.cancel();
    super.dispose();
  }
}
