import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/services/permission_state.dart';
import 'package:nlp_digitox/ui/common/sliver_primary_action_container.dart';
import 'package:nlp_digitox/ui/permissions/permission_sheet.dart';

/// Accessibility permission card used by the Shorts / Websites blocking
/// screens. Shows the full permission-onboarding sheet on first launch;
/// after the user has seen it once (Agree & Continue OR Not Now) only a
/// lightweight re-enable banner is shown when the permission is revoked.
class AccessibilityPermissionCard extends ConsumerWidget {
  const AccessibilityPermissionCard({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final permState = ref.watch(permissionProvider);
    final havePermission = permState.haveAccessibilityPermission;
    final isPaused = permState.isAccessibilityServicePaused;
    final onboarded = ref.watch(permissionOnboardedProvider).value ?? false;

    // Show "paused" nudge when permission is granted but service process is dead
    if (havePermission && isPaused) {
      return SliverPrimaryActionContainer(
        isVisible: true,
        margin: const EdgeInsets.symmetric(vertical: 4),
        icon: FluentIcons.accessibility_20_regular,
        title: context.locale.permission_accessibility_title,
        information: 'Shorts blocking is paused — tap to resume',
        positiveBtn: FilledButton.icon(
          icon: const Icon(FluentIcons.play_20_filled, size: 16),
          label: const Text('Resume'),
          onPressed: () {
            // Clear the paused flag; re-check on next heartbeat
            ref
                .read(permissionProvider.notifier)
                .clearAccessibilityServicePausedFlag();
          },
        ),
        // Add a secondary "Re-grant" option too
        negativeBtn: TextButton(
          child: Text(
            context.locale.permission_button_grant_permission,
            style: TextStyle(color: colorScheme.error),
          ),
          onPressed: () => showAccessibilityPermissionSheet(context, ref),
        ),
      );
    }

    if (havePermission) {
      // Permission granted — mark the one-time onboarding as seen so a later
      // revocation goes straight to the lightweight re-enable banner.
      if (!onboarded) {
        _markOnboarded(ref);
      }
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (onboarded) {
      // One-time onboarding already completed → lightweight re-enable banner.
      return SliverPrimaryActionContainer(
        isVisible: true,
        margin: const EdgeInsets.symmetric(vertical: 4),
        icon: Icons.warning_amber_rounded,
        title: context.locale.permission_accessibility_title,
        information:
            'Permission was turned off. Tap Enable to re-enable Shorts blocking.',
        positiveBtn: FilledButton(
          child: Text('Enable'),
          onPressed: () =>
              ref.read(permissionProvider.notifier).askAccessibilityPermission(),
        ),
      );
    }

    // First launch — show the full permission-onboarding flow.
    return SliverPrimaryActionContainer(
      isVisible: true,
      margin: const EdgeInsets.symmetric(vertical: 4),
      icon: FluentIcons.accessibility_20_regular,
      title: context.locale.permission_accessibility_title,
      information: context.locale.permission_accessibility_required,
      positiveBtn: FilledButton(
        child: Text(context.locale.permission_button_grant_permission),
        onPressed: () => showAccessibilityPermissionSheet(context, ref),
      ),
    );
  }

  Future<void> _markOnboarded(WidgetRef ref) async {
    await PermissionState.markOnboardingComplete();
    // Invalidating a provider is safe even if this widget was disposed —
    // it simply marks the value stale for the next read.
    ref.invalidate(permissionOnboardedProvider);
  }

  void showAccessibilityPermissionSheet(
    BuildContext context,
    WidgetRef ref,
  ) {
    // Tapping the primary CTA means the user has seen the flow — never
    // show the full sheet again.
    void completeOnboarding() {
      _markOnboarded(ref);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PermissionSheet(
        icon: FluentIcons.accessibility_20_filled,
        isAccessibilityPerm: true,
        title: context.locale.permission_accessibility_title,
        description: context.locale.permission_accessibility_info,
        deviceSwitchTileLabel:
            context.locale.permission_accessibility_device_tile_label,
        onTapGrantPermission: () {
          Navigator.of(sheetContext).maybePop();
          completeOnboarding();
          ref.read(permissionProvider.notifier).askAccessibilityPermission();
        },
        onNotNow: () => completeOnboarding(),
      ),
    );
  }
}
