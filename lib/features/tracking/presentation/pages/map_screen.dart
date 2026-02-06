import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/utils/marker_utils.dart';
import 'package:quickride/features/tracking/presentation/controllers/tracking_controller.dart';
import 'package:quickride/features/tracking/presentation/controllers/tracking_state.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  BitmapDescriptor? _driverIcon;
  BitmapDescriptor? _customerIcon;

  @override
  void initState() {
    super.initState();
    _loadIcons();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(trackingControllerProvider.notifier).initialize();
    });
  }

  Future<void> _loadIcons() async {
    final driver = await MarkerUtils.getCustomMarkerFromIcon(
      Icons.delivery_dining,
      Colors.deepOrange,
    );
    final customer = await MarkerUtils.getCustomMarkerFromIcon(
      Icons.home,
      Colors.black,
    );
    setState(() {
      _driverIcon = driver;
      _customerIcon = customer;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(trackingControllerProvider);

    // Listen to driver location changes to update camera
    ref.listen<TrackingState>(trackingControllerProvider, (
      previous,
      next,
    ) async {
      if (next.driverLocation != null &&
          (previous?.driverLocation != next.driverLocation)) {
        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: next.driverLocation!,
              zoom: 17,
              bearing: next.driverHeading,
              tilt: 45, // 3D effect
            ),
          ),
        );
      }
    });

    return Scaffold(
      body: Stack(
        children: [_buildMap(state), _buildBottomPanel(state), _buildTopBar()],
      ),
    );
  }

  Widget _buildMap(TrackingState state) {
    if (state.isLoading ||
        state.driverLocation == null ||
        state.customerLocation == null) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    Set<Marker> markers = {};

    // Driver Marker
    markers.add(
      Marker(
        markerId: const MarkerId('driver'),
        position: state.driverLocation!,
        icon: _driverIcon ?? BitmapDescriptor.defaultMarker,
        rotation: state.driverHeading,
        anchor: const Offset(0.5, 0.5),
        zIndex: 2,
      ),
    );

    // Customer Marker
    markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: state.customerLocation!,
        icon:
            _customerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(
              HSVColor.fromColor(AppColors.primary).hue,
            ),
        anchor: const Offset(0.5, 0.5),
      ),
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: state.driverLocation!,
        zoom: 15,
      ),
      markers: markers,
      polylines: {
        Polyline(
          polylineId: const PolylineId('route'),
          points: state.polylineCoordinates,
          color: Colors.black,
          width: 5,
        ),
      },
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
        // Set map style here if desired for Dark Mode
      },
      myLocationEnabled: false,
      compassEnabled: false,
      zoomControlsEnabled: false,
    );
  }

  Widget _buildTopBar() {
    return Positioned(
      top: 50,
      left: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 2),
          ],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black),
      ),
    );
  }

  Widget _buildBottomPanel(TrackingState state) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ETA and Heading
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Heading your way',
                      style: TextStyle(fontFamily: 'fontBold', fontSize: 18),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Arriving at ${state.eta}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '10:45 AM',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'fontBold',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timeline
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildTimelineItem(Icons.check_circle, 'Accepted', true, true),
                _buildTimelineLine(true),
                _buildTimelineItem(Icons.restaurant, 'Cooking', true, true),
                _buildTimelineLine(true),
                _buildTimelineItem(
                  Icons.delivery_dining,
                  'Pickup',
                  true,
                  false,
                ), // Current
                _buildTimelineLine(false),
                _buildTimelineItem(Icons.home, 'Delivered', false, false),
              ],
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),

            // Driver Info
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(
                    'https://i.pravatar.cc/150?img=12',
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Shahinur Rahman',
                      style: TextStyle(fontFamily: 'fontBold', fontSize: 16),
                    ),
                    Text(
                      'Delivery Boy',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green[50]?.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.phone, color: Colors.green, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Order Received',
                  style: TextStyle(color: Colors.white, fontFamily: 'fontBold'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(
    IconData icon,
    String label,
    bool isActive,
    bool isPast,
  ) {
    final color = isActive ? AppColors.primary : Colors.grey[300];
    final iconColor = isActive ? Colors.white : Colors.grey[500];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontFamily: isActive ? 'fontBold' : 'fontRegular',
            color: isActive ? Colors.black : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineLine(bool isActive) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive ? AppColors.primary : Colors.grey[300],
      ),
    );
  }
}
