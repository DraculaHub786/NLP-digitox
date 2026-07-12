import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/providers/restrictions/apps_restrictions_provider.dart';
import 'package:nlp_digitox/providers/restrictions/restriction_groups_provider.dart';
import 'package:nlp_digitox/providers/system/parental_controls_provider.dart';
import 'package:nlp_digitox/providers/apps/apps_info_provider.dart';
import 'package:nlp_digitox/providers/usage/todays_apps_usage_provider.dart';
import 'package:nlp_digitox/ui/common/application_icon.dart';
import 'package:nlp_digitox/ui/common/default_slide_to_remove.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/time_text_short.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/screens/restriction_groups/create_update_group_screen.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';
import 'package:skeletonizer/skeletonizer.dart';

class RestrictionGroupCard extends ConsumerWidget {
  const RestrictionGroupCard({
    super.key,
    required this.group,
    this.position,
  });

  final RestrictionGroup group;
  final ItemPosition? position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupedAppsInfo = ref
        .watch(appsInfoProvider.select((v) => v.value?.values
            .where((e) => group.distractingApps.contains(e.packageName))))
        ?.toList();
    final installedDistractingApps = groupedAppsInfo?.map((e) => e.packageName);

    final timeSpent = ref.watch(
          todaysAppsUsageProvider.select(
            (v) => v.value?.entries
                .where(
                  (e) => installedDistractingApps?.contains(e.key) ?? false,
                )
                .fold<int>(
                  0,
                  (t, e) => (t + e.value.screenTime),
                ),
          ),
        ) ??
        0;

    double progress = timeSpent <= 0 || group.timerSec <= 0
        ? 0
        : max(0, timeSpent / group.timerSec);

    final cardColor = colorScheme.surfaceContainerHighest.withValues(alpha: 0.3);
    final borderColor = colorScheme.outline.withValues(alpha: 0.2);

    return DefaultHero(
      tag: HeroTags.removeRestrictionGroupTag(group.id),
      child: DefaultSlideToRemove(
        enabled: true,
        key: Key("restrictionGroup.${group.id}"),
        position: position ?? ItemPosition.none,
        onDismiss: () => _deleteGroup(context, ref),
        child: GestureDetector(
          onTap: () => _goToEditScreen(context, ref),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    /// Remaining time indicator
                    Container(
                      height: 40,
                      width: 40,
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          CircularProgressIndicator(
                            value: 1,
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                            color: colorScheme.secondaryContainer,
                          ),
                          CircularProgressIndicator(
                            strokeWidth: 6,
                            strokeCap: StrokeCap.round,
                            value: progress > 0 ? progress : 1,
                            color: timeSpent > 0 &&
                                    group.timerSec > 0 &&
                                    progress >= 1
                                ? colorScheme.error
                                : null,
                          ),
                        ],
                      ),
                    ),
                    12.hBox,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          StyledText(
                            group.groupName,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          StyledText(
                            group.periodDurationInMins > 0
                                ? context.locale.app_active_period_tile_subtitle(
                                    group.activePeriodStart.format(context),
                                    group.activePeriodEnd.format(context),
                                  )
                                : context.locale.app_limit_status_not_set,
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ],
                      ),
                    ),
                    8.hBox,
                    if (group.timerSec > 0)
                      Flexible(
                        flex: 0,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TimeTextShort(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                timeDuration: timeSpent.seconds,
                                secondaryFontWeight: FontWeight.w600,
                              ),
                              StyledText(" / ", fontSize: 14),
                              TimeTextShort(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                timeDuration: group.timerSec.seconds,
                                secondaryFontWeight: FontWeight.w600,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                12.vBox,
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    height: 40,
                    color: colorScheme.surfaceContainerHigh,
                    child: Skeletonizer.zone(
                      enableSwitchAnimation: true,
                      enabled: groupedAppsInfo == null,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        physics: const BouncingScrollPhysics(),
                        scrollDirection: Axis.horizontal,
                        itemCount: groupedAppsInfo?.length ??
                            group.distractingApps.length,
                        itemBuilder: (context, index) {
                          final appInfo =
                              groupedAppsInfo?.elementAtOrNull(index);
                          return Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: appInfo == null
                                ? const Bone.icon(size: 28)
                                : ApplicationIcon(
                                    appInfo: appInfo,
                                    size: 14,
                                  ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _deleteGroup(BuildContext context, WidgetRef ref) async {
    final controls = ref.read(parentalControlsProvider);
    final isBetweenWindow =
        ref.read(parentalControlsProvider.notifier).isBetweenInvincibleWindow;

    final canModifyTimer = !(controls.isInvincibleModeOn &&
        controls.includeGroupsTimer &&
        !isBetweenWindow &&
        group.timerSec > 0);

    final canModifyActivePeriod = !(controls.isInvincibleModeOn &&
        controls.includeGroupsActivePeriod &&
        !isBetweenWindow &&
        group.periodDurationInMins > 0);

    if (!canModifyTimer || !canModifyActivePeriod) {
      context.showSnackAlert(
        context.locale.invincible_mode_snack_alert,
      );
      return;
    }

    final confirm = await showConfirmationDialog(
      context: context,
      heroTag: HeroTags.removeRestrictionGroupTag(group.id),
      title: context.locale.remove_restriction_group_dialog_title,
      info:
          context.locale.remove_restriction_group_dialog_info(group.groupName),
      icon: FluentIcons.delete_20_filled,
      positiveLabel: context.locale.dialog_button_remove,
    );

    if (!confirm) return;

    ref.read(appsRestrictionsProvider.notifier).updateAssociatedGroupId(
          appPackages: group.distractingApps,
          groupId: null,
          removeIds: true,
        );

    ref.read(restrictionGroupsProvider.notifier).removeGroup(group: group);
  }

  void _goToEditScreen(BuildContext context, WidgetRef ref) {
    final controls = ref.read(parentalControlsProvider);
    final isBetweenWindow =
        ref.read(parentalControlsProvider.notifier).isBetweenInvincibleWindow;

    final canModifyTimer = !(controls.isInvincibleModeOn &&
        controls.includeGroupsTimer &&
        !isBetweenWindow &&
        group.timerSec > 0);

    final canModifyActivePeriod = !(controls.isInvincibleModeOn &&
        controls.includeGroupsActivePeriod &&
        !isBetweenWindow &&
        group.periodDurationInMins > 0);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CreateUpdateRestrictionGroupScreen(
          group: group,
          canUpdateTimer: canModifyTimer,
          canUpdateActivePeriod: canModifyActivePeriod,
        ),
      ),
    );
  }
}
