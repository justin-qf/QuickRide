import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/features/authentication/presentation/pages/forgot_password_screen.dart';
import 'package:quickride/features/authentication/presentation/pages/role_selection_screen.dart';
import 'package:quickride/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:quickride/features/home/presentation/pages/user_main_navigation_screen.dart';
import 'package:quickride/features/home/presentation/pages/driver_main_navigation_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (user != null && mounted) {
        // Update current user provider
        ref.read(currentUserProvider.notifier).state = user;

        // Navigate based on role
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => user.role == UserRole.rider
                ? const UserMainNavigationScreen()
                : const DriverMainNavigationScreen(),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true,

      extendBody: true,
      body: SingleChildScrollView(
        child: SizedBox(
          height: size.height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Top Decor
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      // 🔹 CENTER CONTENT
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Login',
                              style: AppTextStyles.heading1,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Welcome back, you\'ve been missed!',
                              style: AppTextStyles.body,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 50),

                            CustomTextField(
                              controller: _emailController,
                              hintText: 'Email',
                              prefixIcon: Icons.email_outlined,
                            ),
                            const SizedBox(height: 16),

                            CustomTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              prefixIcon: Icons.lock_outline,
                              isPassword: true,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const ForgotPasswordScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  'Forgot Password?',
                                  style: TextStyle(color: AppColors.primary),
                                ),
                              ),
                            ),

                            const SizedBox(height: 24),

                            CustomButton(
                              text: _isLoading ? 'Signing In...' : 'Sign In',
                              onPressed: _isLoading ? null : _handleLogin,
                            ),

                            const SizedBox(height: 30),

                            const Row(
                              children: [
                                Expanded(child: Divider()),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  child: Text(
                                    'Or sign in with',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),

                            const SizedBox(height: 20),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _SocialIcon(
                                  icon: Icons.g_mobiledata,
                                  onTap: () {},
                                ),
                                const SizedBox(width: 20),
                                _SocialIcon(icon: Icons.apple, onTap: () {}),
                                const SizedBox(width: 20),
                                _SocialIcon(icon: Icons.facebook, onTap: () {}),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // 🔹 BOTTOM FOOTER
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account? '),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RoleSelectionScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                'Sign Up',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontFamily: 'fontBold',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SocialIcon({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Icon(icon, size: 30, color: Colors.black87),
      ),
    );
  }
}
