import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/session_completion_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// Owner-only "Complete Session" action for the session detail screen.
///
/// Completing a session marks it finished. Points are *not* computed here: the
/// server verifies each member's run and writes `sessionResults/{sid}/{uid}`.
/// This button asks the webhook to run that check for the owner and shows the
/// verdict it returns, rather than promising a fixed number the client cannot
/// guarantee.
class CompleteSessionButton extends ConsumerWidget {
  const CompleteSessionButton({super.key, required this.session});

  final SharedSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completeState = ref.watch(completeSessionProvider);
    final currentUserId = FirebaseAuthService.instance.userId;

    if (session.isCompleted) {
      return _CompletionBanner(completedAt: session.completedAt!);
    }

    // Members who are not the owner cannot complete a session; the service
    // enforces this too, so this is purely about not showing a dead button.
    if (currentUserId == null || session.ownerId != currentUserId) {
      return const _MemberWaitingNotice();
    }

    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed:
            completeState.isLoading ? null : () => _confirm(context, ref),
        icon: completeState.isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(FluentIcons.flag_20_filled, size: 18),
        label: const Text('Complete Session'),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: Spacing.base),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(Radii.pill),
          ),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: const Text('Complete session?'),
        content: Text(
          'This marks "${session.name}" as finished. Members who focused with '
          'the group and finished their run are credited — including you, if '
          'you did. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Not yet'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Complete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref
        .read(completeSessionProvider.notifier)
        .completeSession(session.id);

    if (!context.mounted) return;

    final result = ref.read(completeSessionProvider);
    if (result.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not complete session: ${result.error}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      return;
    }

    // The session is finished; the payout is the server's call, so show its
    // verdict when there is one and a neutral confirmation otherwise.
    final verdict =
        SessionCompletionService.instance.resultFor(session.id) ??
            SessionCompletionResult.disabled;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(verdict.message),
        backgroundColor:
            verdict.isCredited ? DesignPalette.fern : null,
      ),
    );
  }
}

/// Shown to a non-owner member while the session is still running.
class _MemberWaitingNotice extends StatelessWidget {
  const _MemberWaitingNotice();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SurfaceCard(
      elevation: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            FluentIcons.hourglass_half_20_regular,
            size: 18,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: StyledText(
              'Waiting for the owner to complete this session. Finish a focus '
              'run with the group and your points are credited automatically '
              'once the server has verified it.',
              fontSize: 13,
              isSubtitle: true,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown once a session has been completed, replacing the action button.
class _CompletionBanner extends StatelessWidget {
  const _CompletionBanner({required this.completedAt});

  final DateTime completedAt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = isDark ? DesignPalette.sage : DesignPalette.fern;

    return SurfaceCard(
      tint: accent,
      elevation: 0,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(Radii.pill),
            ),
            child: Icon(
              FluentIcons.checkmark_circle_20_filled,
              size: 20,
              color: accent,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StyledText(
                  'Session completed',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: accent,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                StyledText(
                  'Finished ${_formatTimestamp(completedAt)}',
                  fontSize: 12,
                  isSubtitle: true,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatTimestamp(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        'at ${two(value.hour)}:${two(value.minute)}';
  }
}
