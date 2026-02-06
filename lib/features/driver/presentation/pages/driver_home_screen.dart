import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/core/utils/helper.dart';
import 'package:quickride/features/driver/presentation/pages/driver_ride_screen.dart';

class DriverHomeScreen extends ConsumerStatefulWidget {
  const DriverHomeScreen({super.key});

  @override
  ConsumerState<DriverHomeScreen> createState() => _DriverHomeScreenState();
}

class _DriverHomeScreenState extends ConsumerState<DriverHomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isOnline = false;
  StreamSubscription<dynamic>? _locationSubscription;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
    _initOnlineStatus();
  }

  void _initOnlineStatus() {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      _isOnline = user.isOnline;
      if (_isOnline) {
        _startLocationTracking();
      }
    }
  }

  void _startLocationTracking() {
    if (_locationSubscription != null) return;

    final locationService = ref.read(locationServiceProvider);
    _locationSubscription = locationService.streamLocationUpdates().listen((
      position,
    ) {
      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
        });
      }
    });
  }

  void _stopLocationTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _loadCurrentLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();

    if (location != null && mounted) {
      setState(() {
        _currentLocation = location;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
    }
  }

  Future<void> _toggleOnlineStatus() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) return;

    final newStatus = !_isOnline;
    setState(() {
      _isOnline = newStatus;
    });

    // Update local state in provider
    ref.read(currentUserProvider.notifier).state = currentUser.copyWith(
      isOnline: newStatus,
    );

    final authService = ref.read(authServiceProvider);
    await authService.updateDriverStatus(currentUser.id, newStatus);

    if (newStatus) {
      _startLocationTracking();
    } else {
      _stopLocationTracking();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final activeRideAsync = currentUser != null
        ? ref.watch(driverActiveRideProvider(currentUser.id))
        : null;

    // Get nearby ride requests when online
    final nearbyRidesAsync = _isOnline && _currentLocation != null
        ? ref.watch(nearbyRideRequestsProvider(_currentLocation!))
        : null;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          _currentLocation == null
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 15,
                  ),
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  myLocationEnabled: true,
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
                  CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (currentUser?.name ?? 'Driver').capitalizeFirst(),
                          style: AppTextStyles.heading3,
                        ),
                        Text(
                          _isOnline ? 'Online' : 'Offline',
                          style: AppTextStyles.body.copyWith(
                            color: _isOnline ? Colors.green : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: _isOnline,
                    onChanged: (value) => _toggleOnlineStatus(),
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),
          ),

          // Check for active ride
          if (activeRideAsync != null)
            activeRideAsync.when(
              data: (ride) {
                if (ride != null) {
                  // Navigate to ride screen if there's an active ride
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DriverRideScreen(ride: ride),
                      ),
                    );
                  });
                  return const SizedBox.shrink();
                }
                return const SizedBox.shrink();
              },
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),

          // Nearby Ride Requests
          if (_isOnline && nearbyRidesAsync != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: nearbyRidesAsync.when(
                data: (rides) {
                  if (rides.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(24),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(30),
                        ),
                      ),
                      child: SafeArea(
                        top: false,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search,
                              size: 60,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Looking for ride requests...',
                              style: AppTextStyles.heading3,
                            ),
                            Text(
                              'You\'ll be notified when a rider needs you',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey[600],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Container(
                    height: 300,
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
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            'Nearby Ride Requests',
                            style: AppTextStyles.heading2,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            physics: BouncingScrollPhysics(),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: rides.length,
                            itemBuilder: (context, index) {
                              return _RideRequestCard(
                                ride: rides[index],
                                onAccept: () async {
                                  final rideService = ref.read(
                                    rideServiceProvider,
                                  );
                                  await rideService.acceptRide(
                                    rideId: rides[index].id,
                                    driverId: currentUser!.id,
                                    driverName: currentUser.name,
                                    driverPhone: currentUser.phone,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ),

          // Offline Message
          if (!_isOnline)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.offline_bolt,
                        size: 60,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text('You\'re Offline', style: AppTextStyles.heading2),
                      const SizedBox(height: 8),
                      Text(
                        'Turn on to start receiving ride requests',
                        style: AppTextStyles.body.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 320,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: _loadCurrentLocation,
              child: const Icon(Icons.my_location, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }
}

class _RideRequestCard extends StatelessWidget {
  final Ride ride;
  final VoidCallback onAccept;

  const _RideRequestCard({required this.ride, required this.onAccept});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                ride.riderName,
                style: AppTextStyles.heading3.copyWith(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.my_location, color: Colors.green, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.pickupLocation.address,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ride.dropLocation.address,
                  style: AppTextStyles.body,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Accept Ride',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
