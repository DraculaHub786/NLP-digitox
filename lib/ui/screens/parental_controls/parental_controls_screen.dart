import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/auth_service.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/dialogs/time_picker_dialog.dart';
import 'package:nlp_digitox/ui/dialogs/parental_password_management_dialog.dart';
import 'package:nlp_digitox/ui/permissions/admin_permission_tile.dart';
import 'package:nlp_digitox/ui/permissions/battery_optimization_recommendation_card.dart';
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

        if (!context.mounted) return;

        if (isAuthenticated == null) {
          context.showSnackAlert(
            context.locale.protected_access_no_lock_snack_alert,
            icon: FluentIcons.fingerprint_20_filled,
          );
          return;
        }

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
    final colorScheme = Theme.of(context).colorScheme;
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
              // Section header for invincible mode
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 4),
                  child: ModernSectionHeader(
                    title: context.locale.parental_controls_tab_title,
                    subtitle: parentalControls.protectedAccess
                        ? 'Protected access is on'
                        : 'Configure parental controls',
                  ),
                ),
              ),

              /// Invincible mode
              const InvincibleModeSettings(),

              /// C.1 + C.2: Battery optimization recommendation & OEM autostart
              const BatteryOptimizationRecommendationCard(),

              // Parental controls section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: ModernSectionHeader(
                    title: 'Access Control',
                  ),
                ),
              ),

              /// Protected access
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: DefaultHero(
                    tag: HeroTags.invincibleModeTileTag,
                    child: ModernSettingsTile(
                      title: context.locale.protected_access_tile_title,
                      subtitle: context.locale.protected_access_tile_subtitle,
                      icon: FluentIcons.fingerprint_20_regular,
                      iconColor: colorScheme.primary,
                      value: parentalControls.protectedAccess,
                      onChanged: (_) => _toggleProtectedAccess(
                        context,
                        ref,
                        parentalControls.protectedAccess,
                      ),
                    ),
                  ),
                ),
              ),

              /// Tamper protection
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: const AdminPermissionTile(),
                ),
              ),

              /// Uninstall window
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: DefaultHero(
                    tag: HeroTags.uninstallWindowTileTag,
                    child: ModernListTile(
                      title: context.locale.uninstall_window_tile_title,
                      subtitle: context.locale.uninstall_window_tile_subtitle,
                      icon: FluentIcons.clock_20_regular,
                      iconColor: colorScheme.primary,
                      showChevron: true,
                      trailing: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.secondaryContainer,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: StyledText(
                            parentalControls.uninstallWindowTime.format(context),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      onTap: () async {
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
                  ),
                ),
              ),

              // Password section header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
                  child: ModernSectionHeader(
                    title: 'Security',
                  ),
                ),
              ),

              /// Parental password management
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                  child: ModernListTile(
                    title: "Manage Parental Password",
                    subtitle: "Change your parental control password",
                    icon: FluentIcons.password_20_regular,
                    iconColor: colorScheme.primary,
                    onTap: () => showParentalPasswordManagementDialog(
                      context: context,
                    ),
                  ),
                ),
              ),

              const SliverTabsBottomPadding(),
            ],
          ),
        )
      ],
    );
  }
}
