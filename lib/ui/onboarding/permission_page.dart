// Copyright (c) 2024 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key});

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  bool _isRequesting = false;
  bool _hasAutoRequestedOnce = false;

  @override
  void initState() {
    super.initState();
    // Auto-request all permissions after short delay on first view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasAutoRequestedOnce) {
        _hasAutoRequestedOnce = true;
        Future.delayed(const Duration(milliseconds: 800), () {
          if (mounted) {
            final permissionsNotifier = ref.read(permissionProvider.notifier);
            _requestAllPermissions(permissionsNotifier);
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionProvider);
    final permissionsNotifier = ref.read(permissionProvider.notifier);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Illustration — same AspectRatio + Image.asset pattern as OnboardingPage
            AspectRatio(
              aspectRatio: 1.2,
              child: Image.asset(
                "assets/illustrations/onboarding_4.png",
                fit: BoxFit.contain,
              ),
            ),
            16.vBox,
            StyledText(
              'Essential Permissions.',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              textAlign: TextAlign.center,
              color: Theme.of(context).colorScheme.primary,
            ),
            8.vBox,
            StyledText(
              'NLP digitox requires following essential permissions to track and manage your screen time, helping reduce distractions and improve focus.',
              fontSize: 14,
              color: Theme.of(context).hintColor,
              textAlign: TextAlign.center,
            ),
            24.vBox,
            _buildPermissionItem(
              context,
              icon: Icons.notifications,
              title: 'Notifications',
              description: 'Send reminders and focus alerts',
              isGranted: permissions.haveNotificationPermission,
              onTap: () => _requestPermission(
                permissionsNotifier.askNotificationPermission,
                'Notification',
              ),
            ),
            _buildPermissionItem(
              context,
              icon: Icons.accessibility,
              title: 'Accessibility',
              description: 'Monitor and restrict app usage',
              isGranted: permissions.haveAccessibilityPermission,
              onTap: () => _requestPermission(
                permissionsNotifier.askAccessibilityPermission,
                'Accessibility',
              ),
            ),
            _buildPermissionItem(
              context,
              icon: Icons.bar_chart,
              title: 'Usage Stats',
              description: 'Track screen time and app usage',
              isGranted: permissions.haveUsageAccessPermission,
              onTap: () => _requestPermission(
                permissionsNotifier.askUsageAccessPermission,
                'Usage Access',
              ),
            ),
            _buildPermissionItem(
              context,
              icon: Icons.layers,
              title: 'Display Overlay',
              description: 'Show restriction overlays',
              isGranted: permissions.haveDisplayOverlayPermission,
              onTap: () => _requestPermission(
                permissionsNotifier.askDisplayOverlayPermission,
                'Display Overlay',
              ),
            ),
            const SizedBox(height: 24),
            if (_isRequesting)
              const CircularProgressIndicator()
            else
              ElevatedButton(
                onPressed: () => _requestAllPermissions(permissionsNotifier),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: const Text(
                  'Grant All Permissions',
                  style: TextStyle(fontSize: 16),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required bool isGranted,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: isGranted ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isGranted
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGranted ? Colors.green : Colors.grey,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isGranted ? Colors.green : Colors.grey,
              size: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isGranted)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              )
            else
              const Icon(
                Icons.touch_app,
                color: Colors.blue,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _requestPermission(
    Future<void> Function() requestFn,
    String permissionName,
  ) async {
    setState(() => _isRequesting = true);
    
    try {
      await requestFn();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$permissionName permission requested. Please grant it in settings.'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      
      // Refresh permission status
      await Future.delayed(const Duration(milliseconds: 500));
      ref.read(permissionProvider.notifier).fetchPermissionsStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting $permissionName: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  Future<void> _requestAllPermissions(PermissionNotifier notifier) async {
    setState(() => _isRequesting = true);
    
    try {
      await notifier.requestAllCriticalPermissions();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All permissions requested. Please grant them in the settings that open.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
      
      // Refresh after user returns from settings
      await Future.delayed(const Duration(seconds: 2));
      ref.read(permissionProvider.notifier).fetchPermissionsStatus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permissions: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isRequesting = false);
    }
  }
}
