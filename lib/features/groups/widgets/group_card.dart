// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/ui/common/default_list_tile.dart';
import 'package:nlp_digitox/ui/common/status_dot.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// One row in "Your Groups".
///
/// Uses the app's standard [DefaultListTile], so it sits flush with the session
/// rows and the leaderboard rows. The leading circle carries the member count
/// rather than a generic group glyph: "how big is this room" is the question
/// the list is scanned for.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
    this.margin,
  });

  final FocusGroup group;
  final VoidCallback onTap;

  /// Forwarded to [DefaultListTile]. Pass [EdgeInsets.zero] when the rows are
  /// grouped inside one card so they sit flush against their dividers.
  final EdgeInsets? margin;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultListTile(
      margin: margin,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colorScheme.primary.withValues(alpha: 0.14),
        ),
        alignment: Alignment.center,
        child: StyledText(
          '${group.memberCount}',
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: colorScheme.primary,
        ),
      ),
      titleText: group.name,
      subtitle: _GroupSubtitle(group: group),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (group.hasLiveSession)
            const _LivePill()
          else
            _SeatChip(used: group.memberCount, total: group.maxMembers),
          const SizedBox(width: 4),
          Icon(
            FluentIcons.chevron_right_20_regular,
            size: 22,
            color: colorScheme.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
      accent: colorScheme.primary,
      onPressed: onTap,
    );
  }
}

/// Presence + visibility line shared by the group rows.
class _GroupSubtitle extends StatelessWidget {
  const _GroupSubtitle({required this.group});

  final FocusGroup group;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = group.description;

    return Row(
      children: [
        StatusDot(
          kind: group.hasLiveSession ? StatusDotKind.good : StatusDotKind.warn,
          size: 8,
        ),
        const SizedBox(width: Spacing.sm),
        Flexible(
          child: StyledText(
            group.hasLiveSession
                ? 'A session is running now'
                : (description != null && description.isNotEmpty
                    ? description
                    : '${group.memberCount} of ${group.maxMembers} members'),
            fontSize: 14,
            isSubtitle: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        if (group.isListed) ...[
          const SizedBox(width: Spacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: StyledText(
              'Listed',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: colorScheme.secondary,
              maxLines: 1,
            ),
          ),
        ],
      ],
    );
  }
}

/// "3/25" seat counter, flipping to a warning-coloured chip once the cap is
/// reached so a closed group is obvious from the list without opening it.
///
/// [total] comes from the group rather than the constant: a group created under
/// an older cap has to show the number the server will actually enforce for it.
class _SeatChip extends StatelessWidget {
  const _SeatChip({required this.used, required this.total});

  final int used;
  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isFull = used >= total;
    final accent = isFull ? colorScheme.error : colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: StyledText(
        isFull ? 'Full' : '$used/$total',
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: accent,
        maxLines: 1,
      ),
    );
  }
}

/// Replaces the seat chip while a run is in progress, so the one thing worth
/// tapping is also the one thing that stands out.
class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            FluentIcons.play_20_filled,
            size: 11,
            color: colorScheme.onPrimary,
          ),
          const SizedBox(width: 4),
          StyledText(
            'Live',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimary,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
