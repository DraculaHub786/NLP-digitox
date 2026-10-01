// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/hero_tags.dart';
import 'package:nlp_digitox/core/services/session_notifications.dart';
import 'package:nlp_digitox/features/groups/group_detail_screen.dart';
import 'package:nlp_digitox/features/groups/group_error_message.dart';
import 'package:nlp_digitox/features/groups/widgets/create_group_sheet.dart';
import 'package:nlp_digitox/features/groups/widgets/group_card.dart';
import 'package:nlp_digitox/features/groups/widgets/join_group_sheet.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/providers/group_provider.dart';
import 'package:nlp_digitox/ui/common/default_fab_button.dart';
import 'package:nlp_digitox/ui/common/default_refresh_indicator.dart';
import 'package:nlp_digitox/ui/common/default_segmented_button.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// The two panes of the groups screen.
enum GroupTab { mine, discover }

/// Focus groups — the durable rooms that make shared sessions repeatable.
///
/// Built on the app's standard [ScaffoldShell] so it shares the botanical
/// background, the serif app-bar title and the back affordance with every other
/// pushed route, and reads correctly in both palettes.
///
/// Reminders are resynced on open: a group joined or a schedule edited on
/// another device would otherwise leave this device's pending alarms stale.
class GroupsListScreen extends ConsumerStatefulWidget {
  const GroupsListScreen({super.key});

  @override
  ConsumerState<GroupsListScreen> createState() => _GroupsListScreenState();
}

class _GroupsListScreenState extends ConsumerState<GroupsListScreen> {
  GroupTab _tab = GroupTab.mine;

  @override
  void initState() {
    super.initState();
    // Fire-and-forget: reminders are a convenience, and a failure here must
    // never block the list from drawing.
    SessionNotificationsService.instance.syncGroupReminders();
  }

  Future<void> _refresh() async {
    ref.invalidate(userGroupsProvider);
    ref.invalidate(groupDirectoryProvider);
    await Future.wait([
      ref.read(userGroupsProvider.future),
      ref.read(groupDirectoryProvider.future),
    ]);
  }

  void _openGroup(FocusGroup group) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupDetailScreen(groupId: group.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.people_team_20_regular,
          filledIcon: FluentIcons.people_team_20_filled,
          titleText: 'Groups',
          fab: DefaultFabButton(
            heroTag: HeroTags.newFocusGroupFABTag,
            label: 'New Group',
            icon: FluentIcons.add_20_filled,
            onPressed: () => showCreateGroupSheet(context),
          ),
          actions: [
            IconButton(
              tooltip: 'Join with a code',
              icon: const Icon(FluentIcons.key_20_regular),
              onPressed: () => showJoinGroupSheet(context),
            ),
          ],
          sliverBody: DefaultRefreshIndicator(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 4, 4, 16),
                    child: Center(
                      child: DefaultSegmentedButton<GroupTab>(
                        selected: _tab,
                        onChanged: (value) => setState(() => _tab = value),
                        segments: const [
                          SegmentItem(
                            value: GroupTab.mine,
                            label: 'My Groups',
                            icon: FluentIcons.people_team_20_regular,
                            filledIcon: FluentIcons.people_team_20_filled,
                          ),
                          SegmentItem(
                            value: GroupTab.discover,
                            label: 'Discover',
                            icon: FluentIcons.globe_search_20_regular,
                            filledIcon: FluentIcons.globe_search_20_filled,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_tab == GroupTab.mine)
                  ..._myGroupsSlivers()
                else
                  ..._discoverSlivers(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------------------------------------------------------------
  // My Groups
  // -------------------------------------------------------------------------

  List<Widget> _myGroupsSlivers() {
    final groupsAsync = ref.watch(userGroupsProvider);

    return groupsAsync.when(
      loading: () => [_loadingSliver()],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: _GroupsErrorView(
            message: groupErrorMessage(error, 'load your'),
            onRetry: _refresh,
          ),
        ),
      ],
      data: (groups) {
        if (groups.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: _GroupsEmptyView(
                icon: FluentIcons.people_team_20_regular,
                title: 'No groups yet',
                subtitle: 'Create a group to run focus sessions with the same '
                    'people again and again.',
                actionLabel: 'Create a group',
                onAction: () => showCreateGroupSheet(context),
              ),
            ),
            ..._footerSlivers,
          ];
        }

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: ModernSectionHeader(
                title: 'Your Groups',
                subtitle: _plural(groups.length, 'group', 'groups'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: SurfaceCard(
                padding: EdgeInsets.zero,
                elevation: 0,
                child: Column(
                  children: [
                    for (final group in groups) ...[
                      GroupCard(
                        group: group,
                        margin: EdgeInsets.zero,
                        onTap: () => _openGroup(group),
                      ),
                      if (group != groups.last)
                        const Divider(height: 0.5, indent: 56),
                    ],
                  ],
                ),
              ),
            ),
          ),
          ..._footerSlivers,
        ];
      },
    );
  }

  // -------------------------------------------------------------------------
  // Discover
  // -------------------------------------------------------------------------

  List<Widget> _discoverSlivers() {
    final directoryAsync = ref.watch(groupDirectoryProvider);

    return directoryAsync.when(
      loading: () => [_loadingSliver()],
      error: (error, _) => [
        SliverToBoxAdapter(
          child: _GroupsErrorView(
            message: groupErrorMessage(error, 'load the'),
            onRetry: _refresh,
          ),
        ),
      ],
      data: (entries) {
        if (entries.isEmpty) {
          return [
            SliverToBoxAdapter(
              child: const _GroupsEmptyView(
                icon: FluentIcons.globe_search_20_regular,
                title: 'No listed groups',
                subtitle: 'Groups shared as discoverable show up here for '
                    'anyone to find.',
              ),
            ),
            ..._footerSlivers,
          ];
        }

        return [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: ModernSectionHeader(
                title: 'Discover',
                subtitle: _plural(entries.length, 'listed group',
                    'listed groups'),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: Column(
                children: [
                  for (final entry in entries)
                    Padding(
                      padding: const EdgeInsets.only(bottom: Spacing.md),
                      child: _DirectoryCard(entry: entry),
                    ),
                ],
              ),
            ),
          ),
          ..._footerSlivers,
        ];
      },
    );
  }

  // -------------------------------------------------------------------------
  // Shared pieces
  // -------------------------------------------------------------------------

  static List<Widget> get _footerSlivers => const [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(4, 0, 4, 16),
            child: _HowGroupsWorkCard(),
          ),
        ),
        SliverTabsBottomPadding(),
      ];

  Widget _loadingSliver() => const SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 64),
          child: Center(child: CircularProgressIndicator()),
        ),
      );

  String _plural(int count, String singular, String plural) =>
      count == 1 ? '1 $singular' : '$count $plural';
}

/// One card in the Discover list, built from a directory entry.
///
/// A directory entry is a small read-only summary, so it carries no invite
/// code or live-session pointer; opening the group is what loads those.
class _DirectoryCard extends StatelessWidget {
  const _DirectoryCard({required this.entry});

  final Map<String, dynamic> entry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final name = (entry['name'] as String?)?.trim();
    final description = (entry['description'] as String?)?.trim();
    final maxMembers = entry['maxMembers'];
    final groupId = entry['id'] as String?;

    return SurfaceCard(
      elevation: 0,
      onTap: groupId == null
          ? null
          : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => GroupDetailScreen(groupId: groupId),
                ),
              ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: colorScheme.primary.withValues(alpha: 0.14),
            ),
            alignment: Alignment.center,
            child: Icon(
              FluentIcons.people_20_regular,
              size: 20,
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  name == null || name.isEmpty ? 'Group' : name,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  (description != null && description.isNotEmpty)
                      ? description
                      : (maxMembers is int ? 'Up to $maxMembers members' : ''),
                  fontSize: 12,
                  isSubtitle: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(
            FluentIcons.chevron_right_20_regular,
            size: 20,
            color: colorScheme.onSurface.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}

/// Explains what a group is, in the app's standard dashboard-card shape.
class _HowGroupsWorkCard extends StatelessWidget {
  const _HowGroupsWorkCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ModernDashboardCard(
      title: 'How Groups Work',
      subtitle: 'Same people, every week',
      icon: const Icon(FluentIcons.people_community_20_filled),
      accentColor: colorScheme.primary,
      children: [
        _infoRow(
          context,
          icon: FluentIcons.add_circle_20_regular,
          title: 'Create a group',
          body: 'Give it a name and share the invite code with your people.',
        ),
        const SizedBox(height: Spacing.md),
        _infoRow(
          context,
          icon: FluentIcons.calendar_ltr_20_regular,
          title: 'Plan a session',
          body: 'Everyone gets a reminder before it starts.',
        ),
        const SizedBox(height: Spacing.md),
        _infoRow(
          context,
          icon: FluentIcons.play_20_regular,
          title: 'Start together',
          body: 'One tap opens a shared run every member can join.',
        ),
      ],
    );
  }

  Widget _infoRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(Radii.sm),
          ),
          child: Icon(icon, size: 18, color: colorScheme.primary),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StyledText(
                title,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              StyledText(
                body,
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.35,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Failure state with a retry button.
class _GroupsErrorView extends StatelessWidget {
  const _GroupsErrorView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: Column(
        children: [
          Icon(
            FluentIcons.error_circle_20_regular,
            size: 40,
            color: colorScheme.error,
          ),
          const SizedBox(height: Spacing.md),
          StyledText(
            message,
            fontSize: 14,
            textAlign: TextAlign.center,
            color: colorScheme.onSurface.withValues(alpha: 0.8),
          ),
          const SizedBox(height: Spacing.md),
          OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(FluentIcons.arrow_sync_20_regular, size: 18),
            label: const Text('Try again'),
          ),
        ],
      ),
    );
  }
}

/// Empty state, with an optional action button.
class _GroupsEmptyView extends StatelessWidget {
  const _GroupsEmptyView({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final label = actionLabel;
    final action = onAction;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
      child: Column(
        children: [
          Icon(icon, size: 44, color: colorScheme.primary),
          const SizedBox(height: Spacing.md),
          StyledText(title, fontSize: 17, fontWeight: FontWeight.w600),
          const SizedBox(height: Spacing.xs),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.xl),
            child: StyledText(
              subtitle,
              fontSize: 13,
              textAlign: TextAlign.center,
              isSubtitle: true,
              height: 1.4,
            ),
          ),
          if (label != null && action != null) ...[
            const SizedBox(height: Spacing.lg),
            FilledButton.icon(
              onPressed: action,
              icon: const Icon(FluentIcons.add_20_filled, size: 18),
              label: Text(label),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: Spacing.xl,
                  vertical: Spacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
