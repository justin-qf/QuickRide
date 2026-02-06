import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:quickride/core/constants/app_constants.dart';
import 'package:quickride/features/rider/presentation/pages/ride_tracking_screen.dart';

class RideRequestScreen extends ConsumerStatefulWidget {
  final LocationData pickupLocation;
  final LocationData dropLocation;

  const RideRequestScreen({
    super.key,
    required this.pickupLocation,
    required this.dropLocation,
  });

  @override
  ConsumerState<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends ConsumerState<RideRequestScreen> {
  bool _isRequestingRide = false;
  double _estimatedFare = 0.0;
  double _estimatedDistance = 0.0;
  final Set<Polyline> _polylines = {};
  GoogleMapController? _mapController;

  @override
  void initState() {
    super.initState();
    _calculateEstimates();
  }

  void _calculateEstimates() {
    final locationService = ref.read(locationServiceProvider);
    final distance = locationService.calculateDistance(
      widget.pickupLocation.toLatLng(),
      widget.dropLocation.toLatLng(),
    );

    setState(() {
      _estimatedDistance = distance;
      // Simple fare calculation: ₹10 per km + ₹20 base fare
      _estimatedFare = (distance * 10) + 20;
    });

    _drawRoute(
      widget.pickupLocation.toLatLng(),
      widget.dropLocation.toLatLng(),
    );
  }

  Future<void> _drawRoute(LatLng start, LatLng end) async {
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
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoordinates,
            color: AppColors.primary,
            width: 5,
          ),
        );
      });

      // Fit bounds
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

  Future<void> _requestRide() async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to request a ride')),
      );
      return;
    }

    setState(() => _isRequestingRide = true);

    try {
      final rideService = ref.read(rideServiceProvider);
      final ride = await rideService.createRide(
        riderId: currentUser.id,
        riderName: currentUser.name,
        riderPhone: currentUser.phone,
        pickupLocation: widget.pickupLocation,
        dropLocation: widget.dropLocation,
      );

      if (mounted) {
        // Navigate to tracking screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => RideTrackingScreen(ride: ride),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to request ride: $e')));
      }
      print('Failed to request ride: $e');
    } finally {
      if (mounted) {
        setState(() => _isRequestingRide = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Ride'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Column(
        children: [
          // Map Preview
          Expanded(
            flex: 2,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.pickupLocation.toLatLng(),
                zoom: 13,
              ),
              onMapCreated: (controller) {
                _mapController = controller;
                _fitBounds(
                  widget.pickupLocation.toLatLng(),
                  widget.dropLocation.toLatLng(),
                );
              },
              markers: {
                Marker(
                  markerId: const MarkerId('pickup'),
                  position: widget.pickupLocation.toLatLng(),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen,
                  ),
                ),
                Marker(
                  markerId: const MarkerId('drop'),
                  position: widget.dropLocation.toLatLng(),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed,
                  ),
                ),
              },
              polylines: _polylines,
              zoomControlsEnabled: false,
              myLocationButtonEnabled: false,
            ),
          ),

          // Ride Details
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ride Details', style: AppTextStyles.heading2),
                    const SizedBox(height: 24),

                    // Pickup Location
                    _LocationCard(
                      icon: Icons.my_location,
                      iconColor: Colors.green,
                      title: 'Pickup Location',
                      address: widget.pickupLocation.address,
                    ),

                    const SizedBox(height: 16),

                    // Drop Location
                    _LocationCard(
                      icon: Icons.location_on,
                      iconColor: Colors.red,
                      title: 'Drop Location',
                      address: widget.dropLocation.address,
                    ),

                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 24),

                    // Fare Estimate
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimated Distance',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_estimatedDistance.toStringAsFixed(2)} km',
                              style: AppTextStyles.heading3,
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Estimated Fare',
                              style: AppTextStyles.body.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '₹${_estimatedFare.toStringAsFixed(2)}',
                              style: AppTextStyles.heading2.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Request Ride Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isRequestingRide ? null : _requestRide,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: _isRequestingRide
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text('Request Ride', style: AppTextStyles.button),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Info Text
                    Text(
                      'A nearby driver will be assigned to your ride',
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
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String address;

  const _LocationCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.inputFill,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.body.copyWith(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  address,
                  style: AppTextStyles.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
