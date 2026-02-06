import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:quickride/core/utils/dialog_utils.dart';
import 'package:quickride/features/profile/presentation/pages/otp_verification_screen.dart';

class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Change Password',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Enter your new password below.'),
            const SizedBox(height: 30),
            const CustomTextField(
              hintText: 'Old Password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'New Password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 16),
            const CustomTextField(
              hintText: 'Confirm New Password',
              isPassword: true,
              prefixIcon: Icons.lock_outline,
            ),
            const SizedBox(height: 40),
            CustomButton(
              text: 'Update Password',
              onPressed: () async {
                // Open OTP screen first for security
                final verified = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const OtpVerificationScreen(),
                  ),
                );

                if (verified == true && context.mounted) {
                  DialogUtils.showSuccessBottomSheet(
                    context,
                    title: 'Success!',
                    message: 'Password Changed Successfully!',
                    onDismiss: () => Navigator.pop(context),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
