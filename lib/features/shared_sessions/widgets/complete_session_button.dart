import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/productivity_points_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';

/// Owner-only "Complete Session" action for [SessionDetailScreen].
///
/// Completing a session pays the owner straight away and marks the session
/// finished. It deliberately does *not* try to pay the other members from
/// here: `LeaderboardService.addPoints` only ever writes the signed-in user's
/// board docs, and firestore.rules permit a client to write its own docs only.
/// Each other member is paid by their own device the next time it reads the
/// session, so the confirmation copy states that rather than implying the
/// owner credits the whole group.
class CompleteSessionButton extends ConsumerWidget {
  final SharedSession session;

  const CompleteSessionButton({super.key, required this.session});

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
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.flag_rounded),
        label: const Text('Complete Session'),
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final points = ProductivityPointsService.sharedSessionCompletionPoints;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Complete session?'),
        content: Text(
          'This marks "${session.name}" as finished. You earn $points points, '
          'and every other member earns $points the next time they open the '
          'app. This cannot be undone.',
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.hasError
              ? 'Could not complete session: ${result.error}'
              : 'Session completed — $points points added.',
        ),
        backgroundColor: result.hasError ? Colors.red.shade400 : Colors.green,
      ),
    );
  }
}

/// Shown to a non-owner member while the session is still running.
class _MemberWaitingNotice extends StatelessWidget {
  const _MemberWaitingNotice();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(
            Icons.hourglass_top_rounded,
            size: 18,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Waiting for the owner to complete this session. '
              'You will earn your points automatically when they do.',
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shown once a session has been completed, replacing the action button.
class _CompletionBanner extends StatelessWidget {
  final DateTime completedAt;

  const _CompletionBanner({required this.completedAt});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Session completed',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Finished ${_formatTimestamp(completedAt)}',
                  style: theme.textTheme.bodySmall,
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
