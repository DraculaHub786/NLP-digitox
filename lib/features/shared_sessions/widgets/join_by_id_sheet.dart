import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/features/shared_sessions/session_error_message.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the "join a session by ID" bottom sheet.
Future<void> showJoinByIdSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const JoinByIdSheet(),
  );
}

/// Bottom sheet that joins a session from a shared ID.
class JoinByIdSheet extends ConsumerStatefulWidget {
  const JoinByIdSheet({super.key});

  @override
  ConsumerState<JoinByIdSheet> createState() => _JoinByIdSheetState();
}

class _JoinByIdSheetState extends ConsumerState<JoinByIdSheet> {
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  /// Rendered inside the sheet rather than as a SnackBar: the sheet is drawn on
  /// top of the screen's Scaffold, so a SnackBar would appear *behind* it and
  /// every failure would look like the button doing nothing.
  String? _error;

  @override
  void dispose() {
    _idCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final id = _idCtrl.text.trim();
    final name = _nameCtrl.text.trim();
    if (id.isEmpty || name.isEmpty) {
      setState(() => _error = 'Enter both the session ID and a display name.');
      return;
    }

    setState(() => _error = null);
    await ref.read(joinByIdProvider.notifier).joinById(
          sessionId: id,
          displayName: name,
        );

    if (!mounted) return;

    final state = ref.read(joinByIdProvider);
    if (state.hasError) {
      // Stay open so the user can correct the ID and retry, and so the reason
      // is actually visible.
      setState(() => _error = sessionErrorMessage(state.error!, 'join'));
      return;
    }

    Navigator.pop(context);
    ref.invalidate(userSessionsProvider);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Joined session!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final joinState = ref.watch(joinByIdProvider);
    final isBusy = joinState.isLoading;

    return SessionSheetScaffold(
      title: 'Join a public session',
      subtitle: 'Paste the ID of an open session you found in Discover.',
      icon: FluentIcons.link_20_filled,
      children: [
        if (_error != null) SessionSheetErrorBanner(message: _error!),
        TextField(
          controller: _idCtrl,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Public session ID',
            hintText: 'e.g. -Nx8kP2vQ…',
            prefixIcon: Icon(FluentIcons.tag_20_regular),
          ),
        ),
        const SizedBox(height: Spacing.md),
        TextField(
          controller: _nameCtrl,
          enabled: !isBusy,
          decoration: const InputDecoration(
            labelText: 'Your display name',
            helperText: 'Shown to the other members of the session',
            prefixIcon: Icon(FluentIcons.person_20_regular),
          ),
        ),
        const SizedBox(height: Spacing.lg),
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isBusy ? null : _join,
            icon: isBusy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(FluentIcons.arrow_join_20_filled, size: 18),
            label: Text(isBusy ? 'Joining…' : 'Join Session'),
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
              FluentIcons.qr_code_20_regular,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.55),
            ),
            const SizedBox(width: Spacing.sm),
            Expanded(
              child: StyledText(
                'Only open sessions can be joined by ID — find one in '
                'Discover. A private or invite-only session can only be joined '
                'with the code or link the host shared. Rooms hold up to '
                '${SessionLimits.maxMembersPerSession} people, so a full one '
                'cannot be joined.',
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
