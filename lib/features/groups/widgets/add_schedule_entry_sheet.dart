// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/constants/group_limits.dart';
import 'package:nlp_digitox/features/groups/group_schedule_format.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/group_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the "plan a session" sheet for [groupId].
Future<bool?> showAddScheduleEntrySheet(
  BuildContext context, {
  required String groupId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => AddScheduleEntrySheet(groupId: groupId),
  );
}

/// Bottom sheet that adds one planned session to a group's schedule.
///
/// Popping with `true` means an entry was written, so the caller can resync
/// its reminders; a dismissal leaves the schedule untouched.
class AddScheduleEntrySheet extends ConsumerStatefulWidget {
  const AddScheduleEntrySheet({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<AddScheduleEntrySheet> createState() =>
      _AddScheduleEntrySheetState();
}

class _AddScheduleEntrySheetState extends ConsumerState<AddScheduleEntrySheet> {
  final TextEditingController _titleCtrl = TextEditingController();

  /// Whole minutes, because a plan is never precise to the second and offering
  /// seconds would invite a level of fiddling the feature does not need.
  int _durationMinutes = 25;

  /// The chosen start, defaulting to an hour from now rounded up to five.
  late DateTime _startsAt = _defaultStart();

  String? _error;

  static const List<int> _durationChoices = [10, 15, 20, 25, 30, 45, 60];

  static DateTime _defaultStart() {
    final now = DateTime.now().add(const Duration(hours: 1));
    final roundedMinute = (now.minute / 5).ceil() * 5;
    return DateTime(now.year, now.month, now.day, now.hour)
        .add(Duration(minutes: roundedMinute));
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickStart() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startsAt,
      firstDate: now,
      lastDate: now.add(GroupLimits.maxScheduleHorizon),
    );
    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startsAt),
    );
    if (!mounted) return;

    setState(() {
      _startsAt = DateTime(
        picked.year,
        picked.month,
        picked.day,
        time?.hour ?? _startsAt.hour,
        time?.minute ?? _startsAt.minute,
      );
    });
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    await ref.read(groupActionsProvider.notifier).addScheduleEntry(
          groupId: widget.groupId,
          title: _titleCtrl.text,
          startsAt: _startsAt,
          durationSec: _durationMinutes * Duration.secondsPerMinute,
        );

    if (!mounted) return;

    final error = ref.read(groupActionsProvider).error;
    if (error != null) {
      setState(() => _error = error.toString());
      return;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final busy = ref.watch(groupActionsProvider).isLoading;

    return SessionSheetScaffold(
      title: 'Plan a session',
      subtitle: 'The group is reminded before it starts.',
      icon: FluentIcons.calendar_add_20_filled,
      children: [
        if (_error != null) SessionSheetErrorBanner(message: _error!),
        TextField(
          controller: _titleCtrl,
          enabled: !busy,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'What is this session for?',
            hintText: 'e.g. Deep work',
            prefixIcon: Icon(FluentIcons.edit_20_regular),
          ),
        ),
        const SizedBox(height: Spacing.lg),

        StyledText('Starts', fontSize: 15, fontWeight: FontWeight.w600),
        const SizedBox(height: Spacing.sm),
        _PickerRow(
          icon: FluentIcons.calendar_ltr_20_regular,
          title: GroupScheduleFormat.absolute(_startsAt),
          subtitle: GroupScheduleFormat.relative(_startsAt),
          onTap: busy ? null : _pickStart,
        ),
        const SizedBox(height: Spacing.lg),

        StyledText('Duration', fontSize: 15, fontWeight: FontWeight.w600),
        const SizedBox(height: Spacing.sm),
        Wrap(
          spacing: Spacing.sm,
          runSpacing: Spacing.sm,
          children: [
            for (final minutes in _durationChoices)
              ChoiceChip(
                label: Text('$minutes min'),
                selected: _durationMinutes == minutes,
                onSelected: busy
                    ? null
                    : (_) => setState(() => _durationMinutes = minutes),
              ),
          ],
        ),
        const SizedBox(height: Spacing.lg),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : _submit,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(FluentIcons.add_20_filled, size: 18),
            label: Text(busy ? 'Adding…' : 'Add to schedule'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: Spacing.base),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              FluentIcons.info_20_regular,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: StyledText(
                'Sessions must start at least '
                '${GroupLimits.minScheduleLead.inMinutes} minutes from now, '
                'and no further ahead than '
                '${GroupLimits.maxScheduleHorizon.inDays} days.',
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                height: 1.35,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A tappable, icon-led row used for the date/time picker.
class _PickerRow extends StatelessWidget {
  const _PickerRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.14),
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
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    StyledText(
                      subtitle,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
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
        ),
      ),
    );
  }
}
