import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/complete_session_button.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_member_tile.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_state_views.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';

/// Detail view for one shared focus session: who is in it, what it enforces,
/// and the actions the member can take (focus together / complete / leave).
///
/// Uses the app's standard [ScaffoldShell] so it inherits the botanical
/// background, serif title and back affordance, and every block is built from
/// the shared card + list primitives, so it tracks the light and dark palettes
/// automatically.
class SessionDetailScreen extends ConsumerWidget {
  const SessionDetailScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionDetailProvider(sessionId)).valueOrNull;

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.people_20_regular,
          filledIcon: FluentIcons.people_20_filled,
          titleText: session?.name ?? 'Session',
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ..._bodySlivers(context, ref),
              const SliverTabsBottomPadding(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _bodySlivers(BuildContext context, WidgetRef ref) {
    final sessionAsync = ref.watch(sessionDetailProvider(sessionId));
    final membersAsync = ref.watch(sessionMembersProvider(sessionId));

    return sessionAsync.when(
      loading: () => [_centredSliver(const CircularProgressIndicator())],
      error: (error, _) => [
        _centredSliver(
          SessionErrorView(
            message: error.toString(),
            onRetry: () => ref.invalidate(sessionDetailProvider(sessionId)),
          ),
        ),
      ],
      data: (session) {
        if (session == null) {
          return [
            _centredSliver(
              const SessionEmptyView(
                icon: FluentIcons.calendar_cancel_20_regular,
                title: 'Session not found',
                subtitle: 'The owner may have ended it, or the ID is no longer '
                    'valid.',
              ),
            ),
          ];
        }

        return [
          // Headline metrics
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: Row(
                children: [
                  Expanded(
                    child: ModernMetricCard(
                      // "3/10" rather than "3": the cap is the fact the owner
                      // cares about, and a bare count cannot show how close the
                      // room is to being closed.
                      label: 'Members',
                      value:
                          '${session.memberCount}/${session.maxMembers}',
                      icon: FluentIcons.people_20_filled,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: Spacing.md),
                  Expanded(
                    child: ModernMetricCard(
                      label: 'Focusing now',
                      value: '${session.activeMembers}',
                      icon: FluentIcons.flash_20_filled,
                      color: DesignPalette.fern,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 350.ms).slideY(begin: 0.04, end: 0),
          ),

          // Session metadata
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: _SessionDetailsCard(session: session),
            ),
          ),

          // Members
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: ModernSectionHeader(
                title: 'Members',
                subtitle: membersAsync.valueOrNull == null
                    ? 'Loading members…'
                    : _memberCountLabel(
                        session.memberCount,
                        session.maxMembers,
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: membersAsync.when(
                loading: () => const SurfaceCard(
                  padding: EdgeInsets.symmetric(vertical: Spacing.xl),
                  elevation: 0,
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => SurfaceCard(
                  elevation: 0,
                  child: StyledText(
                    'Could not load members: $error',
                    fontSize: 13,
                    isSubtitle: true,
                  ),
                ),
                data: (members) => _MembersCard(
                  members: members,
                  ownerId: session.ownerId,
                  currentUserId: FirebaseAuthService.instance.userId,
                ),
              ),
            ),
          ),

          // Actions
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: _SessionActions(session: session),
            ),
          ),
        ];
      },
    );
  }

  /// Seats used out of the room's cap, with the closed state called out so the
  /// owner can see at a glance that nobody else can get in.
  static String _memberCountLabel(int count, int maxMembers) {
    final seats = '$count of $maxMembers seats taken';
    return count >= maxMembers ? '$seats • Full' : seats;
  }

  Widget _centredSliver(Widget child) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
          child: Center(child: child),
        ),
      );
}

/// Grouped member rows inside one card, matching the leaderboard's
/// "Rest of the Board" treatment.
class _MembersCard extends StatelessWidget {
  const _MembersCard({
    required this.members,
    required this.ownerId,
    this.currentUserId,
  });

  final List<SessionMember> members;
  final String ownerId;

  /// The signed-in user, so their own row can be accented. Resolved once by
  /// the screen instead of per-row from the auth singleton.
  final String? currentUserId;

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty) {
      return const SurfaceCard(
        elevation: 0,
        child: StyledText(
          'No members yet — share the session ID to invite people.',
          fontSize: 13,
          isSubtitle: true,
        ),
      );
    }

    return SurfaceCard(
      padding: EdgeInsets.zero,
      elevation: 0,
      child: Column(
        children: [
          for (final member in members) ...[
            SessionMemberTile(
              member: member,
              isOwner: member.userId == ownerId,
              isMe: member.userId == currentUserId,
            ),
            if (member != members.last)
              const Divider(height: 0.5, indent: 56),
          ],
        ],
      ),
    );
  }
}
/// Metadata block: visibility, theme, description and creation date, rendered
/// as the app's standard dashboard card.
class _SessionDetailsCard extends StatelessWidget {
  const _SessionDetailsCard({required this.session});

  final SharedSession session;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final description = session.description;
    final theme = session.theme;

    return ModernDashboardCard(
      title: 'Session Details',
      subtitle: session.isPublic
          ? 'Anyone can find this group in Discover'
          : 'Private — invite only, shared by ID',
      icon: const Icon(FluentIcons.info_20_filled),
      accentColor: colorScheme.primary,
      children: [
        _detailRow(
          context,
          icon: session.isPublic
              ? FluentIcons.globe_20_regular
              : FluentIcons.lock_closed_20_regular,
          label: 'Visibility',
          value: session.isPublic ? 'Public' : 'Private',
        ),
        if (theme != null && theme.isNotEmpty) ...[
          const SizedBox(height: Spacing.md),
          _detailRow(
            context,
            icon: FluentIcons.tag_20_regular,
            label: 'Theme',
            value: theme,
          ),
        ],
        const SizedBox(height: Spacing.md),
        _detailRow(
          context,
          icon: FluentIcons.calendar_ltr_20_regular,
          label: 'Created',
          value: _formatDate(session.createdAt),
        ),
        if (description != null && description.trim().isNotEmpty) ...[
          const SizedBox(height: Spacing.base),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(Spacing.md),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(Radii.md),
            ),
            child: StyledText(
              description.trim(),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: Spacing.md),
        Expanded(
          child: StyledText(
            label,
            fontSize: 14,
            isSubtitle: true,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: Spacing.sm),
        Flexible(
          flex: 0,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: StyledText(
              value,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  static String _formatDate(DateTime value) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final month = months[(value.month - 1).clamp(0, 11)];
    return '${value.day} $month ${value.year}';
  }
}

/// Everything the member can do with this session: start/stop a shared focus
/// run, complete it (owner only), or leave it.
class _SessionActions extends ConsumerWidget {
  const _SessionActions({required this.session});

  final SharedSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final isInSharedFocus =
        ref.watch(focusModeProvider.notifier).isInSharedSessionFocus;
    final leaveState = ref.watch(leaveSessionProvider);

    // Once a session is finished there is nothing left to run or join, so the
    // only remaining action is leaving the (now-closed) group.
    //
    // The settings are never null: a session with none stored simply has every
    // member focus on their own plan (see `SharedSession.groupFocusSettings`),
    // so the group-focus action stays reachable for every active session
    // instead of being disabled until somebody configures a shared one. That
    // gate made group focus impossible for every session created in the app,
    // because the create sheet never supplied settings.
    final settings = session.groupFocusSettings;
    final canFocus = session.canStartGroupFocus;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isInSharedFocus)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () =>
                  ref.read(focusModeProvider.notifier).endSharedSession(),
              icon: const Icon(FluentIcons.stop_20_filled, size: 18),
              label: const Text('Stop Focusing With This Group'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          )
        else if (!session.isCompleted)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: canFocus
                  ? () {
                      ref.read(focusModeProvider.notifier)
                          .startSessionFromSharedSettings(
                        settings: settings,
                        sessionId: session.id,
                      );
                      Navigator.of(context)
                          .pushNamed(AppRoutes.activeSessionPath);
                    }
                  : null,
              icon: const Icon(FluentIcons.play_20_filled, size: 18),
              label: const Text('Start Focusing With This Group'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ),

        const SizedBox(height: Spacing.md),

        // Owner-only completion — marks the session finished and pays out the
        // completion points.
        CompleteSessionButton(session: session),

        const SizedBox(height: Spacing.md),

        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: leaveState.isLoading
                ? null
                : () => _confirmLeave(context, ref),
            icon: leaveState.isLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(FluentIcons.arrow_exit_20_regular, size: 18),
            label: const Text('Leave Session'),
            style: OutlinedButton.styleFrom(
              foregroundColor: colorScheme.error,
              side: BorderSide(
                color: colorScheme.error.withValues(alpha: 0.45),
              ),
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

  Future<void> _confirmLeave(BuildContext context, WidgetRef ref) async {
    final colorScheme = Theme.of(context).colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: const Text('Leave session?'),
        content: const Text(
          'Are you sure? If you are the owner, the session will be marked '
          'inactive.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await ref.read(leaveSessionProvider.notifier).leaveSession(session.id);

    if (!context.mounted) return;

    // The session is gone from the user's list, so this screen has nothing
    // left to show.
    Navigator.of(context).pop();
  }
}
