import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/features/shared_sessions/session_error_message.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_sheet_scaffold.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';

/// Opens the create-session bottom sheet.
Future<void> showCreateSessionSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateSessionSheet(),
  );
}

/// Bottom sheet that creates a shared focus session.
class CreateSessionSheet extends ConsumerStatefulWidget {
  const CreateSessionSheet({super.key});

  @override
  ConsumerState<CreateSessionSheet> createState() => _CreateSessionSheetState();
}

class _CreateSessionSheetState extends ConsumerState<CreateSessionSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isPublic = false;

  /// The shared run length, in minutes, picked from
  /// [SessionLimits.durationOptionsMinutes].
  ///
  /// The sheet used to omit this entirely, so every room was created at the
  /// 25-minute default and each member's local focus run was unrelated to the
  /// room's own length.
  int _durationMin =
      SessionLimits.defaultDurationSec ~/ Duration.secondsPerMinute;

  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    await ref.read(createSessionProvider.notifier).createSession(
          name: _nameCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty
              ? null
              : _descCtrl.text.trim(),
          isPublic: _isPublic,
          durationSec: _durationMin * Duration.secondsPerMinute,
        );

    if (!mounted) return;

    // Only dismiss on success — otherwise the sheet would vanish and the
    // user would lose their input with no explanation of what went wrong.
    final error = ref.read(createSessionProvider).error;
    if (error != null) {
      setState(() => _error = sessionErrorMessage(error, 'create'));
      return;
    }

    ref.invalidate(userSessionsProvider);
    ref.invalidate(publicSessionsProvider);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final createState = ref.watch(createSessionProvider);
    final isBusy = createState.isLoading;

    return SessionSheetScaffold(
      title: 'New Session',
      subtitle: 'Start a group focus room your friends can join.',
      icon: FluentIcons.people_add_20_filled,
      children: [
        Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null) SessionSheetErrorBanner(message: _error!),
              TextFormField(
                controller: _nameCtrl,
                textInputAction: TextInputAction.next,
                enabled: !isBusy,
                // The rules refuse anything longer than this, and a rejection
                // arrives as a bare `permission-denied` — so the form stops it
                // here rather than letting the write explain it.
                maxLength: SessionLimits.maxNameLength,
                decoration: const InputDecoration(
                  labelText: 'Session name',
                  hintText: 'e.g. Morning Study Group',
                  prefixIcon: Icon(FluentIcons.edit_20_regular),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Give your session a name'
                    : null,
              ),
              const SizedBox(height: Spacing.md),
              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                minLines: 2,
                enabled: !isBusy,
                decoration: const InputDecoration(
                  labelText: 'Description (optional)',
                  alignLabelWithHint: true,
                  hintText: 'What is this group focusing on?',
                ),
              ),
              const SizedBox(height: Spacing.lg),
              _VisibilityTile(
                isPublic: _isPublic,
                enabled: !isBusy,
                onChanged: (value) => setState(() => _isPublic = value),
              ),
              const SizedBox(height: Spacing.md),
              _DurationTile(
                minutes: _durationMin,
                enabled: !isBusy,
                onChanged: (value) => setState(() => _durationMin = value),
              ),
              const SizedBox(height: Spacing.md),
              const _CapacityTile(),
              const SizedBox(height: Spacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : _submit,
                  icon: isBusy
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colorScheme.onPrimary,
                          ),
                        )
                      : const Icon(FluentIcons.add_20_filled, size: 18),
                  label: Text(isBusy ? 'Creating…' : 'Create Session'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.base,
                    ),
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
                      'Public sessions appear in Discover so anyone can join.',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// How long the shared run lasts, chosen from a fixed set of lengths.
///
/// The value goes to the server as `durationSec`, and it is what every member's
/// focus run is measured against once the host starts — so it is picked here,
/// once, rather than inferred per device.
class _DurationTile extends StatelessWidget {
  const _DurationTile({
    required this.minutes,
    required this.enabled,
    required this.onChanged,
  });

  final int minutes;
  final bool enabled;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.tertiary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: colorScheme.tertiary.withValues(alpha: 0.18),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                FluentIcons.timer_20_filled,
                size: 20,
                color: colorScheme.tertiary,
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StyledText(
                      'Focus length',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    StyledText(
                      'Everyone focuses for $minutes min, ending together.',
                      fontSize: 12,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.35,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // A wrap, not a row: seven options overflow a narrow phone, and a
          // clipped choice is one the user cannot make.
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: [
              for (final option in SessionLimits.durationOptionsMinutes)
                _DurationChoice(
                  minutes: option,
                  selected: option == minutes,
                  enabled: enabled,
                  onTap: () => onChanged(option),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One selectable run length.
class _DurationChoice extends StatelessWidget {
  const _DurationChoice({
    required this.minutes,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final int minutes;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = selected ? colorScheme.tertiary : colorScheme.outline;

    return Material(
      color: selected
          ? accent.withValues(alpha: 0.16)
          : colorScheme.surface.withValues(alpha: 0.4),
      borderRadius: BorderRadius.circular(Radii.pill),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(Radii.pill),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Radii.pill),
            border: Border.all(
              color: accent.withValues(alpha: selected ? 0.6 : 0.25),
            ),
          ),
          child: StyledText(
            '$minutes min',
            fontSize: 13,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? accent : colorScheme.onSurface,
            maxLines: 1,
          ),
        ),
      ),
    );
  }
}

/// States the member cap before the session exists.
///
/// The cap is fixed and enforced on the server, so this reports it rather than
/// offering a control that could disagree with `database.rules.json`.
class _CapacityTile extends StatelessWidget {
  const _CapacityTile();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    const cap = SessionLimits.maxMembersPerSession;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            FluentIcons.people_20_filled,
            size: 20,
            color: colorScheme.secondary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'Up to $cap people',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  'Sessions hold $cap members, you included, to keep the timer '
                  'and focus state in sync.',
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  height: 1.35,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Public/private selector rendered as a tappable surface row so it matches
/// the rest of the app's switch rows instead of a bare `SwitchListTile`.
class _VisibilityTile extends StatelessWidget {
  const _VisibilityTile({
    required this.isPublic,
    required this.enabled,
    required this.onChanged,
  });

  final bool isPublic;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(Spacing.md),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(Radii.md),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isPublic
                ? FluentIcons.globe_20_filled
                : FluentIcons.lock_closed_20_filled,
            size: 20,
            color: colorScheme.primary,
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'Public session',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
                const SizedBox(height: 2),
                StyledText(
                  isPublic
                      ? 'Anyone can discover and join'
                      : 'Only people with the session ID can join',
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: isPublic,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: colorScheme.primary,
            activeTrackColor: colorScheme.primary.withValues(alpha: 0.4),
          ),
        ],
      ),
    );
  }
}
