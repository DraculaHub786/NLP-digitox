import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';
import 'package:nlp_digitox/features/onboarding/quiz.dart';
import 'package:nlp_digitox/ui/screens/achievements/achievements_screen.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class TabAccount extends ConsumerStatefulWidget {
  const TabAccount({super.key});

  @override
  ConsumerState<TabAccount> createState() => _TabAccountState();
}

class _TabAccountState extends ConsumerState<TabAccount> {
  final _authService = FirebaseAuthService.instance;
  String? _profileUrl;
  bool _isUploading = false;
  bool _isEmailVerified = false;
  bool _isSendingVerification = false;

  @override
  void initState() {
    super.initState();
    _loadProfilePic();
    _checkEmailVerification();
  }

  void _checkEmailVerification() {
    final user = _authService.currentUser;
    if (user != null) {
      _isEmailVerified = user.emailVerified;
    }
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

  Future<void> _sendVerificationEmail() async {
    setState(() => _isSendingVerification = true);
    try {
      final sent = await _authService.sendEmailVerification();
      if (mounted) {
        if (sent) {
          context.showSnackAlert('Verification email sent! Check your inbox.');
        } else {
          context.showSnackAlert('Email is already verified.');
          setState(() => _isEmailVerified = true);
        }
      }
    } catch (e) {
      if (mounted) {
        context.showSnackAlert('Failed to send: ${e.toString().replaceAll('Exception: ', '')}');
      }
    } finally {
      if (mounted) setState(() => _isSendingVerification = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

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
              ),

              /// Email Verification Banner (soft reminder, not a hard block)
              if (!_isEmailVerified) ...[
                12.vBox,
                _buildEmailVerificationBanner(colorScheme),
              ],

              20.vBox,

              /// Profile Picture Management
              _buildProfileSection(colorScheme),

              20.vBox,

              /// Account Actions Card
              _buildResponsiveCard(
                colorScheme: colorScheme,
                icon: FluentIcons.person_settings_20_regular,
                iconColor: colorScheme.primary,
                title: 'Account Actions',
                children: [
                  ModernListTile(
                    title: 'Change Password',
                    subtitle: 'Update your account password',
                    icon: FluentIcons.lock_closed_20_regular,
                    iconColor: colorScheme.primary,
                    onTap: () => _showChangePasswordDialog(),
                  ),
                  8.vBox,
                  ModernListTile(
                    title: 'Change Email',
                    subtitle: 'Update your email address',
                    icon: FluentIcons.mail_20_regular,
                    iconColor: colorScheme.secondary,
                    onTap: () => _showChangeEmailDialog(),
                  ),
                  8.vBox,
                  ModernListTile(
                    title: 'Change Display Name',
                    subtitle: 'Update your profile name',
                    icon: FluentIcons.person_edit_20_regular,
                    iconColor: colorScheme.tertiary,
                    onTap: () => _showChangeNameDialog(),
                  ),
                  8.vBox,
                  ModernListTile(
                    title: 'Achievements',
                    subtitle: 'View points, badges, and streaks',
                    icon: FluentIcons.trophy_20_regular,
                    iconColor: colorScheme.primary,
                    showChevron: true,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const AchievementsScreen(),
                      ),
                    ),
                  ),
                ],
              ),

              20.vBox,

              /// Digital Profile Card — retake quiz
              _buildResponsiveCard(
                colorScheme: colorScheme,
                icon: FluentIcons.person_feedback_20_regular,
                iconColor: colorScheme.primary,
                title: 'Digital Profile',
                children: [
                  ModernListTile(
                    title: 'Update My Digital Profile',
                    subtitle: 'Retake the quiz to improve AI personalization',
                    icon: FluentIcons.person_feedback_20_regular,
                    iconColor: colorScheme.primary,
                    showChevron: true,
                    onTap: () => _openQuiz(),
                  ),
                ],
              ),

              20.vBox,

              /// Data Management Card
              _buildResponsiveCard(
                colorScheme: colorScheme,
                icon: FluentIcons.data_bar_vertical_20_regular,
                iconColor: colorScheme.primary,
                title: 'Data Management',
                children: [
                  ModernListTile(
                    title: 'Export My Data',
                    subtitle: 'Download all your data (GDPR)',
                    icon: FluentIcons.arrow_download_20_regular,
                    iconColor: colorScheme.secondary,
                    showChevron: true,
                    onTap: () => _exportUserData(),
                  ),
                ],
              ),

              20.vBox,

              /// Danger Zone Card
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(Radii.xl),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            FluentIcons.warning_20_filled,
                            color: colorScheme.error,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          StyledText(
                            'Danger Zone',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: colorScheme.error,
                          ),
                        ],
                      ),
                    ),
                    ModernListTile(
                      title: 'Sign Out',
                      subtitle: 'Log out of your account',
                      icon: FluentIcons.sign_out_20_regular,
                      iconColor: colorScheme.primary,
                      showChevron: false,
                      onTap: () => _signOut(),
                    ),
                    8.vBox,
                    ModernListTile(
                      title: 'Delete Account',
                      subtitle: 'Permanently delete your account and data',
                      icon: FluentIcons.delete_20_regular,
                      iconColor: colorScheme.error,
                      showChevron: false,
                      onTap: () => _showDeleteAccountDialog(),
                    ),
                  ],
                ),
              ),

              40.vBox,
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(String? name, String? email, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20.0),
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
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
                        color: colorScheme.scrim.withValues(alpha: 0.5),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colorScheme.onPrimary,
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

  Widget _buildEmailVerificationBanner(ColorScheme colorScheme) {
    final warn = DesignPalette.gold;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: warn.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: warn.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(
            FluentIcons.mail_unread_20_filled,
            color: warn,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                StyledText(
                  'Email not verified',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: warn,
                ),
                const SizedBox(height: 2),
                StyledText(
                  'Please verify your email to secure your account.',
                  fontSize: 11,
                  color: warn.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            height: 32,
            child: FilledButton.tonal(
              onPressed: _isSendingVerification ? null : _sendVerificationEmail,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                backgroundColor: warn.withValues(alpha: 0.2),
                foregroundColor: warn,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
              child: _isSendingVerification
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 1.5),
                    )
                  : StyledText(
                      'Verify',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSection(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: Icon(
                  FluentIcons.image_20_regular,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      'Profile Picture',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    StyledText(
                      'Upload a photo to personalize your profile',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 280;
              final avatarSize = isNarrow ? 48.0 : 64.0;
              // For narrow screens, switch to vertical layout
              if (isNarrow) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: _ProfilePicWidget(
                        size: avatarSize,
                        profileUrl: _profileUrl,
                        isLoading: _isUploading,
                      ),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _isUploading ? null : _uploadProfilePic,
                      icon: _isUploading
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: colorScheme.onPrimary,
                              ),
                            )
                          : const Icon(FluentIcons.image_add_20_filled),
                      label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
                    ),
                    if (_profileUrl != null && _profileUrl!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _isUploading ? null : _removeProfilePic,
                        icon: const Icon(FluentIcons.delete_20_regular),
                        label: const Text('Remove Photo'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: constraints.maxWidth < 200 ? 8 : 0),
                    child: _ProfilePicWidget(
                      size: avatarSize,
                      profileUrl: _profileUrl,
                      isLoading: _isUploading,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        FilledButton.icon(
                          onPressed: _isUploading ? null : _uploadProfilePic,
                          icon: _isUploading
                              ? SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : const Icon(FluentIcons.image_add_20_filled),
                          label: Text(_isUploading ? 'Uploading...' : 'Upload Photo'),
                        ),
                        if (_profileUrl != null && _profileUrl!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: _isUploading ? null : _removeProfilePic,
                            icon: const Icon(FluentIcons.delete_20_regular),
                            label: const Text('Remove Photo'),
                            style: TextButton.styleFrom(
                              foregroundColor: colorScheme.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Reusable responsive card builder that avoids overflow by using compact padding.
  Widget _buildResponsiveCard({
    required ColorScheme colorScheme,
    required IconData icon,
    required Color iconColor,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(Radii.xl),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StyledText(
                    title,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OnboardingQuizPage(
          onComplete: () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile updated! AI will now adapt to your new answers.')),
            );
          },
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
                  borderRadius: BorderRadius.circular(Radii.pill),
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
                    color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(Radii.pill),
                  ),
                  child: Icon(
                    FluentIcons.delete_20_regular,
                    color: Theme.of(context).colorScheme.error,
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
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
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

  // --- ALL DIALOG METHODS REMAIN EXACTLY THE SAME ---

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
            Icon(
              FluentIcons.warning_20_filled,
              color: Theme.of(context).colorScheme.error,
            ),
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
              backgroundColor: Theme.of(context).colorScheme.error,
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
