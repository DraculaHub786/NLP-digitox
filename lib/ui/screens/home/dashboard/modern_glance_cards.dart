import 'dart:ui';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_int.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';
import 'package:nlp_digitox/providers/usage/weekly_device_usage_provider.dart';
import 'package:nlp_digitox/providers/focus/monthly_focus_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

class ModernStatsCards extends ConsumerWidget {
  const ModernStatsCards({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            gradientColors: [
              const Color(0xFF4DD6D9),
              const Color(0xFF3B82F6),
            ],
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
            gradientColors: [
              const Color(0xFF10B981),
              const Color(0xFF059669),
            ],
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
  final List<Color> gradientColors;

  const _ModernStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.trend,
    this.invertTrend = false,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: gradientColors[0].withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: gradientColors[0].withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
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
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
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
                color: Colors.white.withValues(alpha: 0.8),
              ),
              const SizedBox(height: 4),
              StyledText(
                value,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ],
          ),
        ),
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
    final todayUsage = ref.watch(
      weeklyDeviceUsageProvider(dateToday.weekRange).select((v) => v[dateToday]),
    );

    final mobileData = todayUsage?.mobileData ?? 0;
    final wifiData = todayUsage?.wifiData ?? 0;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ModernMiniCard(
                title: 'Mobile Data',
                value: '${(mobileData / 1024).toStringAsFixed(1)} MB',
                icon: FluentIcons.cellular_data_1_20_filled,
                color: const Color(0xFF8B5CF6),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ModernMiniCard(
                title: 'WiFi Data',
                value: '${(wifiData / 1024 / 1024).toStringAsFixed(1)} GB',
                icon: FluentIcons.wifi_1_20_regular,
                color: const Color(0xFF06B6D4),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _ModernMiniCard(
                title: 'Unlocks',
                value: '42',
                icon: FluentIcons.lock_open_20_regular,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ModernMiniCard(
                title: 'Notifications',
                value: '128',
                icon: FluentIcons.alert_20_regular,
                color: const Color(0xFFEC4899),
              ),
            ),
          ],
        ),
      ],
    ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1, end: 0);
  }
}

class _ModernMiniCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ModernMiniCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [Colors.white.withValues(alpha: 0.08), Colors.white.withValues(alpha: 0.04)]
                  : [Colors.white.withValues(alpha: 0.9), Colors.white.withValues(alpha: 0.7)],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      title,
                      fontSize: 11,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                    const SizedBox(height: 2),
                    StyledText(
                      value,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: color.withValues(alpha: 0.2),
            ),
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