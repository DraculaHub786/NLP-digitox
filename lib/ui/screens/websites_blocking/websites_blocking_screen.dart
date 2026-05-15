
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/providers/restrictions/wellbeing_provider.dart';
import 'package:nlp_digitox/providers/system/permissions_provider.dart';
import 'package:nlp_digitox/ui/common/content_section_header.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
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
    final blockNsfwSites =
        ref.watch(wellBeingProvider.select((v) => v.blockNsfwSites));

    final haveAccessibilityPermission = ref.watch(
      permissionProvider.select((v) => v.haveAccessibilityPermission),
    );

    return ScaffoldShell(items: [
      NavbarItem(
        icon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        filledIcon: FluentIcons.arrow_flow_diagonal_up_right_12_filled,
        fab: const AddWebsitesFAB(),
        titleText: context.locale.websites_blocking_tab_title,
        sliverBody: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            /// Information about websites blocking
            StyledText(context.locale.websites_blocking_tab_info).sliver,

            /// Adult content header
            ContentSectionHeader(title: context.locale.adult_content_heading)
                .sliver,

            const AccessibilityPermissionCard(),

            /// Block NSFW websites
            DefaultHero(
              tag: HeroTags.blockNsfwTileTag,
              child: DefaultListTile(
                enabled: haveAccessibilityPermission && !blockNsfwSites,
                leadingIcon: FluentIcons.video_prohibited_20_regular,
                titleText: context.locale.block_nsfw_title,
                subtitleText: context.locale.block_nsfw_subtitle,
                switchValue: blockNsfwSites,
                onPressed: () => _turnNsfwBlockerOn(context, ref),
              ),
            ).sliver,

            /// Blocked websites header
            ContentSectionHeader(title: context.locale.blocked_websites_heading)
                .sliver,

            /// Distracting websites list
            const SliverBlockedWebsitesList(),

            const SliverTabsBottomPadding(),
          ],
        ),
      )
    ]);
  }
}
