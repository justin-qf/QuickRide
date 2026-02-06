import 'package:flutter/material.dart';
import 'package:quickride/core/constants/app_theme.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Wallet', style: TextStyle(fontFamily: 'fontBold')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFF8E53)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Available Balance',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '\$450.00',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontFamily: 'fontBold',
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      _buildActionBtn(Icons.add_rounded, 'Add Money'),
                      const SizedBox(width: 16),
                      _buildActionBtn(Icons.send_rounded, 'Send'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Recent Transactions', style: AppTextStyles.heading3),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.grey[100],
                      child: Icon(
                        index == 0
                            ? Icons.directions_bike_rounded
                            : Icons.add_circle_outline,
                        color: index == 0 ? Colors.red : Colors.green,
                      ),
                    ),
                    title: Text(
                      index == 0 ? 'Ride #1234' : 'Added to Wallet',
                      style: const TextStyle(fontFamily: 'fontSemiBold'),
                    ),
                    subtitle: Text('24 Jan 2024'),
                    trailing: Text(
                      index == 0 ? '-\$12.50' : '+\$50.00',
                      style: TextStyle(
                        fontFamily: 'fontBold',
                        color: index == 0 ? Colors.black : Colors.green,
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'fontSemiBold',
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
