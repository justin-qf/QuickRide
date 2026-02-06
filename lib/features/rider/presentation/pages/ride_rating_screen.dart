import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/ride_model.dart';
import 'package:quickride/core/providers/ride_provider.dart';
import 'package:quickride/features/home/presentation/pages/user_main_navigation_screen.dart';
import 'package:quickride/features/rider/presentation/pages/rider_home_screen.dart';

class RideRatingScreen extends ConsumerStatefulWidget {
  final Ride ride;

  const RideRatingScreen({super.key, required this.ride});

  @override
  ConsumerState<RideRatingScreen> createState() => _RideRatingScreenState();
}

class _RideRatingScreenState extends ConsumerState<RideRatingScreen> {
  double _rating = 5.0;
  final TextEditingController _feedbackController = TextEditingController();
  bool _isSubmitting = false;
  bool _isNavigatedAway = false;

  Future<void> _submitRating() async {
    setState(() => _isSubmitting = true);

    try {
      final rideService = ref.read(rideServiceProvider);
      await rideService.submitRating(
        widget.ride.id,
        _rating,
        _feedbackController.text.isEmpty ? null : _feedbackController.text,
      );

      if (mounted) {
        _navigateToHome();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to submit rating: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _navigateToHome() {
    if (_isNavigatedAway) return;
    _isNavigatedAway = true;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const UserMainNavigationScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const Spacer(),
              // Success Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 60,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Ride Completed!',
                style: AppTextStyles.heading1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                'Thank you for riding with us',
                style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Ride Summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _SummaryRow(
                      label: 'Distance',
                      value: widget.ride.distance != null
                          ? '${widget.ride.distance!.toStringAsFixed(2)} km'
                          : 'N/A',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Fare',
                      value: widget.ride.fare != null
                          ? '₹${widget.ride.fare!.toStringAsFixed(2)}'
                          : 'N/A',
                    ),
                    const Divider(height: 24),
                    _SummaryRow(
                      label: 'Driver',
                      value: widget.ride.driverName ?? 'N/A',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Rating Section
              Text('Rate your ride', style: AppTextStyles.heading2),
              const SizedBox(height: 16),
              RatingBar.builder(
                initialRating: _rating,
                minRating: 1,
                direction: Axis.horizontal,
                allowHalfRating: true,
                itemCount: 5,
                itemSize: 30,
                itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                itemBuilder: (context, _) =>
                    const Icon(Icons.star, color: Colors.amber),
                onRatingUpdate: (rating) {
                  setState(() {
                    _rating = rating;
                  });
                },
              ),

              const SizedBox(height: 10),

              // Feedback TextField
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: TextField(
                  controller: _feedbackController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share your feedback (optional)',
                    border: InputBorder.none,
                  ),
                ),
              ),

              const Spacer(),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitRating,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Submit Rating', style: AppTextStyles.button),
                ),
              ),

              const SizedBox(height: 10),

              // Skip Button
              TextButton(
                onPressed: _isSubmitting ? null : _navigateToHome,
                child: Text(
                  'Skipss',
                  style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.body.copyWith(color: Colors.grey[600]),
        ),
        Text(value, style: AppTextStyles.heading3),
      ],
    );
  }
}
