// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/item_position.dart';
import 'package:nlp_digitox/core/enums/usage_type.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_int.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/restrictions/apps_restrictions_provider.dart';
import 'package:nlp_digitox/providers/apps/apps_info_provider.dart';
import 'package:nlp_digitox/providers/usage/dated_apps_usage_provider.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/application_icon.dart';
import 'package:nlp_digitox/ui/screens/app_dashboard/app_internet_tile.dart';
import 'package:nlp_digitox/ui/screens/app_dashboard/app_timer_tile.dart';
import 'package:nlp_digitox/ui/transitions/default_hero.dart';

/// List tile used for displaying app usage info based on the bool [selectedUsageType]
class ApplicationTile extends ConsumerWidget {
  const ApplicationTile({
    super.key,
    required this.packageName,
    required this.usageType,
    required this.selectedDay,
    this.position,
  });

  final String packageName;
  final UsageType usageType;
  final DateTime selectedDay;
  final ItemPosition? position;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    /// Application info
    final appInfo =
        ref.watch(appsInfoProvider.select((v) => v.value?[packageName]));

    /// Screen usage for today
    final screenTimeToday = ref.watch(appsUsageProvider(dateToday)
            .select((v) => v.value?[packageName]?.screenTime)) ??
        0;

    /// All usage for selected day
    final usage = ref.watch(appsUsageProvider(selectedDay)
            .select((v) => v.value?[packageName])) ??
        const UsageModel();

    /// App's timer in seconds
    final appTimer = ref.watch(
            appsRestrictionsProvider.select((e) => e[packageName]?.timerSec)) ??
        0;

    final isPurged = appTimer > 0 && appTimer <= screenTimeToday;

    return appInfo == null
        ? 0.vBox
        : DefaultHero(
            tag: HeroTags.applicationTileTag(appInfo.packageName),
            child: DefaultListTile(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              position: position,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.appDashboardPath,
                  arguments: {
                    "package": packageName,
                    "type": usageType.index,
                    "day": selectedDay.toIso8601String(),
                  },
                );
              },

              /// App icon
              leading: ApplicationIcon(appInfo: appInfo, isGrayedOut: isPurged),

              /// App Name
              titleText: appInfo.name,

              /// App's Screen Time OR Data Usage
              subtitle: StyledText(
                usageType == UsageType.networkUsage
                    ? usage.totalData.toData()
                    : usage.screenTime.seconds.toTimeFull(context),
                fontSize: 14,
                color: Theme.of(context).hintColor,
              ),

              /// Timer picker button
              trailing: appInfo.isImpSysApp
                  ? null
                  : usageType == UsageType.screenUsage
                      ? AppTimerTile(
                          appInfo: appInfo,
                          appTimer: appTimer,
                          isPurged: isPurged,
                          isIconButton: true,
                        )
                      : AppInternetTile(
                          appInfo: appInfo,
                          isIconButton: true,
                        ),
            ),
          );
  }
}
