// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/utils/invite_code.dart';
import 'package:nlp_digitox/features/groups/group_detail_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/group_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the "join a group with a code" bottom sheet.
Future<void> showJoinGroupSheet(
  BuildContext context, {
  String? initialCode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => JoinGroupSheet(initialCode: initialCode),
  );
}

/// Bottom sheet that joins a group from a 6-character invite code or link.
class JoinGroupSheet extends ConsumerStatefulWidget {
  const JoinGroupSheet({super.key, this.initialCode});

  final String? initialCode;

  @override
  ConsumerState<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends ConsumerState<JoinGroupSheet> {
  late final TextEditingController _codeCtrl =
      TextEditingController(text: widget.initialCode ?? '');
  String? _error;

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _join() async {
    final parsed = InviteCode.parse(_codeCtrl.text);
    if (parsed == null) {
      setState(() => _error =
          'That does not look like an invite code. Codes are '
          '${InviteCode.length} characters, like AB3K7Q.');
      return;
    }

    setState(() => _error = null);

    // The membership document records who joined, so the display name and
    // photo are resolved before the write rather than inside the service.
    final identity = await ref.read(groupIdentityProvider.future);
    final gid = await ref
        .read(joinGroupProvider.notifier)
        .joinByCode(code: parsed, identity: identity);
    if (!mounted) return;

    if (gid == null) {
      final error = ref.read(joinGroupProvider).error;
      setState(() => _error = error?.toString() ??
          'Could not join that group. The invite may have changed.');
      return;
    }

    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => GroupDetailScreen(groupId: gid)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final joinState = ref.watch(joinGroupProvider);
    final isBusy = joinState.isLoading;

    return SessionSheetScaffold(
      title: 'Join a group',
      subtitle: 'Enter the invite code the group shared with you.',
      icon: FluentIcons.people_add_20_filled,
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
            label: Text(isBusy ? 'Joining…' : 'Join group'),
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
                'An expired code, or one that points at a group that has '
                'gone, will be refused — ask for a fresh one.',
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
