import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/constants/app_constants.dart';
import 'package:quickride/features/tracking/domain/repositories/tracking_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final PolylinePoints _polylinePoints = PolylinePoints(
    apiKey: AppConstants.googleMapsApiKey,
  );

  @override
  Future<List<LatLng>> getRoute(LatLng origin, LatLng destination) async {
    try {
      PolylineResult result = await _polylinePoints.getRouteBetweenCoordinates(
        // googleApiKey: AppConstants.googleMapsApiKey,
        request: PolylineRequest(
          origin: PointLatLng(origin.latitude, origin.longitude),
          destination: PointLatLng(destination.latitude, destination.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        return result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();
      } else {
        // Fallback or Error handling
        // For demo purposes, we return a simple list containing start and end if API fails
        // This ensures the app doesn't crash without a valid key
        return [origin, destination];
      }
    } catch (e) {
      // In case of error (e.g. invalid key), return direct line
      return [origin, destination];
    }
  }
}
