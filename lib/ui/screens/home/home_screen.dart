import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/services/method_channel_service.dart';
import 'package:nlp_digitox/config/app_constants.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/providers/system/mindful_settings_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/dialogs/confirmation_dialog.dart';
import 'package:nlp_digitox/ui/screens/home/bedtime/tab_bedtime.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/settings_fab.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/greetings_username.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/tab_dashboard.dart';
import 'package:nlp_digitox/ui/screens/home/notifications/new_notification_schedule_fab.dart';
import 'package:nlp_digitox/ui/screens/home/statistics/tab_statistics.dart';
import 'package:nlp_digitox/ui/screens/home/notifications/tab_notifications.dart';
import 'package:nlp_digitox/ui/screens/leaderboard/leaderboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({
    super.key,
    this.initialTabIndex,
  });

  final int? initialTabIndex;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showDonationDialog());
  }

  void _showDonationDialog() async {
    await Future.delayed(10.seconds);

    /// Add randomness (1 out of 10) to skip showing sometimes whenever possible
    final prob = Random().nextInt(10);
    debugPrint("Show donation dialog? : ${prob == 1}");
    if (!mounted || prob != 1) return;

    final isConfirm = await showConfirmationDialog(
      context: context,
      heroTag: HeroTags.donationDialogTag,
      title: context.locale.donation_card_title,
      info: context.locale.donation_card_info,
      icon: FluentIcons.handshake_20_regular,
      positiveLabel: context.locale.donation_card_button_donate,
    );

    if (!isConfirm) return;
    MethodChannelService.instance
        .launchUrl(AppConstants.gitHubDonationSectionUrl);
  }

  @override
  Widget build(BuildContext context) {
    final homeTab =
        ref.watch((mindfulSettingsProvider.select((v) => v.defaultHomeTab)));

    return PopScope(
      onPopInvokedWithResult: (didPop, _) => SystemNavigator.pop(),
      child: ScaffoldShell(
        initialTab: widget.initialTabIndex ?? homeTab.index,
        canGoBack: false,
        items: [
          NavbarItem(
            titleText: context.locale.dashboard_tab_title,
            icon: FluentIcons.home_20_regular,
            filledIcon: FluentIcons.home_20_filled,
            sliverBody: const TabDashboard(),
            titleBuilder: (_) => const GreetingsUsername(),
            fab: const SettingsFab(),
          ),
          NavbarItem(
            titleText: context.locale.statistics_tab_title,
            icon: FluentIcons.data_pie_24_regular,
            filledIcon: FluentIcons.data_pie_24_filled,
            sliverBody: const TabStatistics(),
          ),
          NavbarItem(
            icon: FluentIcons.alert_urgent_20_regular,
            filledIcon: FluentIcons.alert_urgent_20_filled,
            titleText: context.locale.notifications_tab_title,
            fab: const NewNotificationScheduleFab(),
            sliverBody: const TabNotifications(),
          ),
          NavbarItem(
            titleText: context.locale.bedtime_tab_title,
            icon: FluentIcons.sleep_20_regular,
            filledIcon: FluentIcons.sleep_20_filled,
            sliverBody: const TabBedtime(),
          ),
          NavbarItem(
            titleText: "Leaderboard",
            icon: FluentIcons.trophy_20_regular,
            filledIcon: FluentIcons.trophy_20_filled,
            sliverBody: const LeaderboardScreen(),
          ),
        ],
      ),
    );
  }
}