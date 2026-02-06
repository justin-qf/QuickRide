import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:quickride/core/constants/app_constants.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/core/utils/marker_utils.dart';
import 'package:quickride/features/rider/presentation/pages/ride_rating_screen.dart';
import 'package:quickride/features/tracking/presentation/pages/chat_screen.dart';

class RideTrackingScreen extends ConsumerStatefulWidget {
  final Ride ride;

  const RideTrackingScreen({super.key, required this.ride});

  @override
  ConsumerState<RideTrackingScreen> createState() => _RideTrackingScreenState();
}

class _RideTrackingScreenState extends ConsumerState<RideTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropIcon;
  bool _isNavigatingToRating = false;

  @override
  void initState() {
    super.initState();
    _loadIcons();
  }

  Future<void> _loadIcons() async {
    _driverIcon = await MarkerUtils.getBikeMarker(
      color: Colors.black, // Dark color for rider view to contrast
    );
    _pickupIcon = await MarkerUtils.getCustomMarker(
      Icons.my_location,
      AppColors.primary,
      70,
    );
    _dropIcon = await MarkerUtils.getCustomMarker(
      Icons.location_on,
      Colors.red,
      70,
    );
    _updateMarkers(widget.ride);
  }

  void _updateMarkers(Ride ride) {
    if (_pickupIcon == null || _dropIcon == null || _driverIcon == null) return;

    setState(() {
      _markers.clear();

      // Pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: ride.pickupLocation.toLatLng(),
          icon: _pickupIcon!,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      // Drop marker
      _markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: ride.dropLocation.toLatLng(),
          icon: _dropIcon!,
          anchor: const Offset(0.5, 0.5),
        ),
      );

      // Driver marker (if location available)
      if (ride.driverCurrentLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: ride.driverCurrentLocation!.toLatLng(),
            icon: _driverIcon!,
            rotation: ride.driverCurrentLocation!.bearing ?? 0,
            anchor: const Offset(0.5, 0.5),
            flat: true,
          ),
        );

        // Calculate and Update ETA/Distance live
        _updateLiveInfo(ride);

        // Animate camera to follow driver if trip started or driver arriving
        if (ride.status != RideStatus.requested) {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: ride.driverCurrentLocation!.toLatLng(),
                zoom: 16,
                bearing: ride.driverCurrentLocation!.bearing ?? 0,
                tilt: 45,
              ),
            ),
          );
        }
      }
    });
  }

  void _updateLiveInfo(Ride ride) {
    if (ride.driverCurrentLocation == null) return;

    final locationService = ref.read(locationServiceProvider);
    LatLng target;
    if (ride.status == RideStatus.accepted ||
        ride.status == RideStatus.driverArriving) {
      target = ride.pickupLocation.toLatLng();
    } else {
      target = ride.dropLocation.toLatLng();
    }

    final distance = locationService.calculateDistance(
      ride.driverCurrentLocation!.toLatLng(),
      target,
    );

    // Estimate time: distance / speed (default 20km/h if speed is 0)
    final speed =
        (ride.driverCurrentLocation!.speed != null &&
            ride.driverCurrentLocation!.speed! > 0)
        ? ride.driverCurrentLocation!.speed! *
              3.6 // m/s to km/h
        : 25.0;

    final timeHours = distance / speed;
    final timeMinutes = (timeHours * 60).round();

    // In a real app, you'd store this in a provider or update Firestore
    // For now we'll just show it in the UI using local state if needed
    // or rely on the text calculation in build
  }

  String _calculateETAText(Ride ride) {
    if (ride.driverCurrentLocation == null) return '-- min';

    final locationService = ref.read(locationServiceProvider);
    LatLng target;
    if (ride.status == RideStatus.accepted ||
        ride.status == RideStatus.driverArriving) {
      target = ride.pickupLocation.toLatLng();
    } else {
      target = ride.dropLocation.toLatLng();
    }

    final distance = locationService.calculateDistance(
      ride.driverCurrentLocation!.toLatLng(),
      target,
    );

    final speed =
        (ride.driverCurrentLocation!.speed != null &&
            ride.driverCurrentLocation!.speed! > 0)
        ? ride.driverCurrentLocation!.speed! *
              3.6 // m/s to km/h
        : 25.0;

    final timeHours = distance / speed;
    final timeMinutes = (timeHours * 60).round();

    if (timeMinutes < 1) return 'Arriving now';
    return '$timeMinutes min';
  }

  String _calculateDistanceText(Ride ride) {
    if (ride.driverCurrentLocation == null) return '-- km';

    final locationService = ref.read(locationServiceProvider);
    LatLng target;
    if (ride.status == RideStatus.accepted ||
        ride.status == RideStatus.driverArriving) {
      target = ride.pickupLocation.toLatLng();
    } else {
      target = ride.dropLocation.toLatLng();
    }

    final distance = locationService.calculateDistance(
      ride.driverCurrentLocation!.toLatLng(),
      target,
    );

    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
    // final polylinePoints = PolylinePoints();
    final polylinePoints = PolylinePoints(
      apiKey: AppConstants.googleMapsApiKey,
    );

    // You'll need to add your Google Maps API key
    final result = await polylinePoints.getRouteBetweenCoordinates(
      // ignore: deprecated_member_use
      request: PolylineRequest(
        origin: PointLatLng(start.latitude, start.longitude),
        destination: PointLatLng(end.latitude, end.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      final polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      setState(() {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: AppColors.primary,
            width: 5,
          ),
        );
      });

      // Fit bounds to show entire route
      _fitBounds(start, end);
    }
  }

  void _fitBounds(LatLng start, LatLng end) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        start.latitude < end.latitude ? start.latitude : end.latitude,
        start.longitude < end.longitude ? start.longitude : end.longitude,
      ),
      northeast: LatLng(
        start.latitude > end.latitude ? start.latitude : end.latitude,
        start.longitude > end.longitude ? start.longitude : end.longitude,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
  }

  String _getStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.requested:
        return 'Finding nearby drivers...';
      case RideStatus.accepted:
        return 'Driver is on the way to pickup';
      case RideStatus.driverArriving:
        return 'Driver is arriving';
      case RideStatus.rideStarted:
        return 'Ride in progress';
      case RideStatus.rideCompleted:
        return 'Ride completed';
      case RideStatus.cancelled:
        return 'Ride cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    final rideStream = ref.watch(rideStreamProvider(widget.ride.id));

    return Scaffold(
      body: rideStream.when(
        data: (ride) {
          if (ride == null) {
            return const Center(child: Text('Ride not found'));
          }

          // Update markers when ride updates
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _updateMarkers(ride);

            // Navigate to rating screen when ride is completed
            if (ride.status == RideStatus.rideCompleted &&
                !_isNavigatingToRating) {
              _isNavigatingToRating = true;
              Future.microtask(() {
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RideRatingScreen(ride: ride),
                    ),
                  );
                }
              });
            }
          });

          return Stack(
            children: [
              // Map
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: ride.pickupLocation.toLatLng(),
                  zoom: 15,
                ),
                onMapCreated: (controller) {
                  _mapController = controller;

                  // Draw route based on ride status
                  if (ride.status == RideStatus.accepted ||
                      ride.status == RideStatus.driverArriving) {
                    // Route from driver to pickup
                    if (ride.driverCurrentLocation != null) {
                      _drawRoute(
                        ride.driverCurrentLocation!.toLatLng(),
                        ride.pickupLocation.toLatLng(),
                      );
                    }
                  } else if (ride.status == RideStatus.rideStarted) {
                    // Route from pickup to drop
                    _drawRoute(
                      ride.pickupLocation.toLatLng(),
                      ride.dropLocation.toLatLng(),
                    );
                  }
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
              ),

              // Live Indicator Badge
              if (ride.driverCurrentLocation != null)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 80,
                  left: 24,
                  right: 24,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.timer,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _calculateETAText(ride),
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const VerticalDivider(width: 1),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.straighten,
                            color: AppColors.primary,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _calculateDistanceText(ride),
                            style: AppTextStyles.heading3.copyWith(
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

              // Top Bar
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 16,
                    left: 24,
                    right: 24,
                    bottom: 16,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      Expanded(
                        child: Text(
                          _getStatusText(ride.status),
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48), // Balance the back button
                    ],
                  ),
                ),
              ),

              // Bottom Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(30),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 20,
                        offset: Offset(0, -5),
                      ),
                    ],
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Driver Info
                        if (ride.driverName != null)
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppColors.primary.withOpacity(
                                  0.1,
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      ride.driverName!,
                                      style: AppTextStyles.heading3,
                                    ),
                                    Text(
                                      ride.driverPhone ?? '',
                                      style: AppTextStyles.body.copyWith(
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.chat_bubble_outline_rounded,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  final currentUser = ref.read(
                                    currentUserProvider,
                                  );
                                  if (currentUser == null) return;

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ChatScreen(
                                        rideId: ride.id,
                                        senderId: currentUser.id,
                                        receiverId: ride.driverId ?? '',
                                        receiverName:
                                            ride.driverName ?? 'Driver',
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppColors.primary,
                                ),
                                onPressed: () {
                                  // Call driver
                                },
                              ),
                            ],
                          ),

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 20),

                        // Ride Details
                        _RideDetailRow(
                          icon: Icons.my_location,
                          label: 'Pickup',
                          value: ride.pickupLocation.address,
                        ),
                        const SizedBox(height: 12),
                        _RideDetailRow(
                          icon: Icons.location_on,
                          label: 'Drop',
                          value: ride.dropLocation.address,
                        ),
                        if (ride.eta != null) ...[
                          const SizedBox(height: 12),
                          _RideDetailRow(
                            icon: Icons.access_time,
                            label: 'ETA',
                            value: ride.eta!,
                          ),
                        ],
                        if (ride.fare != null) ...[
                          const SizedBox(height: 12),
                          _RideDetailRow(
                            icon: Icons.payment,
                            label: 'Fare',
                            value: '₹${ride.fare!.toStringAsFixed(2)}',
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

class _RideDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _RideDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyles.body.copyWith(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: AppTextStyles.body,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
