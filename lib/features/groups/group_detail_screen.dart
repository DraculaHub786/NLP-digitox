// Copyright (c) 2026 NLP digitox

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/core/services/firebase_auth_service.dart';
import 'package:nlp_digitox/core/services/session_notifications.dart';
import 'package:nlp_digitox/features/groups/group_error_message.dart';
import 'package:nlp_digitox/features/groups/widgets/add_schedule_entry_sheet.dart';
import 'package:nlp_digitox/features/groups/widgets/group_detail_sections.dart';
import 'package:nlp_digitox/features/groups/widgets/group_invite_panel.dart';
import 'package:nlp_digitox/features/groups/widgets/group_roster_section.dart';
import 'package:nlp_digitox/features/groups/widgets/group_schedule_section.dart';
import 'package:nlp_digitox/features/shared_sessions/session_lobby_screen.dart';
import 'package:nlp_digitox/features/shared_sessions/widgets/report_block_sheet.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_member.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';
import 'package:nlp_digitox/providers/group_provider.dart';
import 'package:nlp_digitox/providers/session_provider.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';

/// One group: its roster, its schedule, and the run it is doing right now.
///
/// The live session a group starts still lives in the Realtime Database — this
/// screen only holds the pointer to it. "Join the run" therefore opens the same
/// lobby every other join path uses, rather than growing a second way to enter
/// a session.
class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.groupId});

  final String groupId;

  @override
  ConsumerState<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  bool _isStartingRun = false;

  @override
  Widget build(BuildContext context) {
    final groupAsync = ref.watch(groupStreamProvider(widget.groupId));

    return ScaffoldShell(
      items: [
        NavbarItem(
          icon: FluentIcons.people_team_20_regular,
          filledIcon: FluentIcons.people_team_20_filled,
          titleText: groupAsync.valueOrNull?.name ?? 'Group',
          sliverBody: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              ..._bodySlivers(groupAsync),
              const SliverTabsBottomPadding(),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _bodySlivers(AsyncValue<FocusGroup?> groupAsync) {
    return groupAsync.when(
      loading: () => [_centre(const CircularProgressIndicator())],
      error: (error, _) => [
        _centre(
          GroupErrorView(
            message: groupErrorMessage(error, 'load'),
            onRetry: () => ref.invalidate(groupStreamProvider(widget.groupId)),
          ),
        ),
      ],
      data: (group) {
        if (group == null) {
          return [
            _centre(
              const GroupEmptyView(
                icon: FluentIcons.people_team_20_regular,
                title: 'Group not found',
                subtitle: 'The owner may have deleted it, or you have left.',
              ),
            ),
          ];
        }

        final members = ref
                .watch(groupMembersStreamProvider(widget.groupId))
                .valueOrNull ??
            const <GroupMember>[];
        final schedule = ref
                .watch(groupScheduleStreamProvider(widget.groupId))
                .valueOrNull ??
            const <GroupScheduleEntry>[];
        final busy = ref.watch(groupActionsProvider).isLoading;

        return [
          if (group.hasLiveSession)
            _padded(LiveSessionBanner(onTap: () => _joinLiveRun(group))),
          _padded(GroupOverviewCard(group: group, schedule: schedule)),
          _padded(
            GroupRecordCard(
              statsAsync:
                  ref.watch(myGroupStatsStreamProvider(widget.groupId)),
            ),
          ),
          _padded(
            GroupRosterSection(
              group: group,
              members: members,
              currentUserId: FirebaseAuthService.instance.userId,
              onReportBlock: (member) => _reportBlock(group, member),
              onRemoveMember: (member) => _removeMember(group, member),
              onToggleRole: (member) => _toggleRole(group, member),
            ),
          ),
          _padded(
            GroupInvitePanel(
              groupName: group.name,
              code: group.inviteCode,
              canManage: group.canManage,
              isBusy: busy,
              onRefreshCode: () => _refreshInvite(group),
              onRevokeCode: () => _revokeInvite(group),
            ),
          ),
          _padded(
            GroupScheduleSection(
              entries: schedule,
              canManage: group.canManage,
              onAdd: () => _addScheduleEntry(group),
              onRemove: (entry) => _removeScheduleEntry(group, entry),
            ),
          ),
          _padded(
            GroupActionBar(
              group: group,
              isBusy: busy,
              isStartingRun: _isStartingRun,
              onStartRun: () => _startGroupRun(group),
              onLeave: () => _leave(group),
            ),
          ),
        ];
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Actions
  // ---------------------------------------------------------------------------

  /// Starts a shared session owned by this group and publishes the pointer.
  ///
  /// The run itself is an ordinary shared session: it is created with the
  /// group's id, and the group document is then given a pointer to it so every
  /// member sees "a session is running now" without opening the Realtime
  /// Database.
  Future<void> _startGroupRun(FocusGroup group) async {
    if (_isStartingRun) return;
    setState(() => _isStartingRun = true);

    try {
      final session = await ref.read(sessionServiceProvider).createSession(
            name: group.name,
            description: group.description,
            groupId: group.id,
            hostDisplayName: group.name,
          );

      await ref.read(groupActionsProvider.notifier).publishLiveSession(
            groupId: group.id,
            sessionId: session.id,
            code: session.inviteCode,
          );

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => SessionLobbyScreen(sessionId: session.id),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      _showMessage(groupErrorMessage(error, 'start a session for'));
    } finally {
      if (mounted) setState(() => _isStartingRun = false);
    }
  }

  /// Joins the run a group is doing right now.
  Future<void> _joinLiveRun(FocusGroup group) async {
    final pointer = group.liveSession;
    if (pointer == null) return;

    // The pointer carries the session's code so a member who is not yet in the
    // session takes the same join path every other screen uses, rather than
    // being dropped into a lobby the rules would refuse them.
    final code = pointer.code;
    if (code != null) {
      final identity = await ref.read(groupIdentityProvider.future);
      final joined = await ref.read(joinByCodeProvider.notifier).joinByCode(
            code: code,
            displayName: identity.displayName,
            photoUrl: identity.photoUrl,
          );
      if (!mounted) return;
      if (joined == null) {
        _showMessage(
          groupErrorMessage(
            ref.read(joinByCodeProvider).error ?? 'Could not join the run.',
            'join',
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SessionLobbyScreen(sessionId: pointer.sessionId),
      ),
    );
  }

  Future<void> _addScheduleEntry(FocusGroup group) async {
    final added = await showAddScheduleEntrySheet(context, groupId: group.id);
    if (added != true) return;
    // A new plan is a new alarm: resync so the reminder exists even if the user
    // never returns to the groups list.
    await SessionNotificationsService.instance.syncGroupReminders();
  }

  Future<void> _removeScheduleEntry(
    FocusGroup group,
    GroupScheduleEntry entry,
  ) async {
    final confirmed = await _confirm(
      title: 'Remove this planned session?',
      body: '"${entry.title}" will be taken off the schedule and its reminder '
          'cancelled.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed != true) return;

    await ref
        .read(groupActionsProvider.notifier)
        .removeScheduleEntry(groupId: group.id, entryId: entry.id);
    _showActionError('remove that planned session');
    if (!mounted) return;
    await SessionNotificationsService.instance.syncGroupReminders();
  }

  Future<String?> _refreshInvite(FocusGroup group) async {
    final code = await ref
        .read(groupActionsProvider.notifier)
        .refreshInviteCode(group.id);
    _showActionError('create an invite code');
    return code;
  }

  Future<void> _revokeInvite(FocusGroup group) async {
    final confirmed = await _confirm(
      title: 'Revoke the invite code?',
      body: 'The current code will stop working immediately. Anyone who has '
          'not joined yet will need a new one.',
      confirmLabel: 'Revoke',
      destructive: true,
    );
    if (confirmed != true) return;

    await ref.read(groupActionsProvider.notifier).revokeInviteCode(group.id);
    _showActionError('revoke the invite');
  }

  Future<void> _removeMember(FocusGroup group, GroupMember member) async {
    final confirmed = await _confirm(
      title: 'Remove ${member.displayName}?',
      body: 'They will be removed from the group and stop receiving its '
          'session reminders.',
      confirmLabel: 'Remove',
      destructive: true,
    );
    if (confirmed != true) return;

    await ref.read(groupActionsProvider.notifier).removeMember(
          groupId: group.id,
          memberId: member.userId,
        );
    _showActionError('remove the member from');
  }

  Future<void> _toggleRole(FocusGroup group, GroupMember member) async {
    final nextRole =
        member.role == GroupRole.admin ? GroupRole.member : GroupRole.admin;
    await ref.read(groupActionsProvider.notifier).setMemberRole(
          groupId: group.id,
          memberId: member.userId,
          role: nextRole,
        );
    _showActionError('change the role of');
  }

  void _reportBlock(FocusGroup group, GroupMember member) {
    showReportBlockSheet(
      context,
      targetUid: member.userId,
      targetDisplayName: member.displayName,
      groupId: group.id,
    );
  }

  Future<void> _leave(FocusGroup group) async {
    if (group.isOwnedByMe) {
      await _confirm(
        title: 'You own ${group.name}',
        body: 'An owner cannot leave their own group — that would leave nobody '
            'able to manage it.',
        confirmLabel: 'Close',
      );
      return;
    }

    final confirmed = await _confirm(
      title: 'Leave ${group.name}?',
      body: 'You will be removed from the roster and stop receiving its '
          'session reminders.',
      confirmLabel: 'Leave',
      destructive: true,
    );
    if (confirmed != true) return;

    await ref.read(groupActionsProvider.notifier).leave(group.id);
    _showActionError('leave the group');
    if (!mounted) return;
    await SessionNotificationsService.instance.syncGroupReminders();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _showActionError(String action) {
    final error = ref.read(groupActionsProvider).error;
    if (error == null || !mounted) return;
    _showMessage(groupErrorMessage(error, action));
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
