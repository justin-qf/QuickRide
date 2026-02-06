import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/core/utils/helper.dart';
import 'package:quickride/features/profile/presentation/pages/change_password_screen.dart';
import 'package:quickride/features/profile/presentation/pages/edit_profile_screen.dart';
import 'package:quickride/features/authentication/presentation/pages/login_screen.dart';
import 'package:quickride/core/utils/dialog_utils.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:quickride/features/profile/presentation/pages/help_support_screen.dart';
import 'package:quickride/core/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  String _version = '1.0.0';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _version = '${info.version} (${info.buildNumber})';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontFamily: 'fontBold', color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 5),
            // Profile Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: DecorationImage(
                        image: user?.profileImage != null
                            ? NetworkImage(user!.profileImage!)
                            : const NetworkImage('https://i.pravatar.cc/300'),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          (user?.name ?? 'User').capitalizeFirst(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontFamily: 'fontBold',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          user?.email ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          user?.phone ?? '',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.mode_edit_outline_rounded,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'My Account',
                  style: AppTextStyles.heading2.copyWith(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // List Items
            _buildProfileTile(Icons.person_outline, 'Edit Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );
            }),
            _buildProfileTile(Icons.lock_outline, 'Change Password', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChangePasswordScreen(),
                ),
              );
            }),
            _buildProfileTile(
              Icons.policy_outlined,
              'Privacy Policy',
              () async {
                final Uri url = Uri.parse('https://google.com');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
            ),
            _buildProfileTile(Icons.help_outline_rounded, 'Help & Support', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HelpSupportScreen(),
                ),
              );
            }),
            _buildProfileTile(Icons.logout, 'Log Out', () {
              DialogUtils.showConfirmationBottomSheet(
                context,
                title: 'Log Out',
                message: 'Are you sure you want to log out?',
                confirmText: 'Log Out',
                isDestructive: true,
                onConfirm: () async {
                  await ref.read(authServiceProvider).signOut();
                  if (context.mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                      (route) => false,
                    );
                  }
                },
              );
            }, isDestructive: true),
            _buildProfileTile(Icons.delete_outline, 'Delete Account', () {
              DialogUtils.showConfirmationBottomSheet(
                context,
                title: 'Delete Account',
                message:
                    'Are you sure you want to delete your account? This action cannot be undone.',
                confirmText: 'Delete',
                isDestructive: true,
                onConfirm: () {
                  // Implement delete account logic
                  DialogUtils.showSuccessBottomSheet(
                    context,
                    title: 'Account Deleted',
                    message: 'Your account has been successfully deleted.',
                    onDismiss: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                        (route) => false,
                      );
                    },
                  );
                },
              );
            }, isDestructive: true),

            const SizedBox(height: 30),
            Text(
              'Version $_version',
              style: TextStyle(color: Colors.grey[400]),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withOpacity(0.1)
                : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : AppColors.primary,
            size: 20,
          ),
        ),
        title: Text(title, style: const TextStyle(fontFamily: 'fontSemiBold')),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
    );
  }
}
