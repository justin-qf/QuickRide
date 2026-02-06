import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:quickride/core/constants/app_constants.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/core/utils/marker_utils.dart';
import 'package:quickride/features/driver/presentation/pages/driver_home_screen.dart';
import 'package:quickride/features/home/presentation/pages/driver_main_navigation_screen.dart';
import 'package:quickride/features/tracking/presentation/pages/chat_screen.dart';
import 'package:quickride/core/providers/auth_provider.dart';

class DriverRideScreen extends ConsumerStatefulWidget {
  final Ride ride;

  const DriverRideScreen({super.key, required this.ride});

  @override
  ConsumerState<DriverRideScreen> createState() => _DriverRideScreenState();
}

class _DriverRideScreenState extends ConsumerState<DriverRideScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  BitmapDescriptor? _pickupIcon;
  BitmapDescriptor? _dropIcon;
  BitmapDescriptor? _driverIcon;
  StreamSubscription? _locationSubscription;
  LatLng? _currentLocation;
  double _currentBearing = 0;
  bool _isPanelExpanded = true;
  RideStatus? _lastDrawnStatus;
  bool _isUpdatingStatus = false;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _startLocationTracking();
  }

  Future<void> _loadIcons() async {
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
    _driverIcon = await MarkerUtils.getBikeMarker(color: AppColors.primary);
    _updateMarkers(widget.ride);
  }

  void _startLocationTracking() {
    final locationService = ref.read(locationServiceProvider);
    _locationSubscription = locationService.streamLocationUpdates().listen((
      position,
    ) {
      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentLocation = location;
        _currentBearing = position.heading;
      });

      // Update driver location in Firebase
      final rideService = ref.read(rideServiceProvider);
      rideService.updateDriverLocation(
        widget.ride.id,
        LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          address: '',
          bearing: position.heading,
          speed: position.speed,
        ),
      );

      // Move camera to follow driver smoothly
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: location, zoom: 16, bearing: position.heading),
        ),
      );
    });
  }

  void _updateMarkers(Ride ride) {
    if (_pickupIcon == null || _dropIcon == null || _driverIcon == null) return;

    setState(() {
      _markers.clear();

      // Driver Current Location Marker
      if (_currentLocation != null) {
        _markers.add(
          Marker(
            markerId: const MarkerId('driver'),
            position: _currentLocation!,
            icon: _driverIcon!,
            rotation: _currentBearing,
            anchor: const Offset(0.5, 0.5),
            flat: true,
          ),
        );
      }

      // Pickup marker
      _markers.add(
        Marker(
          markerId: const MarkerId('pickup'),
          position: ride.pickupLocation.toLatLng(),
          icon: _pickupIcon!,
          infoWindow: InfoWindow(
            title: 'Pickup',
            snippet: ride.pickupLocation.address,
          ),
        ),
      );

      // Drop marker
      _markers.add(
        Marker(
          markerId: const MarkerId('drop'),
          position: ride.dropLocation.toLatLng(),
          icon: _dropIcon!,
          infoWindow: InfoWindow(
            title: 'Drop',
            snippet: ride.dropLocation.address,
          ),
        ),
      );
    });
  }

  Future<void> _drawRoute(LatLng start, LatLng end, RideStatus status) async {
    if (_lastDrawnStatus == status) return;

    try {
      final polylinePoints = PolylinePoints(
        apiKey: AppConstants.googleMapsApiKey,
      );

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
          _polylines.clear();
          _polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              color: AppColors.primary,
              width: 5,
            ),
          );
        });

        // Calculate distance
        final locationService = ref.read(locationServiceProvider);
        final distance = locationService.calculateDistance(start, end);

        // Update fare (simple calculation: ₹10 per km + ₹20 base fare)
        final fare = (distance * 10) + 20;

        final rideService = ref.read(rideServiceProvider);
        await rideService.updateRideFare(widget.ride.id, fare, distance);

        setState(() {
          _lastDrawnStatus = status;
        });
      }
    } catch (e) {
      debugPrint('Route error: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to fetch route. Check internet connection.'),
          ),
        );
      }
    }
  }

  Future<void> _updateRideStatus(RideStatus status) async {
    if (_isUpdatingStatus) return;

    setState(() {
      _isUpdatingStatus = true;
    });

    try {
      print("_updateRideStatus called with status: $status");

      final rideService = ref.read(rideServiceProvider);
      await rideService.updateRideStatus(widget.ride.id, status);

      if (status == RideStatus.rideCompleted) {
        // Navigate back to driver home
        if (mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const DriverMainNavigationScreen(),
            ),
            (route) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update status: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingStatus = false;
        });
      }
    }
  }

  String _getActionButtonText(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return 'Arrived at Pickup';
      case RideStatus.driverArriving:
        return 'Start Ride';
      case RideStatus.rideStarted:
        return 'Complete Ride';
      default:
        return 'Update Status';
    }
  }

  RideStatus _getNextStatus(RideStatus currentStatus) {
    switch (currentStatus) {
      case RideStatus.accepted:
        return RideStatus.driverArriving;
      case RideStatus.driverArriving:
        return RideStatus.rideStarted;
      case RideStatus.rideStarted:
        return RideStatus.rideCompleted;
      default:
        return currentStatus;
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

            // Draw route based on status
            if (_currentLocation != null) {
              if (ride.status == RideStatus.accepted ||
                  ride.status == RideStatus.driverArriving) {
                // Route to pickup
                _drawRoute(
                  _currentLocation!,
                  ride.pickupLocation.toLatLng(),
                  ride.status,
                );
              } else if (ride.status == RideStatus.rideStarted) {
                // Route to drop
                _drawRoute(
                  ride.pickupLocation.toLatLng(),
                  ride.dropLocation.toLatLng(),
                  ride.status,
                );
              }
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
                },
                markers: _markers,
                polylines: _polylines,
                myLocationEnabled: false,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
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
                        onPressed: () => Navigator.pop(context),
                      ),
                      Expanded(
                        child: Text(
                          _getRideStatusText(ride.status),
                          style: AppTextStyles.heading3,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
              ),

              // Bottom Panel
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.fastOutSlowIn,
                  height: _isPanelExpanded ? 500 : 80,
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
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
                  child: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Toggle Handle
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isPanelExpanded = !_isPanelExpanded;
                              });
                            },
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Center(
                                child: Icon(
                                  _isPanelExpanded
                                      ? Icons.keyboard_arrow_down_rounded
                                      : Icons.keyboard_arrow_up_rounded,
                                  color: Colors.grey[400],
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                          // Rider Info
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
                                      ride.riderName,
                                      style: AppTextStyles.heading3,
                                    ),
                                    Text(
                                      ride.riderPhone,
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
                                        receiverId: ride.riderId,
                                        receiverName: ride.riderName,
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
                                  // Call rider
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
                          if (ride.distance != null) ...[
                            const SizedBox(height: 12),
                            _RideDetailRow(
                              icon: Icons.straighten,
                              label: 'Distance',
                              value: '${ride.distance!.toStringAsFixed(2)} km',
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

                          const SizedBox(height: 24),

                          // Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isUpdatingStatus
                                  ? null
                                  : () {
                                      _updateRideStatus(
                                        _getNextStatus(ride.status),
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                              ),
                              child: _isUpdatingStatus
                                  ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                  : Text(
                                      _getActionButtonText(ride.status),
                                      style: AppTextStyles.button,
                                    ),
                            ),
                          ),
                        ],
                      ),
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

  String _getRideStatusText(RideStatus status) {
    switch (status) {
      case RideStatus.accepted:
        return 'Going to Pickup';
      case RideStatus.driverArriving:
        return 'Arrived at Pickup';
      case RideStatus.rideStarted:
        return 'Ride in Progress';
      default:
        return 'Ride';
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
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
