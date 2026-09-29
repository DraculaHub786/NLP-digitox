import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/productivity_points_service.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// Owner-only "Complete Session" action for the session detail screen.
///
/// Completing a session pays the owner straight away and marks the session
/// finished. It deliberately does *not* try to pay the other members from
/// here: `LeaderboardService.addPoints` only ever writes the signed-in user's
/// board docs, and firestore.rules permit a client to write its own docs only.
/// Each other member is paid by their own device the next time it reads the
/// session, so the confirmation copy states that rather than implying the
/// owner credits the whole group.
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
    final points = ProductivityPointsService.sharedSessionCompletionPoints;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: const Text('Complete session?'),
        content: Text(
          'This marks "${session.name}" as finished. The $points points go to '
          'members who focused with the group and finished their focus run — '
          'including you, if you did. This cannot be undone.',
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
        backgroundColor: result.hasError
            ? Theme.of(context).colorScheme.error
            : DesignPalette.fern,
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
              'run with the group and your '
              '${ProductivityPointsService.sharedSessionCompletionPoints} '
              'points are added automatically once they complete it.',
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
