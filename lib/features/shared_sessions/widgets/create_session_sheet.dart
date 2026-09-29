import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
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
              const SizedBox(height: Spacing.lg),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isBusy ? null : _submit,
                  icon: isBusy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
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
