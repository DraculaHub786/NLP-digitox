import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/permissions/accessibility_permission_card.dart';
import 'package:nlp_digitox/ui/screens/websites_blocking/add_websites_fab.dart';
import 'package:nlp_digitox/ui/screens/websites_blocking/sliver_blocked_websites_list.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

class WebsitesBlockingScreen extends ConsumerWidget {
  const WebsitesBlockingScreen({super.key});

  void _turnNsfwBlockerOn(BuildContext context, WidgetRef ref) async {
    final isConfirm = await showConfirmationDialog(
      context: context,
      icon: FluentIcons.video_prohibited_20_filled,
      heroTag: HeroTags.blockNsfwTileTag,
      title: context.locale.adult_content_heading,
      info: context.locale.block_nsfw_dialog_info,
      positiveLabel: context.locale.block_nsfw_dialog_button_block_anyway,
    );

    if (isConfirm) {
      ref.read(wellBeingProvider.notifier).switchBlockNsfwSites();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final blockNsfwSites =
        ref.watch(wellBeingProvider.select((v) => v.blockNsfwSites));

    final haveAccessibilityPermission = ref.watch(
      permissionProvider.select((v) => v.haveAccessibilityPermission),
    );

    final blockedWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.blockedWebsites,
    ));
    final nsfwWebsites = ref.watch(wellBeingProvider.select(
      (v) => v.nsfwWebsites,
    ));
    final totalBlocked = blockedWebsites.length + nsfwWebsites.length;

    return ScaffoldShell(items: [
      NavbarItem(
        icon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        filledIcon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        fab: const AddWebsitesFAB(),
        titleText: context.locale.websites_blocking_tab_title,
        sliverBody: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Section header with count
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                child: ModernSectionHeader(
                  title: context.locale.websites_blocking_tab_title,
                  subtitle: '$totalBlocked website${totalBlocked == 1 ? '' : 's'} blocked • ${blockNsfwSites ? 'NSFW filter on' : 'NSFW filter off'}',
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                    ),
                    child: StyledText(
                      '$totalBlocked',
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ),
            ),

            // Info card in modern style
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                    border: Border.all(
                      color: colorScheme.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          FluentIcons.info_20_filled,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: StyledText(
                          context.locale.websites_blocking_tab_info,
                          fontSize: 13,
                          color: colorScheme.onSurface.withValues(alpha: 0.75),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Adult content header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: ModernSectionHeader(
                  title: context.locale.adult_content_heading,
                ),
              ),
            ),

            const AccessibilityPermissionCard(),

            // Block NSFW websites - modern settings tile
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                child: DefaultHero(
                  tag: HeroTags.blockNsfwTileTag,
                  child: ModernSettingsTile(
                    title: context.locale.block_nsfw_title,
                    subtitle: context.locale.block_nsfw_subtitle,
                    icon: FluentIcons.video_prohibited_20_regular,
                    iconColor: colorScheme.primary,
                    value: blockNsfwSites,
                    onChanged: haveAccessibilityPermission && !blockNsfwSites
                        ? (_) => _turnNsfwBlockerOn(context, ref)
                        : null,
                  ),
                ),
              ),
            ),

            // Blocked websites header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
                child: ModernSectionHeader(
                  title: context.locale.blocked_websites_heading,
                ),
              ),
            ),

            // Distracting websites list
            const SliverBlockedWebsitesList(),

            const SliverTabsBottomPadding(),
          ],
        ),
      )
    ]);
  }
}
