import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/extensions/ext_num.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
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
  final _firestore = FirebaseFirestore.instance;

  int _maxHabitStreak = 0;
  int _maxTaskStreak = 0;
  bool _loadingStreaks = true;
  PageController? _badgePageController;
  int _currentBadgePage = 0;
  Timer? _badgeAutoSlideTimer;
  List<Map<String, dynamic>> _badges = [];
  bool _loadingBadges = true;

  @override
  void initState() {
    super.initState();
    _loadProductivityStreaks();
    _loadBadges();
    _startBadgeCarouselAutoSlide();
  }

  @override
  void dispose() {
    _badgeAutoSlideTimer?.cancel();
    _badgePageController?.dispose();
    super.dispose();
  }

  void _startBadgeCarouselAutoSlide() {
    _badgeAutoSlideTimer?.cancel();
    _badgeAutoSlideTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (!mounted || _badgePageController == null || !_badgePageController!.hasClients) return;
      final count = _badges.isEmpty ? 1 : _badges.length;
      final nextPage = (_currentBadgePage + 1) % count;
      if (_badgePageController!.hasClients) {
        await _badgePageController!.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
        _currentBadgePage = nextPage;
      }
    });
  }

  /// Fetch badges from Firestore where uid == currentUser.uid, ordered by awardedAt desc
  Future<void> _loadBadges() async {
    try {
      final uid = FirebaseAuthService.instance.userId;
      if (uid == null) {
        if (mounted) setState(() => _loadingBadges = false);
        return;
      }

      final snapshot = await _firestore
          .collection('badges')
          .where('userId', isEqualTo: uid)
          .orderBy('awardedAt', descending: true)
          .get();

      if (mounted) {
        setState(() {
          _badges = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
          _loadingBadges = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading badges: $e');
      if (mounted) setState(() => _loadingBadges = false);
    }
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

                  // Badge carousel — live from Firestore
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernDashboardCard(
                        title: 'Badges',
                        icon: const Icon(FluentIcons.ribbon_star_20_filled),
                        accentColor: colorScheme.primary,
                        children: [
                          if (_loadingBadges)
                            const SizedBox(
                              height: 80,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else if (_badges.isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: StyledText('No badges yet. Complete challenges to earn your first badge!'),
                            )
                          else
                            SizedBox(
                              height: 130,
                              child: PageView.builder(
                                controller: _badgePageController,
                                itemCount: _badges.length,
                                onPageChanged: (index) {
                                  _currentBadgePage = index;
                                },
                                itemBuilder: (context, index) {
                                  final badge = _badges[index];
                                  final badgeName = badge['badgeName'] as String? ?? 'Badge';
                                  final badgeUrl = badge['badgeUrl'] as String?;
                                  final awardedAt = (badge['awardedAt'] as Timestamp?)?.toDate();
                                  final verificationId = badge['verificationId'] as String?;
                                  final formattedDate = awardedAt != null
                                      ? '${awardedAt.day}/${awardedAt.month}/${awardedAt.year}'
                                      : '';

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
                                          backgroundImage: badgeUrl != null
                                              ? NetworkImage(badgeUrl)
                                              : null,
                                          child: badgeUrl == null
                                              ? Icon(
                                                  FluentIcons.ribbon_star_20_filled,
                                                  color: colorScheme.primary,
                                                )
                                              : null,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              StyledText(
                                                badgeName,
                                                fontWeight: FontWeight.w600,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (formattedDate.isNotEmpty)
                                                StyledText(
                                                  formattedDate,
                                                  fontSize: 12,
                                                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                                                  maxLines: 1,
                                                ),
                                              if (verificationId != null && verificationId.isNotEmpty)
                                                StyledText(
                                                  verificationId,
                                                  fontSize: 11,
                                                  color: colorScheme.tertiary,
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          if (_badges.length > 1)
                            const SizedBox(height: 8),
                          if (_badges.length > 1)
                            Center(
                              child: StyledText(
                                '${_currentBadgePage + 1} / ${_badges.length}',
                                fontSize: 12,
                                color: colorScheme.onSurface.withValues(alpha: 0.5),
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

                  // Badges section removed — now shown in the carousel above

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
