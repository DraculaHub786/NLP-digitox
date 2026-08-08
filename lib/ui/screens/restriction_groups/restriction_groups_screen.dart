import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_widget.dart';
import 'package:nlp_digitox/core/utils/widget_utils.dart';
import 'package:nlp_digitox/providers/restrictions/restriction_groups_provider.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/screens/restriction_groups/create_update_group_screen.dart';
import 'package:nlp_digitox/ui/screens/restriction_groups/restriction_group_card.dart';
import 'package:nlp_digitox/ui/screens/restriction_groups/sample_restriction_group.dart';
import 'package:sliver_tools/sliver_tools.dart';

class RestrictionGroupsScreen extends ConsumerWidget {
  const RestrictionGroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final groups =
        ref.watch(restrictionGroupsProvider.select((v) => v.values.toList()));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.app_title_20_regular,
          filledIcon: FluentIcons.app_title_20_filled,
          titleText: context.locale.restriction_groups_tab_title,
          fab: DefaultFabButton(
            label: context.locale.create_group_fab_button,
            icon: FluentIcons.tab_add_20_filled,
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const CreateUpdateRestrictionGroupScreen(),
              ),
            ),
          ),
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Quick summary header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: ModernSectionHeader(
                    title: context.locale.restriction_groups_tab_title,
                    subtitle: '${groups.length} group${groups.length == 1 ? '' : 's'} • ${groups.where((g) => g.timerSec > 0).length} with timers',
                    trailing: groups.isNotEmpty
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                            ),
                            child: StyledText(
                              '${groups.length}',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: colorScheme.onPrimaryContainer,
                            ),
                          )
                        : null,
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
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
                      border: Border.all(
                        color: colorScheme.outline.withValues(alpha: 0.18),
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
                            context.locale.restriction_groups_tab_info,
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

              SliverAnimatedSwitcher(
                duration: 250.ms,
                child: groups.isEmpty
                    ? const SampleRestrictionGroup().sliver
                    : SliverList.builder(
                        itemCount: groups.length,
                        itemBuilder: (context, index) => RestrictionGroupCard(
                          group: groups[index],
                          position: getItemPositionInList(index, groups.length),
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
