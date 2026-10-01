import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/session_service.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_state_views.dart';
import 'package:nlp_digitox/models/session_result.dart';
// `SessionMember` is re-exported by `shared_session_model.dart`, so importing it
// directly would be a redundant import.
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// Verified results for a shared run.
///
/// Reads `sessionResults/{sid}/{uid}` — a node **only** the completion webhook
/// may write — so what is shown here is the server's verdict, not the client's
/// claim. When no webhook is configured the node never appears and each member
/// simply sees their own completion state, which is the honest answer.
final _sessionResultsProvider = FutureProvider.autoDispose
    .family<List<SessionResult>, String>((ref, sessionId) {
  return SessionService.instance.getSessionResults(sessionId);
});

/// Shown after a shared run reaches `endAt`: who finished, and what it earned.
class SessionSummaryScreen extends ConsumerWidget {
  const SessionSummaryScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionStreamProvider(sessionId));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.trophy_20_regular,
          filledIcon: FluentIcons.trophy_20_filled,
          titleText: 'Session summary',
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ..._body(context, ref, sessionAsync),
              const SliverTabsBottomPadding(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _body(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<SharedSession?> sessionAsync,
  ) {
    return sessionAsync.when(
      loading: () => [_padded(const Center(child: CircularProgressIndicator()))],
      error: (error, _) => [
        _padded(
          SessionErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(sessionStreamProvider(sessionId)),
          ),
        ),
      ],
      data: (session) {
        if (session == null) {
          return [
            _padded(
              const SessionEmptyView(
                icon: FluentIcons.calendar_cancel_20_regular,
                title: 'Session unavailable',
                subtitle: 'It was removed before the summary could load.',
              ),
            ),
          ];
        }

        final resultsAsync = ref.watch(_sessionResultsProvider(sessionId));
        final results = resultsAsync.valueOrNull ?? const <SessionResult>[];
        final currentUserId = FirebaseAuthService.instance.userId;

        final myResult = _resultForUser(results, currentUserId);
        final points = myResult?.points ?? 0;
        final didComplete = myResult?.completed ??
            (session.memberFor(currentUserId ?? '')?.hasCompleted ?? false);

        return [
          _padded(
            _ResultHero(
              completed: didComplete,
              points: points,
              sessionName: session.name,
            ),
          ),
          _padded(_RosterCard(members: session.members, results: results)),
          _padded(_SummaryActions(sessionId: session.id)),
        ];
      },
    );
  }

  Widget _padded(Widget child) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
          child: child,
        ),
      );

  /// The signed-in member's verified result, or null when the webhook has not
  /// written one (no webhook configured, or the member was not credited).
  static SessionResult? _resultForUser(
    List<SessionResult> results,
    String? userId,
  ) {
    if (userId == null) return null;
    for (final result in results) {
      if (result.userId == userId) return result;
    }
    return null;
  }
}

/// The headline: did the member finish, and what did the server credit?
class _ResultHero extends StatelessWidget {
  const _ResultHero({
    required this.completed,
    required this.points,
    required this.sessionName,
  });

  final bool completed;
  final int points;
  final String sessionName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = completed ? DesignPalette.fern : colorScheme.primary;

    return SurfaceCard(
      elevation: 0,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(Spacing.lg),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              completed
                  ? FluentIcons.checkmark_circle_20_filled
                  : FluentIcons.hourglass_half_20_filled,
              size: 40,
              color: accent,
            ),
          ),
          const SizedBox(height: Spacing.md),
          StyledText(
            completed ? 'Run complete' : 'Session ended',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: Spacing.xs),
          StyledText(
            completed
                ? 'You finished "$sessionName" with the group.'
                : '"$sessionName" ended before the run was credited.',
            fontSize: 13,
            textAlign: TextAlign.center,
            color: colorScheme.onSurface.withValues(alpha: 0.7),
          ),
          if (points > 0) ...[
            const SizedBox(height: Spacing.lg),
            StyledText(
              '+$points points',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: accent,
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

/// Who took part and how each of them finished.
class _RosterCard extends StatelessWidget {
  const _RosterCard({required this.members, required this.results});

  final List<SessionMember> members;
  final List<SessionResult> results;

  @override
  Widget build(BuildContext context) {
    final completed = members.where((m) => m.hasCompleted).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'Results',
          subtitle: members.isEmpty
              ? 'No members'
              : '$completed of ${members.length} finished',
        ),
        const SizedBox(height: Spacing.sm),
        SurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          child: Column(
            children: [
              for (final member in members) ...[
                _ResultRow(
                  member: member,
                  result: _resultFor(member.userId),
                ),
                if (member != members.last)
                  const Divider(height: 0.5, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }

  SessionResult? _resultFor(String userId) {
    for (final result in results) {
      if (result.userId == userId) return result;
    }
    return null;
  }
}

/// One member's outcome row.
class _ResultRow extends StatelessWidget {
  const _ResultRow({required this.member, required this.result});

  final SessionMember member;
  final SessionResult? result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final didComplete = result?.completed ?? member.hasCompleted;
    final statusLabel = didComplete
        ? (result != null
            ? '${result!.focusedSec ~/ 60} min focused'
            : 'Finished')
        : member.isPresent
            ? 'Did not finish'
            : 'Left the run';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      leading: CircleAvatar(
        backgroundColor: (didComplete ? DesignPalette.fern : colorScheme.outline)
            .withValues(alpha: 0.15),
        child: Icon(
          didComplete
              ? FluentIcons.checkmark_20_filled
              : FluentIcons.dismiss_20_regular,
          size: 20,
          color: didComplete ? DesignPalette.fern : colorScheme.outline,
        ),
      ),
      title: StyledText(
        member.displayName,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: StyledText(statusLabel, fontSize: 12, isSubtitle: true),
      trailing: result != null && result!.points > 0
          ? StyledText(
              '+${result!.points}',
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: DesignPalette.fern,
            )
          : null,
    );
  }
}

/// Closing actions: back to the session list, or straight into another run.
class _SummaryActions extends StatelessWidget {
  const _SummaryActions({required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
            icon: const Icon(FluentIcons.arrow_left_20_filled, size: 18),
            label: const Text('Back to sessions'),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: Spacing.base),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Radii.pill),
              ),
            ),
          ),
        ),
        const SizedBox(height: Spacing.sm),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.of(context).pushNamed(AppRoutes.sharedSessionsPath);
            },
            icon: const Icon(FluentIcons.add_20_regular, size: 18),
            label: const Text('Start another session'),
            style: OutlinedButton.styleFrom(
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
