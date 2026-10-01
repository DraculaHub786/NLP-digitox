import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/features/shared_sessions/session_error_message.dart';
import 'package:nlp_digitox/features/shared_sessions/session_lobby_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the "join with an invite code" bottom sheet.
///
/// [initialCode] pre-fills the code field — used when the sheet is opened from
/// a deep link, so the user only has to confirm rather than retype the code
/// that just arrived.
Future<void> showJoinByCodeSheet(
  BuildContext context, {
  String? initialCode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JoinByCodeSheet(initialCode: initialCode),
  );
}

/// Bottom sheet that joins a session from a 6-character invite code or link.
///
/// This is the primary join path: the code is what the host shares, and it is
/// the only thing that both a person reading it aloud and a phone receiving a
/// link can act on. The raw app link (`com.nlp.digitox://join/CODE`) or a
/// pasted `https` link both normalise through [InviteCode.parse].
class JoinByCodeSheet extends ConsumerStatefulWidget {
  const JoinByCodeSheet({super.key, this.initialCode});

  /// A code to pre-fill, e.g. from an invite link.
  final String? initialCode;

  @override
  ConsumerState<JoinByCodeSheet> createState() => _JoinByCodeSheetState();
}

class _JoinByCodeSheetState extends ConsumerState<JoinByCodeSheet> {
  late final TextEditingController _codeCtrl =
      TextEditingController(text: widget.initialCode ?? '');
  final _nameCtrl = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final parsed = InviteCode.parse(_codeCtrl.text);
    final name = _nameCtrl.text.trim();

    if (parsed == null) {
      setState(() => _error =
          'That does not look like an invite code. Codes are '
          '${InviteCode.length} characters, like AB3K7Q.');
      return;
    }
    if (name.isEmpty) {
      setState(() => _error = 'Add a display name so the group knows who you '
          'are.');
      return;
    }

    setState(() => _error = null);

    final sessionId = await ref.read(joinByCodeProvider.notifier).joinByCode(
          code: parsed,
          displayName: name,
        );

    if (!mounted) return;

    final state = ref.read(joinByCodeProvider);
    final error = state.error;
    if (error != null || sessionId == null) {
      setState(() => _error = error != null
          ? sessionErrorMessage(error, 'join')
          : 'Could not join that session. Try again.');
      return;
    }

    ref.invalidate(userSessionsProvider);
    Navigator.pop(context);
    // A lobby is a push, not a named route: it carries the session id it was
    // opened for, and there is no deep-link shape that should rebuild it.
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionLobbyScreen(sessionId: sessionId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final joinState = ref.watch(joinByCodeProvider);
    final isBusy = joinState.isLoading;
    final userId = FirebaseAuthService.instance.userId;

    // Prefill the display name from the account so the common case is one tap.
    if (_nameCtrl.text.isEmpty && userId != null) {
      final name = FirebaseAuthService.instance.userDisplayName;
      if (name != null && name.isNotEmpty) _nameCtrl.text = name;
    }

    return SessionSheetScaffold(
      title: 'Join with a code',
      subtitle: 'Enter the code the host shared with you.',
      icon: FluentIcons.qr_code_20_filled,
      children: [
        if (_error != null) SessionSheetErrorBanner(message: _error!),
        TextField(
          controller: _codeCtrl,
          enabled: !isBusy,
          autofocus: true,
          textCapitalization: TextCapitalization.characters,
          inputFormatters: [
            LengthLimitingTextInputFormatter(InviteCode.length + 8),
          ],
          decoration: const InputDecoration(
            labelText: 'Invite code',
            hintText: 'e.g. AB3K7Q',
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
            label: Text(isBusy ? 'Joining…' : 'Join session'),
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
                'A code that has expired, or that points at a session you '
                'cannot see, will be refused — ask the host for a fresh one.',
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
