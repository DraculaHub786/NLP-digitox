
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/core/services/auth_service.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/dialogs/time_picker_dialog.dart';
import 'package:nlp_digitox/ui/dialogs/parental_password_management_dialog.dart';
import 'package:nlp_digitox/ui/permissions/admin_permission_tile.dart';
import 'package:nlp_digitox/ui/screens/parental_controls/invincible_mode_settings.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class ParentalControlsScreen extends ConsumerWidget {
  const ParentalControlsScreen({super.key});

  void _toggleProtectedAccess(
    BuildContext context,
    WidgetRef ref,
    bool isAccessProtected,
  ) async {
    try {
      if (!isAccessProtected) {
        final isAuthenticated = await AuthService.instance.authenticate();

        /// Return if not mounted
        if (!context.mounted) return;

        /// If no locks available
        if (isAuthenticated == null) {
          context.showSnackAlert(
            context.locale.protected_access_no_lock_snack_alert,
            icon: FluentIcons.fingerprint_20_filled,
          );
          return;
        }

        /// If aborted the auth
        if (!isAuthenticated) {
          context.showSnackAlert(
            context.locale.protected_access_failed_lock_snack_alert,
            icon: FluentIcons.fingerprint_20_filled,
          );

          return;
        }
      }

      ref.read(parentalControlsProvider.notifier).switchProtectedAccess();
    } catch (e) {
      debugPrint("Failed to authenticate: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentalControls = ref.watch(parentalControlsProvider);
    final isAdminEnabled =
        ref.watch(permissionProvider.select((v) => v.haveAdminPermission));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.shield_keyhole_20_regular,
          filledIcon: FluentIcons.shield_keyhole_20_filled,
          titleText: context.locale.parental_controls_tab_title,
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              /// Invincible mode
              const InvincibleModeSettings(),

              /// Parental controls
              ContentSectionHeader(
                title: context.locale.parental_controls_tab_title,
              ).sliver,

              /// Protected access
              DefaultListTile(
                position: ItemPosition.top,
                switchValue: parentalControls.protectedAccess,
                leadingIcon: FluentIcons.fingerprint_20_regular,
                titleText: context.locale.protected_access_tile_title,
                subtitleText: context.locale.protected_access_tile_subtitle,
                onPressed: () => _toggleProtectedAccess(
                  context,
                  ref,
                  parentalControls.protectedAccess,
                ),
              ).sliver,

              /// Tamper protection
              const AdminPermissionTile().sliver,

              /// Uninstall window
              DefaultHero(
                tag: HeroTags.uninstallWindowTileTag,
                child: DefaultListTile(
                  position: ItemPosition.mid,
                  titleText: context.locale.uninstall_window_tile_title,
                  subtitleText: context.locale.uninstall_window_tile_subtitle,
                  trailing: StyledText(
                    parentalControls.uninstallWindowTime.format(context),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  onPressed: () async {
                    /// Check if between the specified window
                    if (isAdminEnabled &&
                        !ref
                            .read(parentalControlsProvider.notifier)
                            .isBetweenUninstallWindow) {
                      context.showSnackAlert(
                        context.locale.permission_admin_snack_alert,
                      );
                      return;
                    }

                    final pickedTime = await showCustomTimePickerDialog(
                      context: context,
                      heroTag: HeroTags.uninstallWindowTileTag,
                      initialTime: parentalControls.uninstallWindowTime,
                      info: context.locale.uninstall_window_tile_title,
                    );

                    if (pickedTime != null && context.mounted) {
                      ref
                          .read(parentalControlsProvider.notifier)
                          .changeUninstallWindowTime(pickedTime);
                    }
                  },
                ),
              ).sliver,

              /// Parental password management
              DefaultListTile(
                position: ItemPosition.bottom,
                leadingIcon: FluentIcons.password_20_regular,
                titleText: "Manage Parental Password",
                subtitleText: "Change your parental control password",
                onPressed: () => showParentalPasswordManagementDialog(
                  context: context,
                ),
              ).sliver,

              const SliverTabsBottomPadding(),
            ],
          ),
        )
      ],
    );
  }
}
