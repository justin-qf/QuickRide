import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/core/utils/marker_utils.dart';
import 'package:quickride/features/rider/presentation/pages/select_location_screen.dart';
import 'package:quickride/features/rider/presentation/pages/ride_tracking_screen.dart';
import 'package:quickride/features/rider/presentation/pages/ride_request_screen.dart';

class RiderHomeScreen extends ConsumerStatefulWidget {
  const RiderHomeScreen({super.key});

  @override
  ConsumerState<RiderHomeScreen> createState() => _RiderHomeScreenState();
}

class _RiderHomeScreenState extends ConsumerState<RiderHomeScreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  LocationData? _pickupLocation;
  LocationData? _dropLocation;
  BitmapDescriptor? _bikeIcon;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    _loadCurrentLocation();
  }

  Future<void> _loadIcons() async {
    _bikeIcon = await MarkerUtils.getBikeMarker(color: AppColors.primary);
    if (mounted) setState(() {});
  }

  Future<void> _loadCurrentLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();

    if (location != null && mounted) {
      setState(() {
        _currentLocation = location;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));
    } else {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _checkAndNavigateToRequest() {
    if (_pickupLocation != null && _dropLocation != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RideRequestScreen(
            pickupLocation: _pickupLocation!,
            dropLocation: _dropLocation!,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final activeRideAsync = currentUser != null
        ? ref.watch(riderActiveRideProvider(currentUser.id))
        : null;

    // Nearby drivers
    final availableDriversAsync = ref.watch(availableDriversProvider);

    final markers = {
      if (_currentLocation != null)
        Marker(
          markerId: const MarkerId('current_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            HSVColor.fromColor(AppColors.primary).hue,
          ),
        ),
      ...availableDriversAsync.maybeWhen(
        data: (drivers) => drivers
            .where((d) => d.lastLocation != null)
            .map(
              (d) => Marker(
                markerId: MarkerId('driver_${d.id}'),
                position: LatLng(
                  d.lastLocation!.latitude,
                  d.lastLocation!.longitude,
                ),
                icon:
                    _bikeIcon ??
                    BitmapDescriptor.defaultMarkerWithHue(
                      HSVColor.fromColor(AppColors.primary).hue,
                    ),
                rotation: d.lastLocation?.bearing ?? 0,
                anchor: const Offset(0.5, 0.5),
                flat: true,
                infoWindow: InfoWindow(title: d.name),
              ),
            )
            .toSet(),
        orElse: () => <Marker>{},
      ),
    };

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
                  markers: markers,
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
                          'Hello, ${currentUser?.name ?? 'Rider'}',
                          style: AppTextStyles.heading3,
                        ),
                        Text(
                          'Where are you going?',
                          style: AppTextStyles.body.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
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
                  // Navigate to tracking screen if there's an active ride
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideTrackingScreen(ride: ride),
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

          // Bottom Panel
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
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
                    _LocationButton(
                      icon: Icons.my_location,
                      label: _pickupLocation != null
                          ? 'Pickup Location'
                          : 'Pickup Location',
                      subtitle:
                          _pickupLocation?.address ??
                          'Select your pickup point',
                      onTap: () async {
                        final result = await Navigator.push<LocationData>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SelectLocationScreen(isPickup: true),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _pickupLocation = result;
                          });
                          _checkAndNavigateToRequest();
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _LocationButton(
                      icon: Icons.location_on,
                      label: _dropLocation != null
                          ? 'Drop Location'
                          : 'Drop Location',
                      subtitle:
                          _dropLocation?.address ?? 'Where do you want to go?',
                      onTap: () async {
                        final result = await Navigator.push<LocationData>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const SelectLocationScreen(isPickup: false),
                          ),
                        );
                        if (result != null) {
                          setState(() {
                            _dropLocation = result;
                          });
                          _checkAndNavigateToRequest();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 250,
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
}

class _LocationButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  const _LocationButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.inputFill,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTextStyles.heading3.copyWith(fontSize: 16),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.body.copyWith(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
