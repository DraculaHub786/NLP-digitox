// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/glassmorphic_container.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final _leaderboardService = LeaderboardService.instance;
  
  List<LeaderboardUser> _leaderboardData = [];
  LeaderboardUser? _currentUserData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }

  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await _leaderboardService.getTopUsers(limit: 100);
      final currentUser = await _leaderboardService.getCurrentUserData();

      setState(() {
        _leaderboardData = users;
        _currentUserData = currentUser;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load leaderboard';
        _isLoading = false;
      });
    }
  }

  Map<String, int> get _pointsBreakdown =>
      _currentUserData?.pointsBreakdown ?? {};

  int get _totalPoints =>
      _pointsBreakdown.isEmpty ? 0 : _pointsBreakdown.values.reduce((a, b) => a + b);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary.withOpacity(0.05),
              colorScheme.secondary.withOpacity(0.05),
            ],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _leaderboardService.clearCache();
              await _loadLeaderboardData();
            },
            child: _isLoading
                ? _buildLoadingState()
                : _errorMessage != null
                    ? _buildErrorState(colorScheme)
                    : _leaderboardData.isEmpty
                        ? _buildEmptyState(colorScheme)
                        : _buildLeaderboard(colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(ColorScheme colorScheme) {
    return Center(
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
            _errorMessage ?? 'An error occurred',
            fontSize: 16,
            color: colorScheme.error,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadLeaderboardData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
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
            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(ColorScheme colorScheme) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          title: ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                colorScheme.primary,
                colorScheme.secondary,
              ],
            ).createShader(bounds),
            child: const Text(
              'Leaderboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(FluentIcons.arrow_clockwise_20_regular),
              onPressed: () {
                _leaderboardService.clearCache();
                _loadLeaderboardData();
              },
              tooltip: 'Refresh',
            ),
          ],
        ),

        // Stats Cards
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverToBoxAdapter(
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
                // Streak Card
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
              ],
            ),
          ),
        ),

              // Points Breakdown Section
              if (_pointsBreakdown.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverToBoxAdapter(
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
                        GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: _pointsBreakdown.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary.withOpacity(0.1),
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
                                          ),
                                          const SizedBox(height: 4),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: entry.value / _totalPoints,
                                              backgroundColor: colorScheme.surfaceVariant,
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
                                    StyledText(
                                      '${entry.value}',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.primary,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

              // Leaderboard Title
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12, left: 4),
                    child: StyledText(
                      'Top Users',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Leaderboard List
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final user = _leaderboardData[index];
                      final isCurrentUser = user.isCurrentUser;
                      final rank = user.rank;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              // Rank Badge
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: _getRankGradient(rank, colorScheme),
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: _getRankGradient(rank, colorScheme)[0]
                                          .withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: StyledText(
                                    rank <= 3 ? _getRankEmoji(rank) : '#$rank',
                                    fontSize: rank <= 3 ? 20 : 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Avatar
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colorScheme.surfaceVariant,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Center(
                                  child: Text(
                                    user.avatarEmoji ?? '👤',
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // User Info
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    StyledText(
                                      user.username,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                      color: isCurrentUser
                                          ? colorScheme.primary
                                          : null,
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        if (user.streak > 0) ...[
                                          Icon(
                                            FluentIcons.fire_20_filled,
                                            size: 14,
                                            color: user.streak >= 7
                                                ? Colors.orange
                                                : colorScheme.onSurfaceVariant
                                                    .withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 4),
                                          StyledText(
                                            '${user.streak} ${user.streak == 1 ? 'day' : 'days'}',
                                            fontSize: 12,
                                            fontWeight: user.streak >= 7
                                                ? FontWeight.w600
                                                : FontWeight.normal,
                                            color: user.streak >= 7
                                                ? Colors.orange
                                                : colorScheme.onSurfaceVariant,
                                          ),
                                        ] else ...[
                                          Icon(
                                            FluentIcons.sparkle_20_regular,
                                            size: 14,
                                            color: colorScheme.onSurfaceVariant
                                                .withOpacity(0.5),
                                          ),
                                          const SizedBox(width: 4),
                                          StyledText(
                                            'Start your streak!',
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant
                                                .withOpacity(0.7),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              // Points
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  StyledText(
                                    '${user.points}',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: colorScheme.primary,
                                  ),
                                  const SizedBox(height: 2),
                                  StyledText(
                                    'points',
                                    fontSize: 12,
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: _leaderboardData.length,
                  ),
                ),
              ),

              // How to Earn Points Section
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverToBoxAdapter(
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FluentIcons.info_20_filled,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            StyledText(
                              'How to Earn Points',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildPointsInfoRow(
                          icon: FluentIcons.phone_20_regular,
                          title: 'Stay within screen time goals',
                          points: '+50 pts/day',
                        ),
                        _buildPointsInfoRow(
                          icon: FluentIcons.heart_pulse_20_regular,
                          title: 'Complete wellbeing activities',
                          points: '+30 pts/activity',
                        ),
                        _buildPointsInfoRow(
                          icon: FluentIcons.weather_sunny_20_regular,
                          title: 'Maintain daily streaks',
                          points: '+15 pts/day',
                        ),
                        _buildPointsInfoRow(
                          icon: FluentIcons.sleep_20_regular,
                          title: 'Follow bedtime schedule',
                          points: '+25 pts/night',
                        ),
                        _buildPointsInfoRow(
                          icon: FluentIcons.shield_checkmark_20_regular,
                          title: 'Respect app restrictions',
                          points: '+10 pts/day',
                          isLast: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
  }

  Widget _buildPointsInfoRow({
    required IconData icon,
    required String title,
    required String points,
    bool isLast = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StyledText(
              title,
              fontSize: 14,
            ),
          ),
          StyledText(
            points,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: colorScheme.primary,
          ),
        ],
      ),
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
        return [const Color(0xFFFFD700), const Color(0xFFFFAA00)]; // Gold
      case 2:
        return [const Color(0xFFC0C0C0), const Color(0xFF808080)]; // Silver
      case 3:
        return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
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
