import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:quickride/core/constants/app_theme.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(fontFamily: 'fontBold'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSupportItem(
              Icons.chat_bubble_outline_rounded,
              'Chat with us',
              'Our team is here to help you 24/7',
            ),
            _buildSupportItem(
              Icons.email_outlined,
              'Email Support',
              'Response within 24 hours',
            ),
            _buildSupportItem(
              Icons.phone_enabled_outlined,
              'Call Support',
              'Emergency assistance',
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Frequently Asked Questions',
                style: AppTextStyles.heading3,
              ),
            ),
            const SizedBox(height: 16),
            _buildFaqItem(
              'How to book a ride?',
              'To book a ride, go to home screen, select your destination...',
            ),
            _buildFaqItem(
              'Payment methods',
              'We accept Cards, Wallet, and Cash payments.',
            ),
            _buildFaqItem(
              'Cancellation policy',
              'Cancellations are free within first 2 minutes of booking.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'fontSemiBold',
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildFaqItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontFamily: 'fontSemiBold', fontSize: 14),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            answer,
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
          ),
        ),
      ],
    );
  }
}
