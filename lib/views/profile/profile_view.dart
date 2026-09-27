import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../auth/login_view.dart';
import '../favorites/favorites_view.dart';
import '../pantry_ai/pantry_input_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  String? _profileImageUrl;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  // Profile Image Load Logic (Guest -> Local Box, Logged-In -> Supabase User Metadata / Local)
  Future<void> _loadProfileImage() async {
    final authVm = context.read<AuthViewModel>();
    if (authVm.isGuestMode) {
      final box = await Hive.openBox('settingsBox');
      setState(() {
        _profileImageUrl = box.get('guest_profile_image');
      });
    } else {
      final user = authVm.currentUser;
      final avatarUrl = user?.userMetadata?['avatar_url'];
      if (avatarUrl != null && avatarUrl.toString().isNotEmpty) {
        setState(() {
          _profileImageUrl = avatarUrl.toString();
        });
      }
    }
  }

  // Image Pick and Save Handler
  Future<void> _pickAndSaveImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);
      final authVm = context.read<AuthViewModel>();

      if (authVm.isGuestMode) {
        // GUEST MODE: Save file path/URL to local Hive storage
        final box = await Hive.openBox('settingsBox');
        await box.put('guest_profile_image', pickedFile.path);

        setState(() {
          _profileImageUrl = pickedFile.path;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo saved locally!')),
          );
        }
      } else {
        // LOGGED-IN MODE: Upload to Supabase Storage Bucket 'avatars'
        final user = authVm.currentUser;
        if (user == null) return;

        final fileBytes = await pickedFile.readAsBytes();
        final fileExt = pickedFile.name.split('.').last;
        final fileName = '${user.id}_${DateTime.now().millisecondsSinceEpoch}.$fileExt';

        final storage = Supabase.instance.client.storage.from('avatars');

        if (kIsWeb) {
          await storage.uploadBinary(fileName, fileBytes);
        } else {
          await storage.upload(fileName, File(pickedFile.path));
        }

        final String publicUrl = storage.getPublicUrl(fileName);

        // Update Supabase User Metadata
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(data: {'avatar_url': publicUrl}),
        );

        setState(() {
          _profileImageUrl = publicUrl;
          _isUploading = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile photo updated on cloud!')),
          );
        }
      }
    } catch (e) {
      setState(() => _isUploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save image: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final recipeVm = context.watch<RecipeViewModel>();
    final user = authVm.currentUser;
    final isGuest = authVm.isGuestMode;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Avatar Card with Edit Button
            Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                        backgroundImage: _getAvatarImageProvider(),
                        child: (_profileImageUrl == null && !_isUploading)
                            ? Icon(
                          isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
                          size: 55,
                          color: AppColors.primary,
                        )
                            : (_isUploading
                            ? const CircularProgressIndicator(color: AppColors.primary)
                            : null),
                      ),
                      GestureDetector(
                        onTap: _pickAndSaveImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    isGuest ? 'Guest User' : (user?.email?.split('@').first.toUpperCase() ?? 'Foodie'),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGuest ? 'Explore mode enabled' : (user?.email ?? ''),
                    style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Profile Stats Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('Favorites', '${recipeVm.favoriteRecipes.length}'),
                  Container(height: 30, width: 1, color: AppColors.border),
                  _buildStatItem('Diet Plan', 'Standard'),
                  Container(height: 30, width: 1, color: AppColors.border),
                  _buildStatItem('Status', isGuest ? 'Guest' : 'Pro'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Functional Profile Options Menu
            _buildMenuItem(
              icon: Icons.favorite_border_rounded,
              title: 'Saved Recipes',
              subtitle: '${recipeVm.favoriteRecipes.length} recipes saved offline',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FavoritesView()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.kitchen_outlined,
              title: 'Pantry AI Generator',
              subtitle: 'Generate recipes from left-over ingredients',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const PantryInputView()),
                );
              },
            ),
            _buildMenuItem(
              icon: Icons.settings_outlined,
              title: 'Preferences',
              subtitle: 'Dietary restrictions & units',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Preferences feature coming in next update!')),
                );
              },
            ),

            const SizedBox(height: 30),

            // Action Button (Sign In or Sign Out)
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  if (isGuest) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginView()),
                    );
                  } else {
                    await authVm.signOut();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginView()),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGuest ? AppColors.primary : Colors.red[50],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: Icon(
                  isGuest ? Icons.login_rounded : Icons.logout_rounded,
                  color: isGuest ? Colors.white : Colors.red,
                ),
                label: Text(
                  isGuest ? 'Sign In / Register' : 'Sign Out',
                  style: TextStyle(
                    color: isGuest ? Colors.white : Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Image Provider Helper for Web/Network/File
  ImageProvider? _getAvatarImageProvider() {
    if (_profileImageUrl == null) return null;
    if (_profileImageUrl!.startsWith('http')) {
      return NetworkImage(_profileImageUrl!);
    }
    if (!kIsWeb) {
      return FileImage(File(_profileImageUrl!));
    }
    return NetworkImage(_profileImageUrl!);
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.textMuted),
      ),
    );
  }
}