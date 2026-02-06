import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/features/tracking/presentation/pages/ride_detail_screen.dart';

class EarningsScreen extends ConsumerWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(currentUserProvider.select((user) => user?.id));
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please login')));
    }

    final historyAsync = ref.watch(
      rideHistoryProvider((userId: userId, isDriver: true)),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Earnings', style: TextStyle(fontFamily: 'fontBold')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: historyAsync.when(
        skipLoadingOnRefresh: true,
        data: (rides) {
          double totalEarnings = 0;
          for (var ride in rides) {
            totalEarnings += ride.fare ?? 0;
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Lifetime Earnings',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '₹${totalEarnings.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontFamily: 'fontBold',
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${rides.length} Completed Rides',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontFamily: 'fontSemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildStatCard(
                      'Total Trips',
                      rides.length.toString(),
                      Icons.directions_bike,
                    ),
                    const SizedBox(width: 16),
                    _buildStatCard(
                      'Avg Rating',
                      _calculateAvgRating(rides),
                      Icons.star,
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Performance History',
                    style: AppTextStyles.heading3,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    physics: BouncingScrollPhysics(),
                    itemCount: rides.length,
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RideDetailScreen(ride: ride),
                              ),
                            );
                          },
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ride.completedAt != null
                                        ? DateFormat(
                                            'dd MMM yyyy',
                                          ).format(ride.completedAt!)
                                        : 'N/A',
                                    style: TextStyle(
                                      color: Colors.grey[500],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    ride.completedAt != null
                                        ? DateFormat(
                                            'EEEE',
                                          ).format(ride.completedAt!)
                                        : 'N/A',
                                    style: const TextStyle(
                                      fontFamily: 'fontSemiBold',
                                    ),
                                  ),
                                ],
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
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              ride.dropLocation.address.split(',').first,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  String _calculateAvgRating(List<Ride> rides) {
    if (rides.isEmpty) return '0.0';
    double total = 0;
    int ratedCount = 0;
    for (var ride in rides) {
      if (ride.rating != null) {
        total += ride.rating!;
        ratedCount++;
      }
    }
    if (ratedCount == 0) return '0.0';
    return (total / ratedCount).toStringAsFixed(1);
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontFamily: 'fontBold'),
            ),
            Text(
              label,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
