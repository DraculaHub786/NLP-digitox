import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_int.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/notifications/today_notifications_count_provider.dart';
import 'package:nlp_digitox/providers/usage/device_unlock_count_provider.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/providers/focus/monthly_focus_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class ModernStatsCards extends ConsumerWidget {
  const ModernStatsCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final (todayScreenTime, yesterdayScreenTime) = ref.watch(
      weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => (
            v[dateToday]?.screenTime ?? 0,
            v[dateToday.subtract(1.days)]?.screenTime ?? 0
          )),
    );

    final customRange =
        DateTimeRange(start: dateToday.subtract(1.days), end: dateToday);
    final (todayFocus, yesterdayFocus) = ref.watch(
      monthlyFocusProvider(customRange).select((v) => (
            v.monthlyFocus[customRange.end] ?? 0,
            v.monthlyFocus[customRange.start] ?? 0
          )),
    );

    return Row(
      children: [
        Expanded(
          child: _ModernStatCard(
            title: 'Screen Time',
            value: todayScreenTime.seconds.toTimeShort(context),
            icon: FluentIcons.phone_screen_time_20_regular,
            trend: todayScreenTime.toDiffPercentage(yesterdayScreenTime),
            accentColor: colorScheme.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ModernStatCard(
            title: 'Focus Time',
            value: todayFocus.seconds.toTimeShort(context),
            icon: FluentIcons.target_20_filled,
            trend: todayFocus.toDiffPercentage(yesterdayFocus),
            invertTrend: true,
            accentColor: colorScheme.secondary,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ModernStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final int trend;
  final bool invertTrend;
  final Color accentColor;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    this.invertTrend = false,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surfaceContainerHighest.withOpacity(0.3);
    final borderColor = colorScheme.outline.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 22,
                ),
              ),
              _TrendBadge(trend: trend, invertTrend: invertTrend),
            ],
          ),
          const SizedBox(height: 16),
          StyledText(
            title,
            fontSize: 13,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: StyledText(
              value,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendBadge extends StatelessWidget {
  final int trend;
  final bool invertTrend;

  const _TrendBadge({required this.trend, this.invertTrend = false});

  @override
  Widget build(BuildContext context) {
    final isPositive = invertTrend ? trend < 0 : trend > 0;
    final color = isPositive ? Colors.green[200] : Colors.red[200];
    final icon = isPositive ? FluentIcons.arrow_up_12_filled : FluentIcons.arrow_down_12_filled;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 2),
          Text(
            '${trend.abs()}%',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class ModernGlanceGrid extends ConsumerWidget {
  const ModernGlanceGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final todayUsage = ref.watch(
      weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday]),
    );
    final unlockCount = ref.watch(deviceUnlockCountProvider).valueOrNull ?? 0;
    final notificationsCount = ref.watch(todayNotificationsCountProvider).valueOrNull ?? 0;

    final mobileData = todayUsage?.mobileData ?? 0;
    final wifiData = todayUsage?.wifiData ?? 0;

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 10.0;
        final itemWidth = (constraints.maxWidth - spacing) / 2;
        final childAspectRatio = itemWidth / 86;

        return GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          childAspectRatio: childAspectRatio,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            _ModernMiniCard(
              title: 'Mobile Data',
              value: '${(mobileData / 1024).toStringAsFixed(1)} MB',
              icon: FluentIcons.cellular_data_1_20_filled,
              color: colorScheme.primary,
            ),
            _ModernMiniCard(
              title: 'WiFi Data',
              value: '${(wifiData / 1024 / 1024).toStringAsFixed(1)} GB',
              icon: FluentIcons.wifi_1_20_regular,
              color: colorScheme.secondary,
            ),
            _ModernMiniCard(
              title: 'Unlocks',
              value: unlockCount.toString(),
              icon: FluentIcons.lock_open_20_regular,
              color: colorScheme.tertiary,
            ),
            _ModernMiniCard(
              title: 'Notifications',
              value: notificationsCount.toString(),
              icon: FluentIcons.alert_20_regular,
              color: colorScheme.primaryContainer,
              iconColor: colorScheme.onPrimaryContainer,
            ),
          ],
        );
      },
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ModernMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color? iconColor;

  const _ModernMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final iconTint = iconColor ?? color;
    final cardColor = colorScheme.surfaceContainerHighest.withOpacity(0.3);
    final borderColor = colorScheme.outline.withOpacity(0.2);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconTint, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  title,
                  fontSize: 11,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: colorScheme.onSurface.withValues(alpha: 0.75),
                ),
                const SizedBox(height: 2),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: StyledText(
                    value,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ModernQuickActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const ModernQuickActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final cardColor = colorScheme.surfaceContainerHighest.withOpacity(0.3);
    final borderColor = colorScheme.outline.withOpacity(0.2);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 8),
              StyledText(
                title,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
