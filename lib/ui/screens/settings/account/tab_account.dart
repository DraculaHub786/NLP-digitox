// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/firestore_service.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class TabAccount extends ConsumerStatefulWidget {
  const TabAccount({super.key});

  @override
  ConsumerState<TabAccount> createState() => _TabAccountState();
}

class _TabAccountState extends ConsumerState<TabAccount> {
  final _authService = FirebaseAuthService.instance;

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverList(
          delegate: SliverChildListDelegate(
            [
              /// User Info Section
              _buildUserInfoCard(user?.displayName, user?.email),

              SizedBox(height: 20.0),

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

              SizedBox(height: 20.0),

              /// Data Management
              DefaultListTile(
                leadingIcon: FluentIcons.arrow_download_20_regular,
                titleText: 'Export My Data',
                subtitleText: 'Download all your data (GDPR)',
                onPressed: () => _exportUserData(),
              ),

              SizedBox(height: 40.0),

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

              SizedBox(height: 40.0),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(String? name, String? email) {
    return Container(
      margin: EdgeInsets.all(20.0),
      padding: EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          /// Avatar
          CircleAvatar(
            radius: 32.0,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              FluentIcons.person_24_filled,
              size: 32.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          SizedBox(width: 16.0),

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
                SizedBox(height: 4.0),
                StyledText(
                  email ?? 'No email',
                  fontSize: 14,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(
            FluentIcons.warning_20_filled,
            color: Colors.red,
            size: 20.0,
          ),
          SizedBox(width: 8.0),
          StyledText(
            'Danger Zone',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  /// Change Password Dialog
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
            SizedBox(height: 12.0),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New Password',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12.0),
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

  /// Change Email Dialog
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
            SizedBox(height: 12.0),
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

  /// Change Name Dialog
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

  /// Delete Account Confirmation Dialog
  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(FluentIcons.warning_20_filled, color: Colors.red),
            SizedBox(width: 8.0),
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
              _showDeleteAccountPasswordDialog();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete Account Password Dialog
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
            SizedBox(height: 12.0),
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

  /// Change Password
  Future<void> _changePassword(String currentPassword, String newPassword) async {
    

    try {
      // Reauthenticate first
      await _authService.reauthenticate(currentPassword);
      await _authService.updatePassword(newPassword);
      if (mounted) {
        context.showSnackAlert('Password updated successfully');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      
    }
  }

  /// Change Email
  Future<void> _changeEmail(String newEmail, String password) async {
    

    try {
      // Reauthenticate first
      await _authService.reauthenticate(password);
      await _authService.updateEmail(newEmail);
      if (mounted) {
        context.showSnackAlert('Email updated successfully');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      
    }
  }

  /// Change Name
  Future<void> _changeName(String newName) async {
    

    try {
      await _authService.updateDisplayName(newName);
      if (mounted) {
        context.showSnackAlert('Display name updated successfully');
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      
    }
  }

  /// Export User Data
  Future<void> _exportUserData() async {
    

    try {
      final data = await FirestoreService.instance.exportUserData();
      
      // TODO: Save to file or share
      // For now, just show success message
      if (mounted) {
        context.showSnackAlert('Data exported: ${data.length} characters');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      
    }
  }

  /// Sign Out
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
    } finally {
      
    }
  }

  /// Delete Account
  Future<void> _deleteAccount(String password) async {
    

    try {
      // Reauthenticate first
      await _authService.reauthenticate(password);
      
      // Delete user data from Firestore
      await FirestoreService.instance.deleteUserData();

      // Delete Firebase Auth account
      await _authService.deleteAccount();

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.loginPath,
          (route) => false,
        );
        context.showSnackAlert('Account deleted successfully');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      
    }
  }

  /// Show Error
  void _showError(String message) {
    if (mounted) {
      context.showSnackAlert(message);
    }
  }
}
