import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _leaderboardService = LeaderboardService.instance;

  Map<String, dynamic>? _weekInfo;
  bool _isLoadingWeekInfo = true;

  @override
  void initState() {
    super.initState();
    _loadWeekInfo();
  }

  Future<void> _loadWeekInfo() async {
    try {
      final weekInfo = await _leaderboardService.getLeaderboardWeekInfo();
      if (mounted) {
        setState(() {
          _weekInfo = weekInfo;
          _isLoadingWeekInfo = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading week info: $e');
      if (mounted) {
        setState(() => _isLoadingWeekInfo = false);
      }
    }
  }

  Map<String, int> get _pointsBreakdown =>
      _currentUserData?.pointsBreakdown ?? {};

  int get _totalPoints =>
      _pointsBreakdown.isEmpty ? 0 : _pointsBreakdown.values.reduce((a, b) => a + b);

  String _getResetTimeText() {
    if (_weekInfo == null) return 'Loading...';

    final daysUntilReset = _weekInfo!['daysUntilReset'] as int? ?? 0;
    final hoursUntilReset = _weekInfo!['hoursUntilReset'] as int? ?? 0;

    if (hoursUntilReset < 1) {
      return 'Resetting now!';
    } else if (hoursUntilReset < 24) {
      return 'Resets in ${hoursUntilReset}h at Monday 4 AM';
    } else if (daysUntilReset == 1) {
      return 'Resets tomorrow at 4 AM';
    } else {
      return 'Resets Monday at 4 AM (${daysUntilReset}d)';
    }
  }

  LeaderboardUser? _currentUserData;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return StreamBuilder<List<LeaderboardUser>>(
      stream: _leaderboardService.streamTopUsers(limit: 100),
      builder: (context, snapshot) {
        final isLoading = snapshot.connectionState == ConnectionState.waiting;
        final hasError = snapshot.hasError;
        final users = snapshot.data ?? <LeaderboardUser>[];

        _currentUserData = users.cast<LeaderboardUser?>().firstWhere(
          (u) => u?.isCurrentUser == true,
          orElse: () => null,
        );

        return DefaultRefreshIndicator(
          onRefresh: () async {
            _leaderboardService.clearCache();
            _currentUserData = null;
            _isLoadingWeekInfo = true;
            setState(() {});
            await _loadWeekInfo();
          },
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (isLoading && users.isEmpty)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (hasError && users.isEmpty)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FluentIcons.error_circle_20_filled,
                          size: 64,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 16),
                        StyledText(
                          'Failed to load leaderboard',
                          fontSize: 16,
                          color: colorScheme.error,
                        ),
                        const SizedBox(height: 8),
                        StyledText(
                          'Pull down to retry',
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                )
              else ...[
                if (hasError && users.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              FluentIcons.info_20_filled,
                              size: 18,
                              color: colorScheme.onErrorContainer,
                            ),
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
                    ),
                  ),

                // Stats Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ModernMetricCard(
                                label: "Your Points",
                                value: _totalPoints.toString(),
                                icon: FluentIcons.trophy_20_filled,
                                color: colorScheme.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernMetricCard(
                                label: "Current Rank",
                                value: _currentUserData != null
                                    ? "#${_currentUserData!.rank}"
                                    : "-",
                                icon: FluentIcons.star_20_filled,
                                color: colorScheme.tertiary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ModernMetricCard(
                          label: _currentUserData?.streak != null && _currentUserData!.streak > 0
                              ? "Day Streak"
                              : "Build Your Streak",
                          value: _currentUserData?.streak != null && _currentUserData!.streak > 0
                              ? "${_currentUserData!.streak} ${_currentUserData!.streak == 1 ? 'day' : 'days'}"
                              : "Get started!",
                          icon: _currentUserData?.streak != null && _currentUserData!.streak >= 7
                              ? FluentIcons.fire_20_filled
                              : FluentIcons.target_20_regular,
                          color: _currentUserData?.streak != null && _currentUserData!.streak >= 7
                              ? Colors.orange
                              : colorScheme.secondary,
                        ),
                        if (!_isLoadingWeekInfo && _weekInfo != null) ...[
                          const SizedBox(height: 12),
                          ModernDashboardCard(
                            title: 'Weekly Reset',
                            subtitle: _getResetTimeText(),
                            icon: const Icon(FluentIcons.calendar_clock_20_regular),
                            accentColor: colorScheme.primary,
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.secondaryContainer,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: StyledText(
                                'Week ${_weekInfo!['weekNumber'] ?? '?'}',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSecondaryContainer,
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),

                // Points Breakdown
                if (_pointsBreakdown.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12, left: 4),
                            child: StyledText(
                              'Points Breakdown',
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ModernDashboardCard(
                            title: 'Breakdown',
                            subtitle: 'How your points are distributed',
                            icon: const Icon(FluentIcons.chart_multiple_20_filled),
                            accentColor: colorScheme.primary,
                            children: _pointsBreakdown.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withValues(alpha: 0.1),
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
                                        crossAxisAlignment: CrossAxisAlignment.start,
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
                                              value: entry.value / _totalPoints,
                                              backgroundColor: colorScheme.surfaceContainerHighest,
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

                // Top Users Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
                    child: StyledText(
                      'Top Users',
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
                            Icon(
                              FluentIcons.people_20_regular,
                              size: 64,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 16),
                            StyledText(
                              'No users on the leaderboard yet',
                              fontSize: 16,
                              color: colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(height: 8),
                            StyledText(
                              'Be the first to earn points!',
                              fontSize: 14,
                              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else if (users.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final user = users[index];
                        final isCurrentUser = user.isCurrentUser;
                        final rank = user.rank;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _buildUserTile(context, user, rank, isCurrentUser, colorScheme),
                        );
                      },
                      childCount: users.length,
                    ),
                  ),

                // How to Earn Points
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                    child: ModernDashboardCard(
                      title: 'How to Earn Points',
                      icon: const Icon(FluentIcons.info_20_filled),
                      accentColor: colorScheme.primary,
                      children: [
                        _buildPointsInfoRow(
                          context,
                          icon: FluentIcons.phone_20_regular,
                          title: 'Stay within screen time goals',
                          points: '+50 pts/day',
                        ),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(
                          context,
                          icon: FluentIcons.heart_pulse_20_regular,
                          title: 'Complete wellbeing activities',
                          points: '+30 pts/activity',
                        ),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(
                          context,
                          icon: FluentIcons.weather_sunny_20_regular,
                          title: 'Maintain daily streaks',
                          points: '+15 pts/day',
                        ),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(
                          context,
                          icon: FluentIcons.sleep_20_regular,
                          title: 'Follow bedtime schedule',
                          points: '+25 pts/night',
                        ),
                        const SizedBox(height: 12),
                        _buildPointsInfoRow(
                          context,
                          icon: FluentIcons.shield_checkmark_20_regular,
                          title: 'Respect app restrictions',
                          points: '+10 pts/day',
                        ),
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

  Widget _buildUserTile(BuildContext context, LeaderboardUser user, int rank, bool isCurrentUser, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _getRankGradient(rank, colorScheme),
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: _getRankGradient(rank, colorScheme)[0].withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: StyledText(
                rank <= 3 ? _getRankEmoji(rank) : '#$rank',
                fontSize: rank <= 3 ? 20 : 15,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  isCurrentUser ? 'You' : user.username,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isCurrentUser ? colorScheme.primary : colorScheme.onSurface,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  user.streak > 0
                      ? '${user.streak} ${user.streak == 1 ? 'day' : 'days'} 🔥'
                      : 'Start your streak!',
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: StyledText(
                  '${user.points}',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: colorScheme.primary,
                ),
              ),
              StyledText(
                'points',
                fontSize: 11,
                color: colorScheme.onSurfaceVariant,
                maxLines: 1,
              ),
            ],
          ),
        ],
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
          child: StyledText(
            title,
            fontSize: 14,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Flexible(
          flex: 0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: StyledText(
              points,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
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

  List<Color> _getRankGradient(int rank, ColorScheme colorScheme) {
    switch (rank) {
      case 1:
        return [const Color(0xFFFFD700), const Color(0xFFFFAA00)];
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)];
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)];
      default:
        return [colorScheme.primary, colorScheme.secondary];
    }
  }

  String _getRankEmoji(int rank) {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return '#$rank';
    }
  }
}
