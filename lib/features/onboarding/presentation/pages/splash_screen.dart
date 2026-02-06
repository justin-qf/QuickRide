import 'package:flutter/material.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/features/onboarding/presentation/pages/intro_screen.dart';
import 'package:quickride/core/services/local_storage_service.dart';
import 'package:quickride/features/home/presentation/pages/user_main_navigation_screen.dart';
import 'package:quickride/features/home/presentation/pages/driver_main_navigation_screen.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _controller.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        final localStorage = LocalStorageService();
        final isLoggedIn = await localStorage.isLoggedIn();

        if (isLoggedIn) {
          final role = await localStorage.getUserRole();
          final userId = await localStorage.getUserId();

          if (userId != null) {
            // Load user data into provider
            final authService = ref.read(authServiceProvider);
            final user = await authService.getUserData(userId);
            if (user != null) {
              ref.read(currentUserProvider.notifier).state = user;

              Widget nextScreen;
              if (role == UserRole.driver.name) {
                nextScreen = const DriverMainNavigationScreen();
              } else {
                nextScreen = const UserMainNavigationScreen();
              }

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => nextScreen),
              );
              return;
            }
          }
        }

        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const IntroScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/pngs/app_logo.png',
                      width: 220,
                      height: 220,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
