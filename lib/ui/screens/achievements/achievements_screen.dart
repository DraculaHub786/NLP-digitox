import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/ui/common/modern_background.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';

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

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Achievements'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ModernGradientBackground(
        child: SafeArea(
          child: StreamBuilder<List<LeaderboardUser>>(
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

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00D6FF).withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFF00D6FF).withValues(alpha: 0.35),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFF00D6FF).withValues(alpha: 0.20),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                FluentIcons.ribbon_star_20_filled,
                                color: Color(0xFF007F99),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Achievements Earned',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text('Digital badges (cyclic preview)'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
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
                                  color: const Color(0xFF00D6FF).withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFF00D6FF).withValues(alpha: 0.35),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 24,
                                      backgroundColor:
                                          const Color(0xFF00D6FF).withValues(alpha: 0.22),
                                      child: const Icon(
                                        FluentIcons.ribbon_star_20_filled,
                                        color: Color(0xFF007F99),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        labels[index],
                                        style: const TextStyle(fontWeight: FontWeight.w600),
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
                  const SizedBox(height: 16),
                  ModernDashboardCard(
                    title: 'Lifetime Points',
                    subtitle: 'Total points earned (all time)',
                    icon: const Icon(FluentIcons.chart_multiple_20_filled),
                    accentColor: colorScheme.primary,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Total Lifetime Points',
                              style: TextStyle(fontSize: 16),
                            ),
                            Text(
                              '${currentUser?.lifetimePoints ?? 0}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if ((currentUser?.pointsBreakdown ?? {}).isNotEmpty) ...[
                        const SizedBox(height: 8),
                        const Divider(),
                        const SizedBox(height: 8),
                        const Text(
                          'This Week\'s Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        ...(currentUser!.pointsBreakdown!.entries.map(
                          (e) => Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(e.key)),
                                Text(
                                  '${e.value}',
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          ),
                        )),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  ModernDashboardCard(
                    title: 'Badges',
                    subtitle: 'Coming soon',
                    icon: const Icon(FluentIcons.badge_20_filled),
                    accentColor: colorScheme.tertiary,
                    children: const [
                      Text('No badges yet. This section will be updated in future.'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ModernDashboardCard(
                    title: 'Max Streaks',
                    subtitle: 'Across productivity and leaderboard',
                    icon: const Icon(FluentIcons.trophy_20_filled),
                    accentColor: Colors.orange,
                    children: [
                      if (_loadingStreaks)
                        const Center(child: CircularProgressIndicator())
                      else ...[
                        _StreakRow(label: 'Habits max streak', value: _maxHabitStreak),
                        const SizedBox(height: 10),
                        _StreakRow(label: 'Tasks/Todos max streak', value: _maxTaskStreak),
                        const SizedBox(height: 10),
                        _StreakRow(label: 'Leaderboard streak', value: leaderboardStreak),
                      ],
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _StreakRow extends StatelessWidget {
  const _StreakRow({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(child: Text(label)),
        Text(
          '$value',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
