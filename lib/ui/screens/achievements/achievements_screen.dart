import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  final _leaderboardService = LeaderboardService.instance;
  final _productivityService = ProductivityService.instance;

  int _maxHabitStreak = 0;
  int _maxTaskStreak = 0;
  bool _loadingStreaks = true;
  final PageController _badgePageController = PageController(viewportFraction: 0.9);
  int _currentBadgePage = 0;
  Timer? _badgeAutoSlideTimer;

  @override
  void initState() {
    super.initState();
    _loadProductivityStreaks();
    _startBadgeCarouselAutoSlide();
  }

  @override
  void dispose() {
    _badgeAutoSlideTimer?.cancel();
    _badgePageController.dispose();
    super.dispose();
  }

  void _startBadgeCarouselAutoSlide() {
    _badgeAutoSlideTimer?.cancel();
    _badgeAutoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || !_badgePageController.hasClients) return;
      final nextPage = (_currentBadgePage + 1) % 3;
      await _badgePageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      _currentBadgePage = nextPage;
    });
  }

  Future<void> _loadProductivityStreaks() async {
    try {
      final habits = await _productivityService.getHabits();
      final tasks = await _productivityService.getTasks();

      final maxHabitStreak = habits.isEmpty
          ? 0
          : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);

      final maxTaskStreak = _calculateMaxTaskStreak(tasks
          .where((t) => t.completedAt != null)
          .map((t) => DateTime(
                t.completedAt!.year,
                t.completedAt!.month,
                t.completedAt!.day,
              ))
          .toList());

      if (mounted) {
        setState(() {
          _maxHabitStreak = maxHabitStreak;
          _maxTaskStreak = maxTaskStreak;
          _loadingStreaks = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _maxHabitStreak = 0;
          _maxTaskStreak = 0;
          _loadingStreaks = false;
        });
      }
    }
  }

  int _calculateMaxTaskStreak(List<DateTime> completedDays) {
    if (completedDays.isEmpty) return 0;

    final uniqueSorted = completedDays.toSet().toList()..sort();
    int maxStreak = 1;
    int currentStreak = 1;

    for (int i = 1; i < uniqueSorted.length; i++) {
      final difference = uniqueSorted[i].difference(uniqueSorted[i - 1]).inDays;
      if (difference == 1) {
        currentStreak++;
        if (currentStreak > maxStreak) {
          maxStreak = currentStreak;
        }
      } else if (difference > 1) {
        currentStreak = 1;
      }
    }

    return maxStreak;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.ribbon_star_20_regular,
          filledIcon: FluentIcons.ribbon_star_20_filled,
          titleText: 'Achievements',
          sliverBody: StreamBuilder<List<LeaderboardUser>>(
            stream: _leaderboardService.streamTopUsers(limit: 100),
            builder: (context, snapshot) {
              final users = snapshot.data ?? const <LeaderboardUser>[];
              LeaderboardUser? currentUser;
              for (final user in users) {
                if (user.isCurrentUser) {
                  currentUser = user;
                  break;
                }
              }

              final leaderboardStreak = currentUser?.streak ?? 0;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Section header
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernSectionHeader(
                        title: 'Achievements Earned',
                        subtitle: 'Digital badges (cyclic preview)',
                        trailing: currentUser != null
                            ? Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: StyledText(
                                  '${currentUser.lifetimePoints} pts',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: colorScheme.onPrimaryContainer,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Badge carousel
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernDashboardCard(
                        title: 'Badge Carousel',
                        icon: const Icon(FluentIcons.ribbon_star_20_filled),
                        accentColor: colorScheme.primary,
                        children: [
                          SizedBox(
                            height: 130,
                            child: PageView.builder(
                              controller: _badgePageController,
                              itemCount: 3,
                              onPageChanged: (index) {
                                _currentBadgePage = index;
                              },
                              itemBuilder: (context, index) {
                                final labels = <String>[
                                  '7-Day Streak Badge (Coming soon)',
                                  '21-Day Streak Badge (Coming soon)',
                                  '30-Day Streak Badge (Coming soon)',
                                ];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 6),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: colorScheme.primary.withValues(alpha: 0.25),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor:
                                            colorScheme.primary.withValues(alpha: 0.22),
                                        child: Icon(
                                          FluentIcons.ribbon_star_20_filled,
                                          color: colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: StyledText(
                                          labels[index],
                                          fontWeight: FontWeight.w600,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  12.vSliverBox,

                  // Stats row: Lifetime points
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ModernMetricCard(
                              label: 'Lifetime Points',
                              value: '${currentUser?.lifetimePoints ?? 0}',
                              icon: FluentIcons.chart_multiple_20_filled,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ModernMetricCard(
                              label: 'Current Streak',
                              value: '${currentUser?.streak ?? 0}',
                              icon: FluentIcons.fire_20_filled,
                              color: leaderboardStreak >= 7 ? Colors.orange : colorScheme.tertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Points breakdown
                  if ((currentUser?.pointsBreakdown ?? {}).isNotEmpty) ...[
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                        child: ModernDashboardCard(
                          title: 'This Week\'s Breakdown',
                          icon: const Icon(FluentIcons.chart_multiple_20_filled),
                          accentColor: colorScheme.primary,
                          children: currentUser!.pointsBreakdown!.entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: StyledText(
                                      e.key,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: StyledText(
                                      '${e.value}',
                                      fontWeight: FontWeight.w700,
                                      color: colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ).toList(),
                        ),
                      ),
                    ),
                    12.vSliverBox,
                  ],

                  // Max Streaks section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernDashboardCard(
                        title: 'Max Streaks',
                        subtitle: 'Across productivity and leaderboard',
                        icon: const Icon(FluentIcons.trophy_20_filled),
                        accentColor: Colors.orange,
                        children: [
                          if (_loadingStreaks)
                            const Center(child: CircularProgressIndicator())
                          else ...[
                            _StreakRow(label: 'Habits max streak', value: _maxHabitStreak, colorScheme: colorScheme),
                            const SizedBox(height: 10),
                            _StreakRow(label: 'Tasks/Todos max streak', value: _maxTaskStreak, colorScheme: colorScheme),
                            const SizedBox(height: 10),
                            _StreakRow(label: 'Leaderboard streak', value: leaderboardStreak, colorScheme: colorScheme),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Badges section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernDashboardCard(
                        title: 'Badges',
                        subtitle: 'Coming soon',
                        icon: const Icon(FluentIcons.badge_20_filled),
                        accentColor: colorScheme.tertiary,
                        children: const [
                          StyledText('No badges yet. This section will be updated in future.'),
                        ],
                      ),
                    ),
                  ),

                  const SliverTabsBottomPadding(),
                ],
              );
            },
          ),
        )
      ],
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.label,
    required this.value,
    required this.colorScheme,
  });

  final String label;
  final int value;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: StyledText(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: StyledText(
            '$value',
            fontWeight: FontWeight.w700,
            color: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
