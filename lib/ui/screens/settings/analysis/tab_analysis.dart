import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:nlp_digitox/core/extensions/ext_build_context.dart';
import 'package:nlp_digitox/core/extensions/ext_duration.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/usage_model.dart';
import 'package:nlp_digitox/providers/usage/analysis_usage_provider.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Analysis tab — a usage-trends line chart that replaces the old
/// Database tab. Shows aggregated daily screen time over 7/30/90 days
/// with a vs-previous-week trend pill (less screen time = improvement).
class TabAnalysis extends ConsumerStatefulWidget {
  const TabAnalysis({super.key});

  @override
  ConsumerState<TabAnalysis> createState() => _TabAnalysisState();
}

class _TabAnalysisState extends ConsumerState<TabAnalysis>
    with AutomaticKeepAliveClientMixin {
  int _days = 7;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    /// Always fetch an extra week so the trend pill has a previous
    /// period to compare against, regardless of the selected range.
    final useAsync = ref.watch(analysisUsageProvider(_days + 7));

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        /// Range selector
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: _RangeSelector(
              selectedDays: _days,
              onSelected: (days) => setState(() => _days = days),
            ),
          ),
        ),

        /// Chart / loading / error
        useAsync.when(
          data: (usageMap) {
            final entries = _buildSortedEntries(usageMap, _days);
            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList.list(
                children: [
                  _HeroChartCard(
                    days: _days,
                    entries: entries,
                  ),
                ],
              ),
            );
          },
          loading: () => const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: _AnalysisLoadingCard(),
            ),
          ),
          error: (error, _) => SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _AnalysisErrorCard(message: '$error'),
            ),
          ),
        ),

        const SliverTabsBottomPadding(),
      ],
    );
  }

  /// Slices the provider's (days + 7) map down to the last [days] entries.
  List<MapEntry<DateTime, UsageModel>> _buildSortedEntries(
    Map<DateTime, UsageModel> usageMap,
    int days,
  ) {
    final sorted = usageMap.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return sorted.sublist(math.max(0, sorted.length - days));
  }
}

// ==================================================================================================================
// Range selector
// ==================================================================================================================

class _RangeSelector extends StatelessWidget {
  final int selectedDays;
  final ValueChanged<int> onSelected;

  const _RangeSelector({
    required this.selectedDays,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final entries = [
      (value: 7, label: context.locale.analysis_7_days),
      (value: 30, label: context.locale.analysis_30_days),
      (value: 90, label: context.locale.analysis_90_days),
    ];

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: entries.map((entry) {
          final isSelected = entry.value == selectedDays;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelected(entry.value),
              child: AnimatedContainer(
                duration: 200.ms,
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(GlassTokens.radiusPill),
                ),
                child: Center(
                  child: StyledText(
                    entry.label,
                    fontSize: 12,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected
                        ? colorScheme.onPrimary
                        : colorScheme.onSurface.withValues(alpha: 0.7),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ==================================================================================================================
// Hero chart card
// ==================================================================================================================

class _HeroChartCard extends StatelessWidget {
  /// Sorted, already-sliced entries: [key] = day, [value] = UsageModel.
  final int days;
  final List<MapEntry<DateTime, UsageModel>> entries;

  const _HeroChartCard({
    required this.days,
    required this.entries,
  });

  @override
  Widget build(BuildContext context) {
    final totalSeconds =
        entries.fold<int>(0, (sum, e) => sum + e.value.screenTime);
    final hasData = entries.any((e) => e.value.screenTime > 0);
    final averageSeconds = days > 0 ? (totalSeconds / days).round() : 0;

    final trend = _computeTrend(entries);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1F2E23), Color(0xFF28392C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.18),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1F2E23).withValues(alpha: 0.4),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  FluentIcons.phone_screen_time_20_regular,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: StyledText(
                  context.locale.analysis_screen_time_trend,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _TrendPill(trend: trend),
            ],
          ),

          16.vBox,

          /// Chart
          SizedBox(
            height: 210,
            child: Stack(
              children: [
                Positioned.fill(
                  child: _buildLineChart(context),
                ),
                if (!hasData)
                  Positioned.fill(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: StyledText(
                          context.locale.analysis_no_data_info,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.7),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          18.vBox,

          /// Summary row
          Row(
            children: [
              _SummaryStat(
                label: context.locale.analysis_daily_average,
                value: averageSeconds.seconds.toTimeShort(context),
              ),
              _SummaryDivider(),
              _SummaryStat(
                label: context.locale.analysis_total,
                value: totalSeconds.seconds.toTimeShort(context),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.12, end: 0, curve: Curves.easeOutCubic);
  }

  // --------------------------------------------------------------------------
  // Trend math — compares the last 7 days vs the 7 days before that.
  // Less screen time = improvement.
  // --------------------------------------------------------------------------

  ({double percentChange, bool improvement}) _computeTrend(
    List<MapEntry<DateTime, UsageModel>> allEntries,
  ) {
    if (allEntries.length < 14) return (percentChange: 0, improvement: false);

    int sum(Iterable<MapEntry<DateTime, UsageModel>> slice) =>
        slice.fold<int>(0, (acc, e) => acc + e.value.screenTime);

    final currentSlice = allEntries.sublist(allEntries.length - 7);
    final previousSlice =
        allEntries.sublist(allEntries.length - 14, allEntries.length - 7);

    final currentAvg = sum(currentSlice) / 7;
    final previousAvg = sum(previousSlice) / 7;

    final percentChange = previousAvg > 0
        ? ((currentAvg - previousAvg) / previousAvg) * 100
        : 0.0;

    return (percentChange: percentChange, improvement: percentChange < 0);
  }

  // --------------------------------------------------------------------------
  // Chart
  // --------------------------------------------------------------------------

  Widget _buildLineChart(BuildContext context) {
    final maxMinutes = entries.fold<double>(
      0,
      (max, e) => math.max(max, e.value.screenTime / 60),
    );

    /// Rounds the y-axis max up to a "nice" interval so axis labels
    /// read as round numbers (15m, 30m, 1h, 2h, 3h, ...).
    final yMax = _niceYMax(math.max(maxMinutes * 1.2, 60.0));
    final yInterval = yMax / 4;

    final spots = List.generate(
      entries.length,
      (i) => FlSpot(
        i.toDouble(),
        (entries[i].value.screenTime / 60).toDouble(),
      ),
    );

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: math.max(0, entries.length - 1).toDouble(),
        minY: 0,
        maxY: yMax,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: yInterval,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white.withValues(alpha: 0.14),
            strokeWidth: 1,
            dashArray: [6, 6],
          ),
        ),
        borderData: FlBorderData(show: false),
        titlesData: _buildTitles(context),
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) => touchedSpots.map((spot) {
              final secs = (spot.y * 60).round();
              return LineTooltipItem(
                secs.seconds.toTimeShort(context),
                const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              );
            }).toList(),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            curveSmoothness: 0.35,
            gradient: const LinearGradient(
              colors: [Color(0xFFD5D9C0), Color(0xFFA3A78D)],
            ),
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  Colors.white.withValues(alpha: 0.22),
                  Colors.white.withValues(alpha: 0.0),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
      ),
      duration: 500.ms,
      curve: Curves.fastEaseInToSlowEaseOut,
    );
  }

  FlTitlesData _buildTitles(BuildContext context) {
    final labelColor = Colors.white.withValues(alpha: 0.75);
    final maxMinutes = entries.fold<double>(
      0,
      (max, e) => math.max(max, e.value.screenTime / 60),
    );
    final yInterval = _niceYMax(math.max(maxMinutes * 1.2, 60.0)) / 4;

    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 42,
          interval: yInterval,
          getTitlesWidget: (value, meta) => StyledText(
            _formatMinutes(value.toInt()),
            fontSize: 10,
            color: labelColor,
          ),
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 26,
          interval: _labelInterval,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= entries.length) {
              return const SizedBox.shrink();
            }
            final day = entries[index].key;
            final label = days == 7
                ? DateFormat.E(Localizations.localeOf(context).languageCode)
                    .format(day)
                : '${day.day}';
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: StyledText(
                label,
                fontSize: 10,
                color: labelColor,
                maxLines: 1,
              ),
            );
          },
        ),
      ),
    );
  }

  double get _labelInterval {
    if (days <= 7) return 1;
    if (days <= 30) return 5;
    return 15;
  }

  /// Rounds the y-axis max up to a "nice" interval so axis labels
  /// read as round numbers (15m, 30m, 1h, 2h, 3h, ...).
  double _niceYMax(double raw) {
    const candidates = [
      15.0, 30.0, 60.0, 120.0, 180.0, 240.0, 360.0, 480.0, 600.0,
      720.0, 960.0, 1200.0, 1440.0,
    ];
    for (final candidate in candidates) {
      if (candidate >= raw) return candidate;
    }
    return ((raw / 60).ceil() * 60).toDouble();
  }

  String _formatMinutes(int minutes) {
    if (minutes >= 60) {
      final hours = minutes / 60;
      return '${hours.toStringAsFixed(minutes % 60 == 0 ? 0 : 1)}h';
    }
    return '${minutes}m';
  }
}

// ==================================================================================================================
// Trend pill
// ==================================================================================================================

class _TrendPill extends StatelessWidget {
  final ({double percentChange, bool improvement}) trend;

  const _TrendPill({
    required this.trend,
  });

  @override
  Widget build(BuildContext context) {
    final percent = trend.percentChange.abs().toStringAsFixed(0);
    final sameAsLastWeek = trend.percentChange == 0;

    final Color color;
    final IconData icon;
    final String label;
    if (sameAsLastWeek) {
      color = Colors.white.withValues(alpha: 0.85);
      icon = FluentIcons.line_horizontal_1_24_regular;
      label = context.locale.analysis_no_change;
    } else if (trend.improvement) {
      color = const Color(0xFFA5D6A7);
      icon = FluentIcons.arrow_down_12_filled;
      label = context.locale.analysis_trend_less(percent);
    } else {
      color = const Color(0xFFEF9A9A);
      icon = FluentIcons.arrow_up_12_filled;
      label = context.locale.analysis_trend_more(percent);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Flexible(
            child: StyledText(
              label,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================================================================
// Summary row
// ==================================================================================================================

class _SummaryStat extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledText(
            label,
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          StyledText(
            value,
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SummaryDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white.withValues(alpha: 0.16),
    );
  }
}

// ==================================================================================================================
// Loading & error states
// ==================================================================================================================

class _AnalysisLoadingCard extends StatelessWidget {
  const _AnalysisLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: const Center(
        child: SizedBox.square(
          dimension: 28,
          child: CircularProgressIndicator(strokeCap: StrokeCap.round),
        ),
      ),
    );
  }
}

class _AnalysisErrorCard extends StatelessWidget {
  final String message;

  const _AnalysisErrorCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(FluentIcons.error_circle_20_filled, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: StyledText(
              message,
              fontSize: 13,
              color: colorScheme.onErrorContainer,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
