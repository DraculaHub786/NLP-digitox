import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/leaderboard_service.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart' hide ModernListTile;
import 'package:nlp_digitox/ui/common/profile_avatar.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// Dedicated Profile screen — displays the user's identity and live stats at
/// a glance. Account-management actions (password/email) stay in Settings →
/// Account; this screen only links out to them.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _changeProfilePicture(BuildContext context) async {
    try {
      await ProfileService.instance.uploadProfilePicture();
      ProfileService.instance.clearCache();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile picture updated'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update picture: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final username =
        ref.watch(digitoxSettingsProvider.select((v) => v.username));
    final email = FirebaseAuthService.instance.userEmail;

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.person_20_regular,
          filledIcon: FluentIcons.person_20_filled,
          titleText: 'Profile',
          sliverBody: StreamBuilder<List<LeaderboardUser>>(
            stream: LeaderboardService.instance.streamTopUsers(limit: 100),
            builder: (context, snapshot) {
              final users = snapshot.data ?? const <LeaderboardUser>[];
              LeaderboardUser? currentUser;
              for (final user in users) {
                if (user.isCurrentUser) {
                  currentUser = user;
                  break;
                }
              }

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Identity card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: SurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            GestureDetector(
                              onTap: () => _changeProfilePicture(context),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: colorScheme.primary,
                                        width: 2,
                                      ),
                                    ),
                                    child: const ProfileAvatar(size: 84),
                                  ),
                                  Positioned(
                                    right: 0,
                                    bottom: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: colorScheme.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        FluentIcons.camera_20_regular,
                                        size: 14,
                                        color: colorScheme.onPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            StyledText(
                              username,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              isHeadline: true,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (email != null) ...[
                              const SizedBox(height: 4),
                              StyledText(
                                email,
                                fontSize: 14,
                                color:
                                    colorScheme.onSurface.withValues(alpha: 0.6),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 8),
                            StyledText(
                              'Tap the photo to change it',
                              fontSize: 11,
                              color:
                                  colorScheme.onSurface.withValues(alpha: 0.5),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Stats row
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
                              color: DesignPalette.goldWarm,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Rank card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernDashboardCard(
                        title: 'Current Rank',
                        subtitle: currentUser != null
                            ? 'Rank #${currentUser.rank} on the leaderboard'
                            : 'Not ranked yet — start earning points',
                        icon: const Icon(FluentIcons.trophy_20_filled),
                        accentColor: DesignPalette.goldWarm,
                        children: [
                          if ((currentUser?.pointsBreakdown ?? {}).isNotEmpty)
                            ...currentUser!.pointsBreakdown!.entries.take(3).map(
                                  (e) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: StyledText(
                                            e.key,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        StyledText(
                                          '${e.value}',
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.primary,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ),

                  // Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Column(
                        children: [
                          ModernListTile(
                            title: 'View Achievements',
                            subtitle: 'Your earned badges and stats',
                            icon: FluentIcons.ribbon_star_20_regular,
                            iconColor: colorScheme.primary,
                            onTap: () => Navigator.of(context)
                                .pushNamed(AppRoutes.achievementsPath),
                          ),
                          const SizedBox(height: 10),
                          ModernListTile(
                            title: 'Account Settings',
                            subtitle: 'Password, email & display name',
                            icon: FluentIcons.settings_20_regular,
                            iconColor: colorScheme.tertiary,
                            onTap: () => Navigator.of(context).pushNamed(
                              AppRoutes.settingsPath,
                              arguments: 1,
                            ),
                          ),
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
