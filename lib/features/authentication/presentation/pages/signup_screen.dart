import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/models/user_model.dart';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:quickride/features/home/presentation/pages/user_main_navigation_screen.dart';
import 'package:quickride/features/home/presentation/pages/driver_main_navigation_screen.dart';

class SignupScreen extends ConsumerStatefulWidget {
  final UserRole role;

  const SignupScreen({super.key, required this.role});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(authServiceProvider);
      final user = await authService.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        role: widget.role,
      );

      print("Signup Result User: $user");
      print("_isLoading: $_isLoading");

      if (user != null && mounted) {
        // Update current user provider
        ref.read(currentUserProvider.notifier).state = user;

        // Navigate based on role
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => widget.role == UserRole.rider
                ? const UserMainNavigationScreen()
                : const DriverMainNavigationScreen(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Signup failed: ${e.toString()}')),
        );
      }

      print('Signup failed: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text(
              'Create ${widget.role == UserRole.rider ? 'Rider' : 'Driver'} Account',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Fill your information below to get started.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),
            CustomTextField(
              controller: _nameController,
              hintText: 'Full Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              hintText: 'Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: _isLoading ? 'Creating Account...' : 'Sign Up',
              onPressed: _isLoading ? null : _handleSignup,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Already have an account? '),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontFamily: 'fontBold',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
