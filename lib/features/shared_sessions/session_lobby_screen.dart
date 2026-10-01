import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/config/navigation/app_routes.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/session_focus_bridge.dart';
import 'package:nlp_digitox/features/shared_sessions/session_summary_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_invite_panel.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/session_state_views.dart';
import 'package:nlp_digitox/models/shared_session_model.dart';
import 'package:nlp_digitox/providers/focus/focus_mode_provider.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/screens/home/dashboard/modern_dashboard_components.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/surface_card.dart';

/// The room before a run: who is here, who is ready, and the host's controls.
///
/// The lobby does not *own* the start time — the host writes a single server
/// timestamp and every device (this one included) derives the countdown from
/// it. What this screen does is watch that derived phase and, the moment it
/// flips to `running`, start this device's focus run and move to the timer.
/// That is the only place the two machines are joined.
class SessionLobbyScreen extends ConsumerStatefulWidget {
  const SessionLobbyScreen({super.key, required this.sessionId});

  final String sessionId;

  @override
  ConsumerState<SessionLobbyScreen> createState() => _SessionLobbyScreenState();
}

class _SessionLobbyScreenState extends ConsumerState<SessionLobbyScreen> {
  bool _hasHandledStart = false;
  bool _hasHandledFinish = false;

  /// Reacts to the shared phase changing.
  ///
  /// Started here rather than in a service so the focus run is tied to a screen
  /// that is actually on screen — leaving the lobby disposes the listener, and
  /// only the member looking at the room is the one who starts their own run.
  void _onPhaseChanged(SessionPhase? previous, SessionPhase next) {
    final session = ref.read(sessionStreamProvider(widget.sessionId)).valueOrNull;
    if (session == null) return;

    if (next == SessionPhase.running && !_hasHandledStart) {
      _hasHandledStart = true;
      _beginFocusRun(session);
    } else if (next == SessionPhase.finished && !_hasHandledFinish) {
      _hasHandledFinish = true;
      _finishRun(session);
    }
  }

  Future<void> _beginFocusRun(SharedSession session) async {
    final focus = ref.read(focusModeProvider.notifier);
    await SessionFocusBridge.instance.startRun(session: session, focus: focus);
    if (!mounted) return;
    Navigator.of(context).pushNamed(AppRoutes.activeSessionPath);
  }

  Future<void> _finishRun(SharedSession session) async {
    await SessionFocusBridge.instance.completeRun(session);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => SessionSummaryScreen(sessionId: session.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<SessionPhase>(
      sessionPhaseProvider(widget.sessionId),
      _onPhaseChanged,
    );

    final sessionAsync = ref.watch(sessionStreamProvider(widget.sessionId));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.people_community_20_regular,
          filledIcon: FluentIcons.people_community_20_filled,
          titleText: sessionAsync.valueOrNull?.name ?? 'Session lobby',
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ..._bodySlivers(sessionAsync),
              const SliverTabsBottomPadding(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _bodySlivers(AsyncValue<SharedSession?> sessionAsync) {
    return sessionAsync.when(
      loading: () => [_centre(const CircularProgressIndicator())],
      error: (error, _) => [
        _centre(
          SessionErrorView(
            message: error.toString(),
            onRetry: () =>
                ref.invalidate(sessionStreamProvider(widget.sessionId)),
          ),
        ),
      ],
      data: (session) {
        if (session == null) {
          return [
            _centre(
              const SessionEmptyView(
                icon: FluentIcons.calendar_cancel_20_regular,
                title: 'Session not found',
                subtitle: 'The host may have ended it, or the code is no '
                    'longer valid.',
              ),
            ),
          ];
        }

        if (session.isCancelled) {
          return [
            _centre(
              const SessionEmptyView(
                icon: FluentIcons.dismiss_circle_20_regular,
                title: 'Session cancelled',
                subtitle: 'The host ended this session before it started.',
              ),
            ),
          ];
        }

        final membersAsync =
            ref.watch(sessionMembersStreamProvider(widget.sessionId));
        final members = membersAsync.valueOrNull ?? session.members;

        return [
          _padded(_LobbyHeader(session: session)),
          _padded(
            _MembersSection(
              members: members,
              ownerId: session.ownerId,
              currentUserId: FirebaseAuthService.instance.userId,
              isHost: session.isOwnedBy(
                FirebaseAuthService.instance.userId ?? '',
              ),
              onKick: _onKick,
            ),
          ),
          _padded(
            SessionInvitePanel(
              code: session.inviteCode,
              sessionName: session.name,
              durationSec: session.durationSec,
            ),
          ),
          _padded(_LobbyActions(session: session, onLeave: _onLeave)),
        ];
      },
    );
  }

  Future<void> _onKick(SessionMember member) async {
    final confirmed = await _confirm(
      title: 'Remove ${member.displayName}?',
      body: 'They will be removed from the lobby and can only rejoin with a '
          'valid invite.',
      confirmLabel: 'Remove',
    );
    if (confirmed != true) return;

    await ref.read(sessionLobbyProvider.notifier).kick(
          sessionId: widget.sessionId,
          memberId: member.userId,
        );
    _showError();
  }

  Future<void> _onLeave() async {
    final confirmed = await _confirm(
      title: 'Leave this session?',
      body: 'You will drop out of the lobby. The host can still start the '
          'session without you.',
      confirmLabel: 'Leave',
      destructive: true,
    );
    if (confirmed != true) return;

    await ref.read(sessionLobbyProvider.notifier).leave(widget.sessionId);
    if (!mounted) return;
    Navigator.of(context).maybePop();
  }

  Future<bool?> _confirm({
    required String title,
    required String body,
    required String confirmLabel,
    bool destructive = false,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Radii.xl),
        ),
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: destructive
                ? ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  /// Surfaces the last lobby-action error, if any.
  void _showError() {
    final error = ref.read(sessionLobbyProvider).error;
    if (error == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }

  Widget _padded(Widget child) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
          child: child,
        ),
      );

  Widget _centre(Widget child) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: Spacing.xxl),
          child: Center(child: child),
        ),
      );
}
/// Headline for the lobby: what kind of run this is, how long, and — once the
/// host has started — the shared countdown every device is showing.
class _LobbyHeader extends ConsumerWidget {
  const _LobbyHeader({required this.session});

  final SharedSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final phase = ref.watch(sessionPhaseProvider(session.id));
    final clock = ref.watch(sessionClockProvider);
    final nowMs = ref.watch(sessionTickerProvider).valueOrNull ?? clock.nowMs();
    final countdown = session.countdownRemainingSecAt(nowMs);

    return SurfaceCard(
      elevation: 0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ModernMetricCard(
                  label: 'Duration',
                  value: '${session.durationSec ~/ 60} min',
                  icon: FluentIcons.timer_20_filled,
                  color: colorScheme.primary,
                ),
              ),
              const SizedBox(width: Spacing.md),
              Expanded(
                child: ModernMetricCard(
                  label: 'Members',
                  value: '${session.memberCount}/${session.maxMembers}',
                  icon: FluentIcons.people_20_filled,
                  color: DesignPalette.fern,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              Icon(
                FluentIcons.clock_20_regular,
                size: 16,
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: StyledText(
                  countdown != null
                      ? 'Starting in $countdown…'
                      : 'Waiting for everyone to get ready.',
                  fontSize: 13,
                  isSubtitle: true,
                ),
              ),
              _PhaseChip(label: phase.label),
            ],
          ),
        ],
      ),
    );
  }
}

/// Small status chip beside the header line.
class _PhaseChip extends StatelessWidget {
  const _PhaseChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(Radii.pill),
      ),
      child: StyledText(
        label,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// The member list, with a ready badge and — for the host — a remove action.
class _MembersSection extends StatelessWidget {
  const _MembersSection({
    required this.members,
    required this.ownerId,
    required this.currentUserId,
    required this.isHost,
    required this.onKick,
  });

  final List<SessionMember> members;
  final String ownerId;
  final String? currentUserId;
  final bool isHost;
  final Future<void> Function(SessionMember member) onKick;

  @override
  Widget build(BuildContext context) {
    final present = members.where((m) => m.isPresent).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ModernSectionHeader(
          title: 'In the lobby',
          subtitle: _subtitle(present),
        ),
        const SizedBox(height: Spacing.sm),
        SurfaceCard(
          padding: EdgeInsets.zero,
          elevation: 0,
          child: Column(
            children: [
              for (final member in present) ...[
                _MemberRow(
                  member: member,
                  isHost: member.userId == ownerId,
                  isMe: member.userId == currentUserId,
                  canKick: isHost &&
                      member.userId != currentUserId &&
                      member.userId != ownerId,
                  onKick: () => onKick(member),
                ),
                if (member != present.last)
                  const Divider(height: 0.5, indent: 56),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static String _subtitle(List<SessionMember> present) {
    final ready = present.where((m) => m.isReady).length;
    if (present.isEmpty) return 'Nobody here yet';
    return '$ready of ${present.length} ready';
  }
}

/// One member row: avatar, name, role/ready badges, optional kick button.
class _MemberRow extends StatelessWidget {
  const _MemberRow({
    required this.member,
    required this.isHost,
    required this.isMe,
    required this.canKick,
    required this.onKick,
  });

  final SessionMember member;
  final bool isHost;
  final bool isMe;
  final bool canKick;
  final VoidCallback onKick;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: Spacing.md),
      leading: _MemberAvatar(member: member),
      title: StyledText(
        isMe ? '${member.displayName} (you)' : member.displayName,
        fontSize: 15,
        fontWeight: FontWeight.w600,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: StyledText(
        isHost ? 'Host' : member.status.label,
        fontSize: 12,
        isSubtitle: true,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (member.isReady)
            Icon(
              FluentIcons.checkmark_circle_20_filled,
              size: 20,
              color: DesignPalette.fern,
            ),
          if (canKick) ...[
            const SizedBox(width: Spacing.sm),
            IconButton(
              tooltip: 'Remove from lobby',
              onPressed: onKick,
              icon: Icon(
                FluentIcons.dismiss_circle_20_regular,
                color: colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Avatar with a graceful fallback to the member's initial.
class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({required this.member});

  final SessionMember member;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final photoUrl = member.photoUrl;
    final initial = member.displayName.trim().isEmpty
        ? '?'
        : member.displayName.trim().substring(0, 1).toUpperCase();

    return CircleAvatar(
      radius: 20,
      backgroundColor: colorScheme.primaryContainer,
      foregroundImage:
          photoUrl != null && photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
      child: StyledText(
        initial,
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

/// The lobby's action bar: ready toggle for everyone, host controls for the
/// owner.
class _LobbyActions extends ConsumerWidget {
  const _LobbyActions({required this.session, required this.onLeave});

  final SharedSession session;
  final Future<void> Function() onLeave;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final currentUserId = FirebaseAuthService.instance.userId;
    final isHost = session.isOwnedBy(currentUserId ?? '');
    final me = session.memberFor(currentUserId ?? '');
    final lobbyState = ref.watch(sessionLobbyProvider);
    final isBusy = lobbyState.isLoading;

    final readyCount = session.presentMembers.where((m) => m.isReady).length;

    return Column(
      children: [
        // Ready toggle — every member, host included.
        SizedBox(
          width: double.infinity,
          child: (me?.isReady ?? false)
              ? OutlinedButton.icon(
                  onPressed: isBusy
                      ? null
                      : () => _setReady(ref, context, ready: false),
                  icon: const Icon(FluentIcons.checkmark_circle_20_filled,
                      size: 18),
                  label: const Text('Ready — tap to un-ready'),
                  style: OutlinedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: Spacing.base),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                )
              : FilledButton.icon(
                  onPressed:
                      isBusy ? null : () => _setReady(ref, context, ready: true),
                  icon: const Icon(FluentIcons.checkmark_20_filled, size: 18),
                  label: const Text('I am ready'),
                  style: FilledButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: Spacing.base),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Radii.pill),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: Spacing.md),

        if (isHost) ...[
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isBusy ? null : () => _start(ref, context),
              icon: const Icon(FluentIcons.play_20_filled, size: 18),
              label: Text(
                readyCount > 0
                    ? 'Start now ($readyCount ready)'
                    : 'Start on my own',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: Spacing.base),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
            ),
          ),
          const SizedBox(height: Spacing.md),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: isBusy ? null : () => _cancel(ref, context),
              icon: const Icon(FluentIcons.dismiss_circle_20_regular, size: 18),
              label: const Text('Cancel session'),
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
          const SizedBox(height: Spacing.md),
        ],

        SizedBox(
          width: double.infinity,
          child: TextButton.icon(
            onPressed: isBusy ? null : onLeave,
            icon: const Icon(FluentIcons.arrow_exit_20_regular, size: 18),
            label: const Text('Leave lobby'),
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.error,
              padding: const EdgeInsets.symmetric(vertical: Spacing.base),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _setReady(
    WidgetRef ref,
    BuildContext context, {
    required bool ready,
  }) async {
    await ref.read(sessionLobbyProvider.notifier).setReady(
          sessionId: session.id,
          ready: ready,
        );
    if (!context.mounted) return;
    _showError(ref, context);
  }

  Future<void> _start(WidgetRef ref, BuildContext context) async {
    await ref
        .read(sessionLobbyProvider.notifier)
        .start(session.id, durationSec: session.durationSec);
    if (!context.mounted) return;
    _showError(ref, context);
  }

  Future<void> _cancel(WidgetRef ref, BuildContext context) async {
    await ref.read(sessionLobbyProvider.notifier).cancel(session.id);
    if (!context.mounted) return;
    _showError(ref, context);
  }

  void _showError(WidgetRef ref, BuildContext context) {
    final error = ref.read(sessionLobbyProvider).error;
    if (error == null || !context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error.toString())),
    );
  }
}
