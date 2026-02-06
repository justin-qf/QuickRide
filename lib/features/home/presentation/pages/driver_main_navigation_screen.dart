import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/features/driver/presentation/pages/driver_home_screen.dart';
import 'package:quickride/features/driver/presentation/pages/earnings_screen.dart';
import 'package:quickride/features/driver/presentation/pages/driver_history_screen.dart';
import 'package:quickride/features/profile/presentation/pages/profile_screen.dart';

class DriverMainNavigationScreen extends StatefulWidget {
  const DriverMainNavigationScreen({super.key});

  @override
  State<DriverMainNavigationScreen> createState() =>
      _DriverMainNavigationScreenState();
}

class _DriverMainNavigationScreenState
    extends State<DriverMainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DriverHomeScreen(),
    const DriverHistoryScreen(),
    const EarningsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  0,
                  Icons.local_taxi_rounded,
                  Icons.local_taxi_outlined,
                  'Requests',
                ),
                _buildNavItem(
                  1,
                  Icons.history_rounded,
                  Icons.history_outlined,
                  'History',
                ),
                _buildNavItem(
                  2,
                  Icons.payments_rounded,
                  Icons.payments_outlined,
                  'Earnings',
                ),
                _buildNavItem(
                  3,
                  Icons.person_rounded,
                  Icons.person_outline_rounded,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData activeIcon,
    IconData inactiveIcon,
    String label,
  ) {
    final bool isSelected = _currentIndex == index;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? activeIcon : inactiveIcon,
              color: isSelected ? AppColors.primary : Colors.grey[400],
              size: 24,
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActiveRidePlaceholder extends StatelessWidget {
  const _ActiveRidePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Active Ride',
          style: TextStyle(fontFamily: 'fontBold'),
        ),
        backgroundColor: Colors.transparent,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_filled_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'No active ride',
              style: AppTextStyles.heading3.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Go to Requests to find a ride',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}
