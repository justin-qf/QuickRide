import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';

class RideDetailScreen extends StatelessWidget {
  final Ride ride;

  const RideDetailScreen({super.key, required this.ride});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ride Details',
          style: TextStyle(fontFamily: 'fontBold'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Ride Completed',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'fontBold',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    ride.completedAt != null
                        ? DateFormat(
                            'dd MMM yyyy, hh:mm a',
                          ).format(ride.completedAt!)
                        : 'N/A',
                    style: TextStyle(color: Colors.white.withOpacity(0.8)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Ride Summary
            _buildDetailCard(
              title: 'Summary',
              children: [
                _buildDetailRow(
                  'Fare',
                  '₹${ride.fare?.toStringAsFixed(2) ?? '0.00'}',
                  isBold: true,
                ),
                const Divider(height: 24),
                _buildDetailRow(
                  'Distance',
                  '${ride.distance?.toStringAsFixed(2) ?? '0.00'} km',
                ),
                const Divider(height: 24),
                _buildDetailRow('Duration', _calculateDuration()),
              ],
            ),
            const SizedBox(height: 16),

            // Location Details
            _buildDetailCard(
              title: 'Route',
              children: [
                _buildLocationItem(
                  icon: Icons.my_location,
                  color: Colors.green,
                  title: 'Pickup',
                  address: ride.pickupLocation.address,
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: SizedBox(
                    height: 20,
                    child: VerticalDivider(width: 1, thickness: 1),
                  ),
                ),
                _buildLocationItem(
                  icon: Icons.location_on,
                  color: Colors.red,
                  title: 'Drop-off',
                  address: ride.dropLocation.address,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Driver/Rider Info
            _buildDetailCard(
              title: 'Participants',
              children: [
                _buildInfoRow(
                  label: 'Rider',
                  name: ride.riderName,
                  phone: ride.riderPhone,
                ),
                if (ride.driverName != null) ...[
                  const Divider(height: 24),
                  _buildInfoRow(
                    label: 'Driver',
                    name: ride.driverName!,
                    phone: ride.driverPhone ?? '',
                  ),
                ],
              ],
            ),

            if (ride.rating != null) ...[
              const SizedBox(height: 16),
              _buildDetailCard(
                title: 'Feedback',
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        ride.rating!.toStringAsFixed(1),
                        style: const TextStyle(
                          fontFamily: 'fontBold',
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  if (ride.feedback != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      ride.feedback!,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String _calculateDuration() {
    if (ride.startedAt != null && ride.completedAt != null) {
      final diff = ride.completedAt!.difference(ride.startedAt!);
      return '${diff.inMinutes} mins';
    }
    return 'N/A';
  }

  Widget _buildDetailCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontFamily: 'fontBold',
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontFamily: isBold ? 'fontBold' : 'fontSemiBold',
            fontSize: isBold ? 16 : 14,
            color: isBold ? AppColors.primary : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationItem({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                address,
                style: const TextStyle(fontSize: 14, fontFamily: 'fontMedium'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String name,
    required String phone,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            name[0],
            style: const TextStyle(
              color: AppColors.primary,
              fontFamily: 'fontBold',
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(name, style: const TextStyle(fontFamily: 'fontBold')),
            ],
          ),
        ),
        Text(phone, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
      ],
    );
  }
}
