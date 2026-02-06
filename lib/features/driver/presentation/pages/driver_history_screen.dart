import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/features/tracking/presentation/pages/ride_detail_screen.dart';

class DriverHistoryScreen extends ConsumerWidget {
  const DriverHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider.select((user) => user?.id));
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final ridesAsync = ref.watch(
      rideHistoryProvider((userId: userId, isDriver: true)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Ride History',
          style: TextStyle(fontFamily: 'fontBold'),
        ),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        elevation: 0,
      ),
      body: ridesAsync.when(
        skipLoadingOnRefresh: true,
        data: (rides) {
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_rounded,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No completed rides yet',
                    style: AppTextStyles.heading3.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            physics: BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: rides.length,
            itemBuilder: (context, index) {
              final ride = rides[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RideDetailScreen(ride: ride),
                      ),
                    );
                  },
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.history, color: AppColors.primary),
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ride.riderName,
                        style: const TextStyle(fontFamily: 'fontBold'),
                      ),
                      Text(
                        '₹${ride.fare?.toStringAsFixed(2) ?? '0.00'}',
                        style: const TextStyle(
                          fontFamily: 'fontBold',
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        ride.completedAt != null
                            ? DateFormat(
                                'dd MMM yyyy, hh:mm a',
                              ).format(ride.completedAt!)
                            : 'N/A',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.grey, size: 14),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              ride.dropLocation.address.split(',').first,
                              style: TextStyle(fontSize: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
