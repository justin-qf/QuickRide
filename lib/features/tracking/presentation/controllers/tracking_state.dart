import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingState {
  final LatLng? driverLocation;
  final LatLng? customerLocation;
  final List<LatLng> polylineCoordinates;
  final String eta;
  final bool isLoading;
  final double driverHeading;

  TrackingState({
    this.driverLocation,
    this.customerLocation,
    this.polylineCoordinates = const [],
    this.eta = '-',
    this.isLoading = false,
    this.driverHeading = 0.0,
  });

  TrackingState copyWith({
    LatLng? driverLocation,
    LatLng? customerLocation,
    List<LatLng>? polylineCoordinates,
    String? eta,
    bool? isLoading,
    double? driverHeading,
  }) {
    return TrackingState(
      driverLocation: driverLocation ?? this.driverLocation,
      customerLocation: customerLocation ?? this.customerLocation,
      polylineCoordinates: polylineCoordinates ?? this.polylineCoordinates,
      eta: eta ?? this.eta,
      isLoading: isLoading ?? this.isLoading,
      driverHeading: driverHeading ?? this.driverHeading,
    );
  }
}
