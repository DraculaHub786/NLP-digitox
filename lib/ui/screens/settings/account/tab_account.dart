
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';
import 'package:nlp_digitox/ui/screens/achievements/achievements_screen.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/greetings_username.dart';

class TabAccount extends ConsumerStatefulWidget {
  const TabAccount({super.key});

  @override
  ConsumerState<TabAccount> createState() => _TabAccountState();
}

class _TabAccountState extends ConsumerState<TabAccount> {
  final _authService = FirebaseAuthService.instance;
  String? _profileUrl;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
  }

  Future<void> _loadProfilePic() async {
    try {
      final url = await ProfileService.instance.getProfileUrl();
      if (mounted) {
        setState(() {
          _profileUrl = url;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile pic: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              /// User Info Section with Profile Pic
              _buildUserInfoCard(
                user?.displayName,
                user?.email,
                colorScheme,
                isDark,
              ),

              const SizedBox(height: 20),

              /// Profile Picture Management
              _buildProfileSection(colorScheme, isDark),

              const SizedBox(height: 20),

              /// Account Actions
              DefaultListTile(
                leadingIcon: FluentIcons.lock_closed_20_regular,
                titleText: 'Change Password',
                subtitleText: 'Update your account password',
                onPressed: () => _showChangePasswordDialog(),
              ),

              DefaultListTile(
                leadingIcon: FluentIcons.mail_20_regular,
                titleText: 'Change Email',
                subtitleText: 'Update your email address',
                onPressed: () => _showChangeEmailDialog(),
              ),

              DefaultListTile(
                leadingIcon: FluentIcons.person_edit_20_regular,
                titleText: 'Change Display Name',
                subtitleText: 'Update your profile name',
                onPressed: () => _showChangeNameDialog(),
              ),

              DefaultListTile(
                leadingIcon: FluentIcons.trophy_20_regular,
                titleText: 'Achievements',
                subtitleText: 'View points, badges, and streaks',
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const AchievementsScreen(),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// Data Management
              DefaultListTile(
                leadingIcon: FluentIcons.arrow_download_20_regular,
                titleText: 'Export My Data',
                subtitleText: 'Download all your data (GDPR)',
                onPressed: () => _exportUserData(),
              ),

              const SizedBox(height: 40),

              /// Danger Zone
              _buildDangerZoneHeader(),

              DefaultListTile(
                leadingIcon: FluentIcons.sign_out_20_regular,
                titleText: 'Sign Out',
                subtitleText: 'Log out of your account',
                color: Colors.blue,
                onPressed: () => _signOut(),
              ),

              DefaultListTile(
                leadingIcon: FluentIcons.delete_20_regular,
                titleText: 'Delete Account',
                subtitleText: 'Permanently delete your account and data',
                color: Colors.red,
                onPressed: () => _showDeleteAccountDialog(),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(String? name, String? email, ColorScheme colorScheme, bool isDark) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black : Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Avatar with profile pic
          GestureDetector(
            onTap: _isUploading ? null : _showProfileOptions,
            child: Stack(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primaryContainer,
                  ),
                  child: ClipOval(
                    child: _profileUrl != null && _profileUrl!.isNotEmpty
                        ? Image.network(
                            _profileUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildDefaultAvatar(colorScheme),
                          )
                        : _buildDefaultAvatar(colorScheme),
                  ),
                ),
                if (_isUploading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      FluentIcons.camera_16_filled,
                      size: 12,
                      color: colorScheme.onPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          /// User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  name ?? 'User',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 4),
                StyledText(
                  email ?? 'No email',
                  fontSize: 14,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        FluentIcons.person_24_filled,
        size: 32,
        color: colorScheme.primary,
      ),
    );
  }

  Widget _buildProfileSection(ColorScheme colorScheme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledText(
              'Profile Picture',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 4),
            StyledText(
              'Upload a photo to personalize your profile',
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ProfilePicWidget(
                    size: 80,
                    profileUrl: _profileUrl,
                    isLoading: _isUploading,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isUploading ? null : _uploadProfilePic,
                          icon: _isUploading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(FluentIcons.image_add_20_filled),
                          label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
                        ),
                      ),
                      if (_profileUrl != null && _profileUrl!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: TextButton.icon(
                            onPressed: _isUploading ? null : _removeProfilePic,
                            icon: const Icon(FluentIcons.delete_20_regular),
                            label: const Text('Remove Photo'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showProfileOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StyledText(
              'Profile Photo',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FluentIcons.image_add_20_regular,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              title: const Text('Upload Photo'),
              subtitle: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _uploadProfilePic();
              },
            ),
            if (_profileUrl != null && _profileUrl!.isNotEmpty)
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    FluentIcons.delete_20_regular,
                    color: Colors.red,
                  ),
                ),
                title: const Text('Remove Photo'),
                subtitle: const Text('Delete current photo'),
                onTap: () {
                  Navigator.pop(context);
                  _removeProfilePic();
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _uploadProfilePic() async {
    setState(() {
      _isUploading = true;
    });

    try {
      final url = await ProfileService.instance.uploadProfilePicture();
      if (mounted) {
        setState(() {
          _profileUrl = url;
        });
        context.showSnackAlert('Profile photo updated successfully!');
      }
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Failed to upload photo: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  Future<void> _removeProfilePic() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo?'),
        content: const Text('Are you sure you want to remove your profile photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ProfileService.instance.removeProfilePicture();
        if (mounted) {
          setState(() {
            _profileUrl = null;
          });
          context.showSnackAlert('Profile photo removed');
        }
      } catch (e) {
        if (mounted) {
          context.showSnackAlert('Failed to remove photo: ${e.toString()}');
        }
      }
    }
  }

  Widget _buildDangerZoneHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          const Icon(
            FluentIcons.warning_20_filled,
            color: Colors.red,
            size: 20.0,
          ),
          const SizedBox(width: 8.0),
          const StyledText(
            'Danger Zone',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                _showError('Passwords do not match');
                return;
              }

              Navigator.pop(context);
              await _changePassword(
                currentPasswordController.text,
                newPasswordController.text,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangeEmailDialog() {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Email'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'New Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changeEmail(
                emailController.text,
                passwordController.text,
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showChangeNameDialog() {
    final nameController = TextEditingController(
      text: _authService.currentUser?.displayName,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Display Name'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            labelText: 'Display Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context);
              await _changeName(nameController.text);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    final isGoogleUser = _authService.isSignedInWithGoogle();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(FluentIcons.warning_20_filled, color: Colors.red),
            const SizedBox(width: 8.0),
            const Text('Delete Account?'),
          ],
        ),
        content: const Text(
          'This action cannot be undone. All your data will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (isGoogleUser) {
                _deleteGoogleAccount();
              } else {
                _showDeleteAccountPasswordDialog();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountPasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your password to delete your account'),
            const SizedBox(height: 12.0),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () async {
              Navigator.pop(context);
              await _deleteAccount(passwordController.text);
            },
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    try {
      await _authService.reauthenticate(currentPassword);
      await _authService.updatePassword(newPassword);
      if (mounted) {
        context.showSnackAlert('Password updated successfully');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _changeEmail(String newEmail, String password) async {
    try {
      await _authService.reauthenticate(password);
      await _authService.updateEmail(newEmail);
      if (mounted) {
        context.showSnackAlert('Email updated successfully');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _changeName(String newName) async {
    try {
      await _authService.updateDisplayName(newName);
      if (mounted) {
        context.showSnackAlert('Display name updated successfully');
        setState(() {});
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _exportUserData() async {
    try {
      final data = await FirestoreService.instance.exportUserData();
      if (mounted) {
        context.showSnackAlert('Data exported: ${data.length} characters');
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginPath,
          (route) => false,
        );
      }
    } catch (e) {
      _showError(e.toString());
    }
  }

  Future<void> _deleteAccount(String password) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      await _authService.reauthenticate(password);
      await FirestoreService.instance.deleteUserData();
      await _authService.deleteAccount();

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginPath,
          (route) => false,
        );
        context.showSnackAlert('Account deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  Future<void> _deleteGoogleAccount() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Please sign in with Google to confirm...'),
            ],
          ),
        ),
      );

      await _authService.reauthenticateWithGoogle();
      await FirestoreService.instance.deleteUserData();
      await _authService.deleteAccount();

      if (mounted) {
        Navigator.pop(context);
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginPath,
          (route) => false,
        );
        context.showSnackAlert('Account deleted successfully');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        _showError(e.toString().replaceAll('Exception: ', ''));
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      context.showSnackAlert(message);
    }
  }
}

/// Profile pic widget for account screen
class _ProfilePicWidget extends StatelessWidget {
  final double size;
  final String? profileUrl;
  final bool isLoading;

  const _ProfilePicWidget({
    required this.size,
    this.profileUrl,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (isLoading) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primaryContainer,
        ),
        child: Center(
          child: SizedBox(
            width: size * 0.5,
            height: size * 0.5,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    if (profileUrl != null && profileUrl!.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          profileUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildDefaultAvatar(colorScheme),
        ),
      );
    }

    return _buildDefaultAvatar(colorScheme);
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primaryContainer,
      ),
      child: Icon(
        FluentIcons.person_24_filled,
        size: size * 0.5,
        color: colorScheme.primary,
      ),
    );
  }
}