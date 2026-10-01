// Copyright (c) 2026 NLP digitox

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/core/services/group_service.dart';
import 'package:nlp_digitox/core/services/profile_service.dart';
import 'package:nlp_digitox/models/focus_group.dart';
import 'package:nlp_digitox/models/group_member.dart';
import 'package:nlp_digitox/models/group_schedule_entry.dart';
import 'package:nlp_digitox/models/group_stats.dart';
import 'package:nlp_digitox/providers/system/digitox_settings_provider.dart'
    show digitoxSettingsProvider;

/// The singleton group service.
final groupServiceProvider = Provider<GroupService>((ref) {
  // `init()` is idempotent, so watching this from any screen is enough to make
  // sure Firestore availability has been probed before the first call.
  unawaited(GroupService.instance.init());
  return GroupService.instance;
});

/// The name and photo to write onto a membership document.
///
/// Resolved once here rather than inside the service, which has no business
/// reading settings or the profile cache: the service takes an identity, the
/// provider decides what the identity is.
typedef GroupIdentity = ({String displayName, String? photoUrl});

/// The signed-in user's name and photo for group membership writes.
final groupIdentityProvider = FutureProvider<GroupIdentity>((ref) async {
  final username = ref.watch(digitoxSettingsProvider).username.trim();
  String? photoUrl;
  try {
    photoUrl = await ProfileService.instance.getProfileUrl();
  } catch (e) {
    // A missing avatar is not a reason to block a group action: the roster
    // falls back to an initial circle.
    debugPrint('groupIdentityProvider: could not read profile picture: $e');
  }
  return (displayName: username.isEmpty ? 'Me' : username, photoUrl: photoUrl);
});

/// Every group the signed-in user belongs to.
///
/// A Future rather than a Stream on purpose: the list changes only when the
/// user joins, leaves, creates or deletes a group — all of which this layer
/// invalidates itself — so a standing listener would cost a read for nothing
/// on every unrelated change.
final userGroupsProvider = FutureProvider.autoDispose<List<FocusGroup>>(
  (ref) => ref.watch(groupServiceProvider).getUserGroups(),
);

/// A live stream of one group, or null once it stops existing.
final groupStreamProvider = StreamProvider.autoDispose
    .family<FocusGroup?, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchGroup(groupId);
});

/// A live stream of one group's roster.
final groupMembersStreamProvider = StreamProvider.autoDispose
    .family<List<GroupMember>, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchMembers(groupId);
});

/// A live stream of one group's planned sessions, soonest first.
final groupScheduleStreamProvider = StreamProvider.autoDispose
    .family<List<GroupScheduleEntry>, String>((ref, groupId) {
  return ref.watch(groupServiceProvider).watchSchedule(groupId);
});

/// A live stream of the signed-in user's own record in one group.
final myGroupStatsStreamProvider = StreamProvider.autoDispose
    .family<GroupStats, String>((ref, groupId) {
  final service = ref.watch(groupServiceProvider);
  final userId = service.currentUserId;
  if (userId == null) {
    return Stream<GroupStats>.value(GroupStats.empty(''));
  }
  return service.watchStats(groupId: groupId, userId: userId);
});

/// The public group directory, for browsing groups to join.
final groupDirectoryProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>(
  (ref) => ref.watch(groupServiceProvider).getDirectory(),
);

/// Creates a group and reports the result.
class CreateGroupNotifier extends StateNotifier<AsyncValue<FocusGroup?>> {
  CreateGroupNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  final GroupService _service;
  final Ref _ref;

  Future<FocusGroup?> create({
    required String name,
    String? description,
    GroupVisibility visibility = GroupVisibility.private,
    required GroupIdentity identity,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.createGroup(
        name: name,
        description: description,
        visibility: visibility,
        displayName: identity.displayName,
        photoUrl: identity.photoUrl,
      ),
    );

    final created = state.valueOrNull;
    if (created != null) _ref.invalidate(userGroupsProvider);
    return created;
  }
}

/// Create-group provider.
final createGroupProvider = StateNotifierProvider.autoDispose<
    CreateGroupNotifier, AsyncValue<FocusGroup?>>((ref) {
  return CreateGroupNotifier(ref.watch(groupServiceProvider), ref);
});

/// Joins a group from an invite code and reports its id.
class JoinGroupNotifier extends StateNotifier<AsyncValue<String?>> {
  JoinGroupNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  final GroupService _service;
  final Ref _ref;

  /// Returns the joined group's id, or null when the join failed — the sheet
  /// then reads [state]'s error and shows it.
  Future<String?> joinByCode({
    required String code,
    required GroupIdentity identity,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.joinByCode(
        rawCode: code,
        displayName: identity.displayName,
        photoUrl: identity.photoUrl,
      ),
    );

    if (state.hasValue && state.valueOrNull != null) {
      _ref.invalidate(userGroupsProvider);
    }
    return state.valueOrNull;
  }

  /// Joins a listed group without a code.
  Future<String?> joinPublicGroup({
    required String groupId,
    required GroupIdentity identity,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => _service.joinPublicGroup(
        groupId: groupId,
        displayName: identity.displayName,
        photoUrl: identity.photoUrl,
      ),
    );

    if (state.hasValue && state.valueOrNull != null) {
      _ref.invalidate(userGroupsProvider);
      _ref.invalidate(groupStreamProvider(groupId));
    }
    return state.valueOrNull;
  }
}

/// Join-group provider.
final joinGroupProvider = StateNotifierProvider.autoDispose<
    JoinGroupNotifier, AsyncValue<String?>>((ref) {
  return JoinGroupNotifier(ref.watch(groupServiceProvider), ref);
});

/// Every group mutation a screen can trigger: leave, delete, edit, roster and
/// invite changes, schedule edits and the live-session pointer.
///
/// One notifier for all of them, matching [SessionLobbyNotifier]: from the
/// user's side these are one screen's set of buttons, and a single busy state
/// and a single error is what the UI actually needs.
class GroupActionsNotifier extends StateNotifier<AsyncValue<void>> {
  GroupActionsNotifier(this._service, this._ref)
      : super(const AsyncValue.data(null));

  final GroupService _service;
  final Ref _ref;

  Future<void> leave(String groupId) => _run(
        () => _service.leaveGroup(groupId),
        invalidate: [userGroupsProvider],
      );

  Future<void> delete(String groupId) => _run(
        () => _service.deleteGroup(groupId),
        invalidate: [
          userGroupsProvider,
          groupStreamProvider(groupId),
          groupMembersStreamProvider(groupId),
        ],
      );

  Future<void> updateGroup({
    required String groupId,
    String? name,
    String? description,
    GroupVisibility? visibility,
  }) =>
      _run(
        () => _service.updateGroup(
          groupId: groupId,
          name: name,
          description: description,
          visibility: visibility,
        ),
        invalidate: [groupStreamProvider(groupId), userGroupsProvider],
      );

  Future<void> removeMember({
    required String groupId,
    required String memberId,
  }) =>
      _run(
        () => _service.removeMember(groupId: groupId, memberId: memberId),
        invalidate: [
          groupMembersStreamProvider(groupId),
          groupStreamProvider(groupId),
        ],
      );

  Future<void> setMemberRole({
    required String groupId,
    required String memberId,
    required GroupRole role,
  }) =>
      _run(
        () => _service.setMemberRole(
          groupId: groupId,
          memberId: memberId,
          role: role,
        ),
        invalidate: [groupMembersStreamProvider(groupId)],
      );

  /// Issues a fresh invite code and returns it for the panel to display.
  ///
  /// Handled by hand rather than through [_run]: this notifier's state is
  /// `AsyncValue<void>`, so a code routed through it would be erased, and the
  /// panel needs the string itself.
  Future<String?> refreshInviteCode(String groupId) async {
    state = const AsyncValue.loading();
    try {
      final code = await _service.issueInviteCode(groupId);
      state = const AsyncValue.data(null);
      _ref.invalidate(groupStreamProvider(groupId));
      return code;
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      return null;
    }
  }

  Future<void> revokeInviteCode(String groupId) => _run(
        () => _service.revokeInviteCode(groupId),
        invalidate: [groupStreamProvider(groupId)],
      );

  Future<void> addScheduleEntry({
    required String groupId,
    required String title,
    required DateTime startsAt,
    required int durationSec,
    String type = 'study',
  }) =>
      _run(
        () => _service.addScheduleEntry(
          groupId: groupId,
          title: title,
          startsAt: startsAt,
          durationSec: durationSec,
          type: type,
        ),
        invalidate: [groupScheduleStreamProvider(groupId)],
      );

  Future<void> removeScheduleEntry({
    required String groupId,
    required String entryId,
  }) =>
      _run(
        () => _service.removeScheduleEntry(groupId: groupId, entryId: entryId),
        invalidate: [groupScheduleStreamProvider(groupId)],
      );

  Future<void> publishLiveSession({
    required String groupId,
    required String sessionId,
    String? code,
  }) =>
      _run(
        () => _service.publishLiveSession(
          groupId: groupId,
          sessionId: sessionId,
          code: code,
        ),
        invalidate: [groupStreamProvider(groupId), userGroupsProvider],
      );

  Future<void> clearLiveSession(String groupId) => _run(
        () => _service.clearLiveSession(groupId),
        invalidate: [groupStreamProvider(groupId), userGroupsProvider],
      );

  /// Runs [work] behind one busy state, then refreshes the given providers.
  Future<void> _run(
    Future<void> Function() work, {
    required List<ProviderOrFamily> invalidate,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(work);
    if (state.hasError) return;
    for (final provider in invalidate) {
      _ref.invalidate(provider);
    }
  }
}

/// Group action provider.
final groupActionsProvider = StateNotifierProvider.autoDispose<
    GroupActionsNotifier, AsyncValue<void>>((ref) {
  return GroupActionsNotifier(ref.watch(groupServiceProvider), ref);
});
