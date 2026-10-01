// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/report_block_service.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/report_block_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the report/block sheet for one person.
///
/// [targetDisplayName] is only ever used in the copy — the write goes by uid,
/// so a name that changed between the roster rendering and the tap cannot make
/// the report land on the wrong person.
Future<void> showReportBlockSheet(
  BuildContext context, {
  required String targetUid,
  required String targetDisplayName,
  ReportTargetKind kind = ReportTargetKind.member,
  String? sessionId,
  String? groupId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => ReportBlockSheet(
      targetUid: targetUid,
      targetDisplayName: targetDisplayName,
      kind: kind,
      sessionId: sessionId,
      groupId: groupId,
    ),
  );
}

/// Report a person, block them, or both.
///
/// The two actions are deliberately separate controls. A block is immediate and
/// silent; a report is a message a human will read. Merging them into one
/// button would force a choice between "blocking did nothing" and "reporting
/// went nowhere", and neither is true.
class ReportBlockSheet extends ConsumerStatefulWidget {
  const ReportBlockSheet({
    super.key,
    required this.targetUid,
    required this.targetDisplayName,
    this.kind = ReportTargetKind.member,
    this.sessionId,
    this.groupId,
  });

  final String targetUid;
  final String targetDisplayName;
  final ReportTargetKind kind;
  final String? sessionId;
  final String? groupId;

  @override
  ConsumerState<ReportBlockSheet> createState() => _ReportBlockSheetState();
}

class _ReportBlockSheetState extends ConsumerState<ReportBlockSheet> {
  final TextEditingController _noteCtrl = TextEditingController();
  ReportReason _reason = ReportReason.harassment;
  String? _error;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _error = null);

    final ok = await ref.read(reportBlockProvider.notifier).report(
          targetUid: widget.targetUid,
          kind: widget.kind,
          reason: _reason,
          note: _noteCtrl.text,
          sessionId: widget.sessionId,
          groupId: widget.groupId,
        );

    if (!mounted) return;

    if (!ok) {
      final error = ref.read(reportBlockProvider).error;
      setState(() => _error = error?.toString() ??
          'Could not send the report. Please try again.');
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Report sent. Thank you for telling us.'),
      ),
    );
  }

  Future<void> _submitBlock() async {
    setState(() => _error = null);

    final ok = await ref.read(reportBlockProvider.notifier).block(
          userId: widget.targetUid,
          displayName: widget.targetDisplayName,
        );

    if (!mounted) return;

    if (!ok) {
      final error = ref.read(reportBlockProvider).error;
      setState(() => _error = error?.toString() ??
          'Could not block this person. Please try again.');
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${widget.targetDisplayName} is blocked. You will not see them in '
          'your sessions or groups.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final busy = ref.watch(reportBlockProvider).isLoading;

    return SessionSheetScaffold(
      title: widget.targetDisplayName,
      subtitle: 'Report or block this person.',
      icon: FluentIcons.shield_error_20_filled,
      children: [
        if (_error != null) SessionSheetErrorBanner(message: _error!),

        // ---- Block ---------------------------------------------------------
        SurfaceCardRow(
          icon: FluentIcons.prohibited_20_filled,
          title: 'Block',
          subtitle:
              'Hides their name and photo from every session and group you '
              'see. They are not told.',
          onTap: busy ? null : _submitBlock,
          destructive: true,
        ),
        const SizedBox(height: Spacing.lg),

        // ---- Report --------------------------------------------------------
        StyledText(
          'Report a problem',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: Spacing.sm),
        StyledText(
          'A person on our team will review this. Reporting does not hide '
          'them — use Block for that.',
          fontSize: 12,
          color: colorScheme.onSurface.withValues(alpha: 0.7),
          height: 1.35,
        ),
        const SizedBox(height: Spacing.md),

        // One RadioGroup owns the selection for the tiles below it; the tiles
        // carry only their own value. Disabling is per tile via `enabled`, so
        // the reasons can still be read while a report is in flight.
        RadioGroup<ReportReason>(
          groupValue: _reason,
          onChanged: (value) {
            if (value != null) setState(() => _reason = value);
          },
          child: Column(
            children: [
              for (final reason in ReportReason.values)
                RadioListTile<ReportReason>(
                  value: reason,
                  enabled: !busy,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colorScheme.primary,
                  title: StyledText(reason.label, fontSize: 14),
                ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: _noteCtrl,
          enabled: !busy,
          maxLines: 3,
          maxLength: ReportBlockService.maxNoteLength,
          decoration: const InputDecoration(
            labelText: 'Anything else? (optional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : _submitReport,
            icon: busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(FluentIcons.flag_20_filled, size: 18),
            label: const Text('Send report'),
            style: FilledButton.styleFrom(
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

/// A tappable, icon-led row used inside the report/block sheet.
///
/// Local to this sheet rather than shared: the roster tiles carry a member and
/// a status dot, and widening one of those to fit a destructive action row
/// would make every roster row heavier for one call site.
class SurfaceCardRow extends StatelessWidget {
  const SurfaceCardRow({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = destructive ? colorScheme.error : colorScheme.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(Radii.md),
        child: Padding(
          padding: const EdgeInsets.all(Spacing.md),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(Radii.sm),
                ),
                child: Icon(icon, size: 18, color: accent),
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
                      color: accent,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    StyledText(
                      subtitle,
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.35,
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
