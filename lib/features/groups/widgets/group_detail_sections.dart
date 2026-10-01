// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';
import 'package:nlp_digitox/models/group_stats.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// Banner shown while the group is running a session.
///
/// The one thing a member opens the group for mid-run is joining it, so the
/// banner itself is the button rather than pointing at one elsewhere.
class LiveSessionBanner extends StatelessWidget {
  const LiveSessionBanner({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      tint: colorScheme.primary,
      elevation: 2,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary,
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              FluentIcons.play_20_filled,
              size: 20,
              color: colorScheme.onPrimary,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'A session is running now',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  'Tap to join the run with the group.',
                  fontSize: 12,
                  isSubtitle: true,
                  maxLines: 1,
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

/// Headline metrics for a group: size, planned sessions, visibility.
class GroupOverviewCard extends StatelessWidget {
  const GroupOverviewCard({
    super.key,
    required this.group,
    required this.schedule,
  });

  final FocusGroup group;
  final List<GroupScheduleEntry> schedule;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final upcoming = schedule.where((e) => !e.isPast).length;
    final description = group.description;

    return SurfaceCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (description != null && description.isNotEmpty) ...[
            StyledText(description, fontSize: 14, height: 1.4),
            const SizedBox(height: Spacing.md),
          ],
          Row(
            children: [
              Expanded(
                child: ModernMetricCard(
                  label: 'Members',
                  value: '${group.memberCount}/${group.maxMembers}',
                  icon: FluentIcons.people_20_filled,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ModernMetricCard(
                  label: 'Planned',
                  value: '$upcoming',
                  icon: FluentIcons.calendar_ltr_20_filled,
                  color: DesignPalette.fern,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                group.isListed
                    ? FluentIcons.globe_20_regular
                    : FluentIcons.lock_closed_20_regular,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: StyledText(
                  group.isListed
                      ? 'Anyone can find this group in the directory.'
                      : 'Private — only people with the invite code can join.',
                  fontSize: 13,
                  isSubtitle: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// The signed-in member's own record in the group.
///
/// Reads from a stream so the card fills in the moment the points webhook
/// writes a new row, without the member leaving and reopening the group.
class GroupRecordCard extends StatelessWidget {
  const GroupRecordCard({super.key, required this.statsAsync});

  final AsyncValue<GroupStats> statsAsync;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final stats = statsAsync.valueOrNull;

    if (stats == null || stats.isEmpty) {
      return SurfaceCard(
        elevation: 0,
        child: Row(
          children: [
            Icon(
              FluentIcons.history_20_regular,
              size: 20,
              color: colorScheme.primary,
            ),
            const SizedBox(width: Spacing.md),
            Expanded(
              child: StyledText(
                'You have not finished a group session yet. Your record '
                'appears here once you do.',
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.35,
              ),
            ),
          ],
        ),
      );
    }

    return SurfaceCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledText(
            'Your record here',
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'Completed',
                  value: '${stats.sessionsCompleted}',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StatPill(
                  label: 'Focused',
                  value: '${stats.focusedMinutes} min',
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: _StatPill(label: 'Streak', value: '${stats.streak}'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One number in the "your record" row.
class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.sm,
        vertical: Spacing.md,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
      ),
      child: Column(
        children: [
          StyledText(
            value,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.primary,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          StyledText(
            label,
            fontSize: 11,
            isSubtitle: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// The group's button bar: start a run, leave or manage.
class GroupActionBar extends StatelessWidget {
  const GroupActionBar({
    super.key,
    required this.group,
    required this.isBusy,
    required this.isStartingRun,
    required this.onStartRun,
    required this.onLeave,
  });

  final FocusGroup group;
  final bool isBusy;
  final bool isStartingRun;
  final VoidCallback onStartRun;
  final VoidCallback onLeave;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final canStart = group.canManage && !group.hasLiveSession;

    return Column(
      children: [
        if (group.canManage) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: (isBusy || isStartingRun || !canStart)
                  ? null
                  : onStartRun,
              icon: isStartingRun
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(FluentIcons.play_20_filled, size: 18),
              label: Text(
                group.hasLiveSession
                    ? 'A session is running'
                    : (isStartingRun
                        ? 'Starting…'
                        : 'Start a group session'),
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
        ],
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: isBusy ? null : onLeave,
            icon: const Icon(FluentIcons.arrow_exit_20_regular, size: 18),
            label: Text(
              group.isOwnedByMe ? 'You own this group' : 'Leave group',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.45),
              ),
              padding: const EdgeInsets.symmetric(vertical: Spacing.base),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Error state with a retry affordance.
class GroupErrorView extends StatelessWidget {
  const GroupErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
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
    );
  }
}

/// Empty state for a group that could not be loaded.
class GroupEmptyView extends StatelessWidget {
  const GroupEmptyView({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 40, color: colorScheme.primary),
        const SizedBox(height: Spacing.md),
        StyledText(title, fontSize: 16, fontWeight: FontWeight.w600),
        const SizedBox(height: Spacing.xs),
        StyledText(
          subtitle,
          fontSize: 13,
          textAlign: TextAlign.center,
          isSubtitle: true,
        ),
      ],
    );
  }
}
