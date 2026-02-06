import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/ride_provider.dart';

class SelectLocationScreen extends ConsumerStatefulWidget {
  final bool isPickup;

  const SelectLocationScreen({super.key, required this.isPickup});

  @override
  ConsumerState<SelectLocationScreen> createState() =>
      _SelectLocationScreenState();
}

class _SelectLocationScreenState extends ConsumerState<SelectLocationScreen> {
  GoogleMapController? _mapController;
  LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final locationService = ref.read(locationServiceProvider);
    final location = await locationService.getCurrentLocation();

    if (location != null && mounted) {
      setState(() {
        _selectedLocation = location;
      });

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(location, 15));

      _updateAddress(location);
    }
  }

  Future<void> _updateAddress(LatLng location) async {
    final locationService = ref.read(locationServiceProvider);
    final address = await locationService.getAddressFromCoordinates(location);

    if (mounted) {
      setState(() {
        _selectedAddress = address;
        _searchController.text = address;
      });
    }
  }

  void _onMapTap(LatLng location) {
    setState(() {
      _selectedLocation = location;
    });
    _updateAddress(location);
  }

  void _confirmLocation() {
    if (_selectedLocation != null) {
      final locationData = LocationData(
        latitude: _selectedLocation!.latitude,
        longitude: _selectedLocation!.longitude,
        address: _selectedAddress,
      );
      Navigator.pop(context, locationData);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? const LatLng(37.7749, -122.4194),
              zoom: 15,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            onTap: _onMapTap,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Center Marker
          Center(
            child: Icon(
              widget.isPickup ? Icons.my_location : Icons.location_on,
              size: 50,
              color: AppColors.primary,
            ),
          ),

          // Top Search Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              color: Colors.white,
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.inputFill,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: widget.isPickup
                              ? 'Search pickup location'
                              : 'Search drop location',
                          border: InputBorder.none,
                          icon: const Icon(Icons.search, color: Colors.grey),
                        ),
                        onSubmitted: (value) async {
                          // Search for location
                          final locationService = ref.read(
                            locationServiceProvider,
                          );
                          final location = await locationService
                              .getCoordinatesFromAddress(value);

                          if (location != null && mounted) {
                            setState(() {
                              _selectedLocation = location;
                            });

                            _mapController?.animateCamera(
                              CameraUpdate.newLatLngZoom(location, 15),
                            );

                            _updateAddress(location);
                          }
                        },
                      ),
                    ),
                  ),
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isPickup ? 'Pickup Location' : 'Drop Location',
                      style: AppTextStyles.heading2,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selectedAddress.isEmpty
                          ? 'Tap on map to select location'
                          : _selectedAddress,
                      style: AppTextStyles.body.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _selectedLocation != null
                            ? _confirmLocation
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          'Confirm Location',
                          style: AppTextStyles.button,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // My Location Button
          Positioned(
            right: 16,
            bottom: 200,
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
    _searchController.dispose();
    super.dispose();
  }
}
