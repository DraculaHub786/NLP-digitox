// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/constants/group_limits.dart';
import 'package:nlp_digitox/features/groups/group_detail_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/providers/group_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the "create a group" bottom sheet.
Future<void> showCreateGroupSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateGroupSheet(),
  );
}

/// Bottom sheet that creates a durable focus group.
///
/// A group is created with an invite code already issued by the service, so
/// the creator can hand the code out from the group screen immediately rather
/// than tapping "create invite" first.
class CreateGroupSheet extends ConsumerStatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  ConsumerState<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends ConsumerState<CreateGroupSheet> {
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _descCtrl = TextEditingController();
  GroupVisibility _visibility = GroupVisibility.private;
  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final name = GroupLimits.normalizeName(_nameCtrl.text);
    if (!GroupLimits.isValidName(name)) {
      setState(() => _error =
          'Give the group a name of at least '
          '${GroupLimits.minNameLength} characters.');
      return;
    }

    setState(() => _error = null);

    // The owner's membership document carries their name and photo, so the
    // identity is resolved here rather than inside the service.
    final identity = await ref.read(groupIdentityProvider.future);
    final created = await ref.read(createGroupProvider.notifier).create(
          name: name,
          description: _descCtrl.text,
          visibility: _visibility,
          identity: identity,
        );

    if (!mounted) return;

    if (created == null) {
      final error = ref.read(createGroupProvider).error;
      setState(() => _error = error?.toString() ??
          'Could not create the group. Please try again.');
      return;
    }

    Navigator.pop(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => GroupDetailScreen(groupId: created.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final busy = ref.watch(createGroupProvider).isLoading;

    return SessionSheetScaffold(
      title: 'New group',
      subtitle: 'A group keeps your people and your schedule together.',
      icon: FluentIcons.people_team_20_filled,
      children: [
        if (_error != null) SessionSheetErrorBanner(message: _error!),
        TextField(
          controller: _nameCtrl,
          enabled: !busy,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          maxLength: GroupLimits.maxNameLength,
          decoration: const InputDecoration(
            labelText: 'Group name',
            hintText: 'e.g. Morning study crew',
            prefixIcon: Icon(FluentIcons.people_20_regular),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        TextField(
          controller: _descCtrl,
          enabled: !busy,
          maxLines: 2,
          maxLength: GroupLimits.maxDescriptionLength,
          decoration: const InputDecoration(
            labelText: 'Description (optional)',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: Spacing.sm),

        StyledText(
          'Who can join',
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        const SizedBox(height: Spacing.sm),
        // One RadioGroup owns the selection for the tiles below it; the tiles
        // carry only their own value. Disabling is per tile via `enabled`,
        // which is what the sheet does while a create is in flight.
        RadioGroup<GroupVisibility>(
          groupValue: _visibility,
          onChanged: (value) {
            if (value != null) setState(() => _visibility = value);
          },
          child: Column(
            children: [
              for (final visibility in GroupVisibility.values)
                RadioListTile<GroupVisibility>(
                  value: visibility,
                  enabled: !busy,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  activeColor: colorScheme.primary,
                  title: StyledText(visibility.label, fontSize: 14),
                  subtitle: StyledText(
                    visibility == GroupVisibility.private
                        ? 'Only people you send the invite code to.'
                        : 'Anyone can find it and ask to join.',
                    fontSize: 12,
                    isSubtitle: true,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.sm),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: busy ? null : _create,
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
            label: Text(busy ? 'Creating…' : 'Create group'),
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
