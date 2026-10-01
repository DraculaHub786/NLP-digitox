// Copyright (c) 2026 NLP digitox

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/models/permissions_model.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// The essential-permission screen.
///
/// Two rules make this safe on a cold start:
///  1. It never opens a system settings screen by itself. The old version
///     auto-requested *every* permission 800 ms after the page was built, so a
///     returning user whose permissions were fine still got dumped into
///     Accessibility / Usage-access / Overlay settings on every launch.
///  2. The "grant" action only walks the permissions that are actually
///     missing, in the order they are listed here.
class PermissionsPage extends ConsumerStatefulWidget {
  const PermissionsPage({super.key, this.onSkip});

  /// Optional escape hatch shown as "Not Now".
  ///
  /// Used by the recovery flow, where the user is already onboarded and must
  /// be able to get back into the app even if they cannot grant something
  /// right now — otherwise a revoked permission would lock them out.
  final VoidCallback? onSkip;

  @override
  ConsumerState<PermissionsPage> createState() => _PermissionsPageState();
}

class _PermissionsPageState extends ConsumerState<PermissionsPage> {
  bool _isRequesting = false;

  /// The permissions the app cannot function without, in the order they are
  /// shown — and therefore also the order their settings screens open in.
  List<_PermissionEntry> _entries(PermissionsModel perms) => [
        _PermissionEntry(
          icon: Icons.notifications,
          title: 'Notifications',
          description: 'Send reminders and focus alerts',
          isGranted: perms.haveNotificationPermission,
          request: (notifier) => notifier.askNotificationPermission(),
        ),
        _PermissionEntry(
          icon: Icons.accessibility,
          title: 'Accessibility',
          description: 'Monitor and restrict app usage',
          isGranted: perms.haveAccessibilityPermission,
          request: (notifier) => notifier.askAccessibilityPermission(),
        ),
        _PermissionEntry(
          icon: Icons.bar_chart,
          title: 'Usage Stats',
          description: 'Track screen time and app usage',
          isGranted: perms.haveUsageAccessPermission,
          request: (notifier) => notifier.askUsageAccessPermission(),
        ),
        _PermissionEntry(
          icon: Icons.layers,
          title: 'Display Overlay',
          description: 'Show restriction overlays',
          isGranted: perms.haveDisplayOverlayPermission,
          request: (notifier) => notifier.askDisplayOverlayPermission(),
        ),
        _PermissionEntry(
          icon: Icons.alarm,
          title: 'Exact Alarms',
          description: 'Deliver scheduled reminders on time',
          isGranted: perms.haveAlarmsPermission,
          request: (notifier) => notifier.askExactAlarmPermission(),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final permissions = ref.watch(permissionProvider);
    final entries = _entries(permissions);
    final missing =
        entries.where((entry) => !entry.isGranted).toList(growable: false);

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
            for (final entry in entries)
              _buildPermissionItem(
                context,
                icon: entry.icon,
                title: entry.title,
                description: entry.description,
                isGranted: entry.isGranted,
                onTap: () => _requestPermission(
                  () => entry.request(ref.read(permissionProvider.notifier)),
                  entry.title,
                ),
              ),
            const SizedBox(height: 24),
            _buildFooter(missing),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(List<_PermissionEntry> missing) {
    if (_isRequesting) return const CircularProgressIndicator();

    if (missing.isEmpty) {
      return const StyledText(
        'All set — continuing…',
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      );
    }

    return Column(
      children: [
        ElevatedButton(
          onPressed: _requestOnlyMissing,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: Text(
            missing.length == 1
                ? 'Grant ${missing.single.title}'
                : 'Grant ${missing.length} missing permissions',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        8.vBox,
        StyledText(
          missing.length == 1
              ? '${missing.single.title} is required to continue.'
              : '${missing.length} permissions above are required to continue.',
          fontSize: 12,
          color: Theme.of(context).hintColor,
          textAlign: TextAlign.center,
        ),
        if (widget.onSkip != null) ...[
          8.vBox,
          TextButton(
            onPressed: widget.onSkip,
            child: Text(context.locale.permission_button_not_now),
          ),
        ],
      ],
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

  /// Opens the settings screen for a single permission and re-reads state when
  /// the user comes back.
  Future<void> _requestPermission(
    Future<void> Function() requestFn,
    String permissionName,
  ) async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    try {
      await requestFn();

      // Refresh so the row reflects what the user granted on the way back.
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await ref.read(permissionProvider.notifier).fetchPermissionsStatus();
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

  /// Opens the settings screen for each *missing* permission only — never for
  /// one that is already granted.
  Future<void> _requestOnlyMissing() async {
    if (_isRequesting) return;
    setState(() => _isRequesting = true);

    final notifier = ref.read(permissionProvider.notifier);
    final missing = _entries(ref.read(permissionProvider))
        .where((entry) => !entry.isGranted);

    try {
      for (final entry in missing) {
        if (!mounted) return;
        await entry.request(notifier);
        await Future.delayed(const Duration(milliseconds: 400));
      }

      if (!mounted) return;
      await notifier.fetchPermissionsStatus();
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

/// One essential permission, its display data and how to request it.
class _PermissionEntry {
  const _PermissionEntry({
    required this.icon,
    required this.title,
    required this.description,
    required this.isGranted,
    required this.request,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isGranted;
  final Future<void> Function(PermissionNotifier notifier) request;
}
