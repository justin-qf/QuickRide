import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quickride/core/constants/app_theme.dart';
import 'package:quickride/features/authentication/presentation/widgets/auth_widgets.dart';
import 'package:quickride/core/utils/dialog_utils.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:quickride/core/providers/auth_provider.dart';
import 'package:quickride/core/services/local_storage_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController =
      TextEditingController(); // Bio not in model but user requested
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider);
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _phoneController.text = user.phone;
      }
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  void _showImagePicker() {
    DialogUtils.showImageSourceSelectionSheet(
      context,
      onCamera: () => _pickImage(ImageSource.camera),
      onGallery: () => _pickImage(ImageSource.gallery),
    );
  }

  Future<void> _saveProfile() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final updatedData = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        // profileImage handling would go here (uploading to Firebase Storage)
        // For now, we'll just update the other fields
      };

      final authService = ref.read(authServiceProvider);
      await authService.updateUserData(user.id, updatedData);

      // Update local state
      final updatedUser = user.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );
      ref.read(currentUserProvider.notifier).state = updatedUser;

      // Save to local storage
      final localStorage = LocalStorageService();
      await localStorage.saveUserData(updatedUser.toJson());

      if (mounted) {
        DialogUtils.showSuccessBottomSheet(
          context,
          title: 'Success!',
          message: 'Profile Updated!',
          onDismiss: () => Navigator.pop(context),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to update profile: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Edit Profile',
          style: TextStyle(color: Colors.black, fontFamily: 'fontBold'),
        ),
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        leading: BackButton(
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary, width: 2),
                      image: DecorationImage(
                        image: _imageFile != null
                            ? FileImage(_imageFile!) as ImageProvider
                            : (user?.profileImage != null
                                  ? NetworkImage(user!.profileImage!)
                                  : const NetworkImage(
                                      'https://i.pravatar.cc/300',
                                    )),
                        fit: BoxFit.cover,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: _showImagePicker,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
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
              // enabled: false, // Email usually cannot be changed easily
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _phoneController,
              hintText: 'Phone Number',
              prefixIcon: Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _bioController,
              hintText: 'Bio',
              prefixIcon: Icons.info_outline,
            ),
            const SizedBox(height: 40),
            _isLoading
                ? const CircularProgressIndicator(color: AppColors.primary)
                : CustomButton(text: 'Save Changes', onPressed: _saveProfile),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }
}
