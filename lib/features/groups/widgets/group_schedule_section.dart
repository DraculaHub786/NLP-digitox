// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/features/groups/group_schedule_format.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// The planned sessions of one group, soonest first.
///
/// A plan is not a session: nothing is running until someone taps start. The
/// section reads as a short agenda — the next entry is highlighted, past
/// entries are dimmed, and an owner or admin can add or remove one.
class GroupScheduleSection extends StatelessWidget {
  const GroupScheduleSection({
    super.key,
    required this.entries,
    this.canManage = false,
    this.onAdd,
    this.onRemove,
  });

  final List<GroupScheduleEntry> entries;

  /// Whether the reader may change the schedule (owner or admin).
  final bool canManage;

  /// Opens the "add a planned session" sheet.
  final VoidCallback? onAdd;

  /// Removes one planned session, by entry id.
  final void Function(GroupScheduleEntry entry)? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Past entries are shown under "Earlier" rather than hidden: "we met on
    // Tuesday" is the record a member looks for, and silently dropping it
    // would make the group look like it never ran.
    final upcoming = entries.where((e) => !e.isPast).toList();
    final past = entries.where((e) => e.isPast).toList();

    return SurfaceCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentIcons.calendar_ltr_20_filled,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: StyledText(
                  'Schedule',
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canManage)
                IconButton(
                  tooltip: 'Add a planned session',
                  onPressed: onAdd,
                  icon: const Icon(FluentIcons.add_20_filled, size: 20),
                ),
            ],
          ),

          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: Spacing.sm),
              child: StyledText(
                canManage
                    ? 'No sessions planned. Add one so the group gets a '
                        'reminder before it starts.'
                    : 'No sessions planned yet.',
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
                height: 1.35,
              ),
            )
          else ...[
            const SizedBox(height: Spacing.sm),
            for (final entry in upcoming)
              GroupScheduleRow(
                entry: entry,
                highlighted: entry == upcoming.first,
                onRemove: canManage ? () => onRemove?.call(entry) : null,
              ),
            if (past.isNotEmpty) ...[
              const SizedBox(height: Spacing.sm),
              StyledText(
                'Earlier',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface.withValues(alpha: 0.55),
              ),
              const SizedBox(height: Spacing.xs),
              for (final entry in past.reversed)
                GroupScheduleRow(
                  entry: entry,
                  highlighted: false,
                  isPast: true,
                  onRemove: canManage ? () => onRemove?.call(entry) : null,
                ),
            ],
          ],
        ],
      ),
    );
  }
}

/// One planned session.
class GroupScheduleRow extends StatelessWidget {
  const GroupScheduleRow({
    super.key,
    required this.entry,
    required this.highlighted,
    required this.onRemove,
    this.isPast = false,
  });

  final GroupScheduleEntry entry;

  /// The next upcoming entry is accented so the answer to "what is next"
  /// needs no reading.
  final bool highlighted;

  final bool isPast;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = highlighted ? colorScheme.primary : null;
    final muted = colorScheme.onSurface.withValues(alpha: isPast ? 0.45 : 0.7);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (accent ?? colorScheme.primary)
                  .withValues(alpha: isPast ? 0.06 : 0.12),
              borderRadius: BorderRadius.circular(Radii.sm),
            ),
            child: Icon(
              isPast
                  ? FluentIcons.checkmark_20_regular
                  : FluentIcons.clock_20_regular,
              size: 18,
              color: accent ?? muted,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  entry.title,
                  fontSize: 14,
                  fontWeight: highlighted ? FontWeight.w600 : FontWeight.normal,
                  color: isPast ? muted : null,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  '${GroupScheduleFormat.absolute(entry.startsAt)} · '
                  '${entry.durationMinutes} min',
                  fontSize: 12,
                  color: muted,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (onRemove != null)
            IconButton(
              tooltip: 'Remove',
              onPressed: onRemove,
              icon: Icon(
                FluentIcons.delete_20_regular,
                size: 18,
                color: colorScheme.error.withValues(alpha: 0.8),
              ),
            )
          else if (highlighted)
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 4),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
                child: StyledText(
                  GroupScheduleFormat.relative(entry.startsAt),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  maxLines: 1,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
