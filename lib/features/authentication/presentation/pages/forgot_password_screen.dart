import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/features/authentication/presentation/widgets/auth_widgets.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_reset, size: 80, color: AppColors.primary),
            const SizedBox(height: 30),
            Text(
              'Forgot Password',
              style: AppTextStyles.heading1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Enter your email address and we will send you a reset link.',
              style: AppTextStyles.body,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            const CustomTextField(
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
            ),

            const SizedBox(height: 40),
            CustomButton(
              text: 'Send Reset Link',
              onPressed: () {
                // Show snackbar or dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Reset link sent! Check your email.'),
                  ),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 100), // Spacing for balance
          ],
        ),
      ),
    );
  }
}
