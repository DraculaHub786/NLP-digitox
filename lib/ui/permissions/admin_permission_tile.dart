import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/permissions/accessibility_permission_card.dart';
import 'package:nlp_digitox/ui/permissions/permission_sheet.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

/// Tile that toggles tamper protection (Android Device Admin).
///
/// While active, the app cannot be uninstalled or force-stopped from Settings
/// outside the configured uninstall window, and the accessibility service
/// blocks access to the device-admin list itself (so it cannot be silently
/// revoked behind the user's back).
class AdminPermissionTile extends ConsumerWidget {
  const AdminPermissionTile({super.key});

  /// Handles the toggle. `isAdminEnabled` is the current switch state — the
  /// user is asking to move to its opposite.
  Future<void> _toggleTamperProtection(
    BuildContext context,
    WidgetRef ref,
    bool isAdminEnabled,
  ) async {
    /// Device Admin cannot do anything useful without the accessibility
    /// service (that is what actually blocks the Settings screen), so ask
    /// for it first when it is missing.
    if (!ref.read(permissionProvider).haveAccessibilityPermission) {
      const AccessibilityPermissionCard()
          .showAccessibilityPermissionSheet(context, ref);
      return;
    }

    if (isAdminEnabled) {
      /// User wants to disable — only allowed inside the uninstall window.
      if (ref
          .read(parentalControlsProvider.notifier)
          .isBetweenUninstallWindow) {
        await ref.read(permissionProvider.notifier).disableAdminPermission();
      } else {
        context.showSnackAlert(
          context.locale.permission_admin_snack_alert,
          icon: FluentIcons.shield_keyhole_20_filled,
        );
      }
      return;
    }

    /// User wants to enable — confirm first, then show the grant sheet.
    final isConfirm = await showConfirmationDialog(
      context: context,
      heroTag: HeroTags.tamperProtectionTileTag,
      icon: FluentIcons.shield_keyhole_20_filled,
      title: context.locale.tamper_protection_tile_title,
      info: context.locale.tamper_protection_confirmation_dialog_info,
      positiveLabel: context.locale.permission_button_grant_permission,
    );

    await Future.delayed(400.ms);
    if (!isConfirm || !context.mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => PermissionSheet(
        icon: FluentIcons.shield_keyhole_20_filled,
        title: context.locale.permission_admin_title,
        description: context.locale.permission_admin_info,
        onTapGrantPermission: () {
          Navigator.of(sheetContext).maybePop();
          ref.read(permissionProvider.notifier).askAdminPermission();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final haveAdminPermission =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));
    final haveAccessibilityPermission = ref
        .watch(permissionProvider.select((v) => v.haveAccessibilityPermission));
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultHero(
      tag: HeroTags.tamperProtectionTileTag,
      child: ModernSettingsTile(
        title: context.locale.tamper_protection_tile_title,
        subtitle: context.locale.tamper_protection_tile_subtitle,
        icon: FluentIcons.shield_keyhole_20_regular,
        iconColor: colorScheme.primary,
        value: haveAdminPermission && haveAccessibilityPermission,
        onChanged: (_) =>
            _toggleTamperProtection(context, ref, haveAdminPermission),
      ),
    );
  }
}
