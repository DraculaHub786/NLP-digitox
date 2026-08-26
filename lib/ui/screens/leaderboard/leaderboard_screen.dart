import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/default_segmented_button.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/leaderboard/podium_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _leaderboardService = LeaderboardService.instance;

  LeaderboardPeriod _period = LeaderboardPeriod.weekly;

  final Map<LeaderboardPeriod, LeaderboardResetInfo?> _resetInfo = {};
  bool _isLoadingResetInfo = true;

  LeaderboardUser? _currentUserData;

  @override
  void initState() {
    super.initState();
    _loadResetInfo();
  }

  Future<void> _loadResetInfo() async {
    setState(() => _isLoadingResetInfo = true);
    try {
      final results = await Future.wait([
        _leaderboardService.getResetInfo(LeaderboardPeriod.weekly),
        _leaderboardService.getResetInfo(LeaderboardPeriod.monthly),
      ]);
      if (!mounted) return;
      setState(() {
        _resetInfo[LeaderboardPeriod.weekly] = results[0];
        _resetInfo[LeaderboardPeriod.monthly] = results[1];
        _isLoadingResetInfo = false;
      });
    } catch (e) {
      debugPrint('Error loading reset info: $e');
      if (mounted) setState(() => _isLoadingResetInfo = false);
    }
  }

  Map<String, int> get _pointsBreakdown =>
      _period == LeaderboardPeriod.weekly
          ? (_currentUserData?.pointsBreakdown ?? {})
          : {};

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<LeaderboardUser>>(
      key: ValueKey(_period),
      stream: _leaderboardService.streamTopUsers(period: _period, limit: 100),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final users = snapshot.data ?? <LeaderboardUser>[];

        _currentUserData = users.cast<LeaderboardUser?>().firstWhere(
              (u) => u?.isCurrentUser == true,
              orElse: () => null,
            );

        final top3 = users.take(3).toList();
        final rest = users.length > 3 ? users.sublist(3) : <LeaderboardUser>[];

        return DefaultRefreshIndicator(
          onRefresh: () async {
            _leaderboardService.clearCache();
            _currentUserData = null;
            setState(() {});
            await _loadResetInfo();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Period switcher
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                  child: Center(
                    child: DefaultSegmentedButton<LeaderboardPeriod>(
                      selected: _period,
                      onChanged: (value) => setState(() => _period = value),
                      segments: const [
                        SegmentItem(
                          value: LeaderboardPeriod.weekly,
                          label: 'Weekly',
                          icon: FluentIcons.calendar_ltr_20_regular,
                        ),
                        SegmentItem(
                          value: LeaderboardPeriod.monthly,
                          label: 'Monthly',
                          icon: FluentIcons.calendar_month_20_regular,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              if (isLoading && users.isEmpty)
                SliverToBoxAdapter(child: _buildSkeletonLoading(colorScheme))
              else if (hasError && users.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(FluentIcons.error_circle_20_filled,
                            size: 64, color: colorScheme.error),
                        const SizedBox(height: 16),
                        StyledText('Failed to load leaderboard',
                            fontSize: 16, color: colorScheme.error),
                        const SizedBox(height: 8),
                        StyledText('Pull down to retry',
                            fontSize: 14, color: colorScheme.onSurfaceVariant),
                      ],
                    ),
                  ),
                )
              else ...[
                if (hasError && users.isNotEmpty)
                  SliverToBoxAdapter(child: _buildInlineErrorBanner(colorScheme)),

                // Stat cards — period-aware points + rank, lifetime + streak
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _AnimatedMetricCard(
                                label: '${_period.label} Points',
                                value: _currentUserData?.scoreFor(_period) ?? 0,
                                icon: FluentIcons.trophy_20_filled,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernMetricCard(
                                label: 'Current Rank',
                                value: _currentUserData != null
                                    ? '#${_currentUserData!.rank}'
                                    : '-',
                                icon: FluentIcons.star_20_filled,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _AnimatedMetricCard(
                                label: 'Lifetime Points',
                                value: _currentUserData?.lifetimePoints ?? 0,
                                icon: FluentIcons.trophy_lock_20_filled,
                                color: colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernMetricCard(
                                label: (_currentUserData?.streak ?? 0) > 0
                                    ? 'Day Streak'
                                    : 'Build Streak',
                                value: (_currentUserData?.streak ?? 0) > 0
                                    ? '${_currentUserData!.streak} '
                                        '${_currentUserData!.streak == 1 ? 'day' : 'days'}'
                                    : 'Get started!',
                                icon: (_currentUserData?.streak ?? 0) >= 7
                                    ? FluentIcons.fire_20_filled
                                    : FluentIcons.target_20_regular,
                                color: (_currentUserData?.streak ?? 0) >= 7
                                    ? DesignPalette.streakFire
                                    : colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                        if (!_isLoadingResetInfo) ...[
                          const SizedBox(height: 12),
                          _buildResetCard(colorScheme),
                        ],
                      ],
                    ),
                  ),
                ),

                // Podium (top 3) — rank 2 | rank 1 | rank 3 on a shared
                // bottom edge; #1 is taller and more elevated than #2/#3.
                if (top3.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 24),
                      child: _LeaderboardPodium(
                        top3: top3,
                        period: _period,
                        colorScheme: colorScheme,
                      ).animate().fadeIn(duration: 400.ms).slideY(
                            begin: 0.08,
                            end: 0,
                            duration: 400.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    ),
                  ),

                // Points Breakdown — weekly only (breakdown is a weekly-scoped field)
                if (_pointsBreakdown.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(bottom: 12, left: 4),
                            child: StyledText(
                              'This Week\'s Breakdown',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ModernDashboardCard(
                            title: 'Breakdown',
                            subtitle: 'How your weekly points are distributed',
                            icon: const Icon(FluentIcons.chart_multiple_20_filled),
                            accentColor: colorScheme.primary,
                            children: _pointsBreakdown.entries.map((entry) {
                              final total = _pointsBreakdown.values
                                  .fold<int>(0, (a, b) => a + b);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary
                                            .withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _getIconForCategory(entry.key),
                                        size: 20,
                                        color: colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          StyledText(
                                            entry.key,
                                            fontWeight: FontWeight.w500,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: total == 0
                                                  ? 0
                                                  : entry.value / total,
                                              backgroundColor:
                                                  colorScheme.surfaceContainerHighest,
                                              valueColor: AlwaysStoppedAnimation(
                                                colorScheme.primary,
                                              ),
                                              minHeight: 6,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Flexible(
                                      flex: 0,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: StyledText(
                                          '${entry.value}',
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: StyledText(
                      users.length > 3 ? 'Rest of the Board' : 'Top Users',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                if (users.isEmpty && !isLoading)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(FluentIcons.people_20_regular,
                                size: 64, color: colorScheme.onSurfaceVariant),
                            const SizedBox(height: 16),
                            StyledText(
                              'No ${_period.label.toLowerCase()} activity yet',
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            StyledText(
                              'Be the first to earn points!',
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant
                                  .withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (rest.isNotEmpty)
                  SliverToBoxAdapter(
                    child: SurfaceCard(
                      padding: EdgeInsets.zero,
                      elevation: 0,
                      child: Column(
                        children: [
                          for (final user in rest) ...[
                            DefaultListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor:
                                    colorScheme.primary.withValues(alpha: 0.12),
                                child: Text(
                                  '#${user.rank}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ),
                              titleText: user.isCurrentUser ? 'You' : user.username,
                              subtitleText: user.streak > 0
                                  ? '${user.streak} '
                                      '${user.streak == 1 ? 'day' : 'days'} 🔥'
                                  : 'Start your streak!',
                              trailing: Text(
                                '${user.scoreFor(_period)} points',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: user.isCurrentUser
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              accent: user.isCurrentUser
                                  ? colorScheme.primary
                                  : null,
                              isPrimary: user.isCurrentUser,
                            ),
                            if (user != rest.last)
                              const Divider(height: 0.5, indent: 56),
                          ],
                        ],
                      ),
                    ),
                  ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 4, 16),
                    child: ModernDashboardCard(
                      title: 'How to Earn Points',
                      icon: const Icon(FluentIcons.info_20_filled),
                      accentColor: colorScheme.primary,
                      children: [
                        _buildPointsInfoRow(context,
                            icon: FluentIcons.phone_20_regular,
                            title: 'Stay within screen time goals',
                            points: '+50 pts/day'),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(context,
                            icon: FluentIcons.heart_pulse_20_regular,
                            title: 'Complete wellbeing activities',
                            points: '+30 pts/activity'),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(context,
                            icon: FluentIcons.weather_sunny_20_regular,
                            title: 'Maintain daily streaks',
                            points: '+15 pts/day'),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(context,
                            icon: FluentIcons.sleep_20_regular,
                            title: 'Follow bedtime schedule',
                            points: '+25 pts/night'),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(context,
                            icon: FluentIcons.shield_checkmark_20_regular,
                            title: 'Respect app restrictions',
                            points: '+10 pts/day'),
                      ],
                    ),
                  ),
                ),

                const SliverTabsBottomPadding(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildInlineErrorBanner(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        child: Row(
          children: [
            Icon(FluentIcons.info_20_filled,
                size: 18, color: colorScheme.onErrorContainer),
            const SizedBox(width: 8),
            Expanded(
              child: StyledText(
                'Some data couldn\'t update. Pull down to retry.',
                fontSize: 13,
                color: colorScheme.onErrorContainer,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResetCard(ColorScheme colorScheme) {
    final info = _resetInfo[_period];
    final subtitle = info?.resetCountdownLabel ?? 'Reset schedule unavailable';

    return ModernDashboardCard(
      title: '${_period.label} Reset',
      subtitle: subtitle,
      icon: const Icon(FluentIcons.calendar_clock_20_regular),
      accentColor: colorScheme.primary,
      trailing: info != null
          ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
              child: StyledText(
                'Cycle ${info.cycleNumber}',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSecondaryContainer,
                maxLines: 1,
              ),
            )
          : null,
    );
  }

  Widget _buildSkeletonLoading(ColorScheme colorScheme) {
    return Skeletonizer(
      enabled: true,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: ModernMetricCard(
                    label: 'Weekly Points',
                    value: '1234',
                    icon: FluentIcons.trophy_20_filled,
                    color: colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernMetricCard(
                    label: 'Current Rank',
                    value: '#12',
                    icon: FluentIcons.star_20_filled,
                    color: colorScheme.tertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(
              6,
              (i) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  height: 76,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(Radii.xl),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPointsInfoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String points,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: StyledText(title,
              fontSize: 14, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
        Flexible(
          flex: 0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: StyledText(points,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colorScheme.primary),
          ),
        ),
      ],
    );
  }

  IconData _getIconForCategory(String category) {
    switch (category) {
      case 'Screen Time Goals':
        return FluentIcons.phone_20_filled;
      case 'Wellbeing Activities':
        return FluentIcons.heart_pulse_20_filled;
      case 'Daily Streaks':
        return FluentIcons.fire_20_filled;
      case 'Bedtime Adherence':
        return FluentIcons.sleep_20_filled;
      case 'App Restrictions':
        return FluentIcons.shield_checkmark_20_filled;
      default:
        return FluentIcons.star_20_filled;
    }
  }
}

/// A `ModernMetricCard`-style card whose number animates (flip-counter)
/// whenever its value changes — used for point totals so switching between
/// Weekly/Monthly (or a live points update) feels alive instead of snapping.
///
/// Layout mirrors `ModernMetricCard` exactly (SurfaceCard, 20px padding,
/// `Radii.lg`, tinted fill, icon chip top-left, big value, label below) so
/// the point cards render identical in size/style to the rank/streak cards
/// beside them.
class _AnimatedMetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;
  final Color color;

  const _AnimatedMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final metricColor = color;

    return SurfaceCard(
      padding: const EdgeInsets.all(20),
      borderRadius: Radii.lg,
      tint: metricColor,
      elevation: 1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: metricColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: metricColor, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 16),
          AnimatedFlipCounter(
            value: value,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            textStyle: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: metricColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Top-3 podium — rank 1 elevated in the center, 2 on the left, 3 on the
/// right, matching the common "modern leaderboard" pattern.
class _LeaderboardPodium extends StatelessWidget {
  final List<LeaderboardUser> top3;
  final LeaderboardPeriod period;
  final ColorScheme colorScheme;

  const _LeaderboardPodium({
    required this.top3,
    required this.period,
    required this.colorScheme,
  });

  LeaderboardUser? _at(int rank) {
    for (final u in top3) {
      if (u.rank == rank) return u;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final first = _at(1);
    final second = _at(2);
    final third = _at(3);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: second != null
              ? PodiumCard(
                  rank: 2,
                  name: second.isCurrentUser ? 'You' : second.username,
                  points: second.scoreFor(period),
                  isCurrentUser: second.isCurrentUser,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: first != null
              ? PodiumCard(
                  rank: 1,
                  name: first.isCurrentUser ? 'You' : first.username,
                  points: first.scoreFor(period),
                  isCurrentUser: first.isCurrentUser,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(width: Spacing.sm),
        Expanded(
          child: third != null
              ? PodiumCard(
                  rank: 3,
                  name: third.isCurrentUser ? 'You' : third.username,
                  points: third.scoreFor(period),
                  isCurrentUser: third.isCurrentUser,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}
