// Copyright (c) 2026 NLP digitox

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/constants/group_limits.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';
import 'package:nlp_digitox/models/group_member.dart';

/// Who can find and join a group.
///
/// A group is durable, so its visibility decides more than one thing: whether
/// it appears in the directory at all, and whether someone who has never been
/// handed the invite code has any path into it.
enum GroupVisibility {
  /// Reachable only with the invite code. Never listed.
  private,

  /// Listed in `group_directory/{gid}` for every signed-in user to find, and
  /// joinable either from that list or with the invite code.
  public;

  /// Wire value stored in Firestore.
  String get wireName {
    switch (this) {
      case GroupVisibility.private:
        return 'private';
      case GroupVisibility.public:
        return 'public';
    }
  }

  /// Whether this group is listed in the directory.
  bool get isListed => this == GroupVisibility.public;

  /// The label shown on the group screen.
  String get label {
    switch (this) {
      case GroupVisibility.private:
        return 'Private';
      case GroupVisibility.public:
        return 'Discoverable';
    }
  }

  /// Parses a stored visibility.
  ///
  /// Anything unrecognised — including a group written before `visibility`
  /// existed — reads as [GroupVisibility.private]. Failing closed matters here:
  /// reading "unknown" as public would list a private group for strangers.
  static GroupVisibility parse(dynamic raw) {
    if (raw is String) {
      for (final value in GroupVisibility.values) {
        if (value.wireName == raw) return value;
      }
    }
    return GroupVisibility.private;
  }
}

/// A pointer from a group to the shared session it is currently running.
///
/// Stored on the group document so the detail screen can offer "join the run
/// that is happening now" without querying the Realtime Database first. It is
/// cleared the moment the session ends.
@immutable
class GroupLiveSession {
  /// The live session's id in the Realtime Database.
  final String sessionId;

  /// The invite code for that session, so a member who is not yet in it can
  /// join by the same code path every other screen uses.
  final String? code;

  /// When the pointer was written.
  final DateTime startedAt;

  const GroupLiveSession({
    required this.sessionId,
    this.code,
    required this.startedAt,
  });

  /// Reads a pointer out of the group document.
  ///
  /// Returns null rather than a half-populated object when the session id is
  /// missing: a pointer that names nothing is worse than no pointer, because
  /// the UI would render a live-session banner that leads nowhere.
  static GroupLiveSession? fromFirestore(dynamic raw) {
    if (raw is! Map) return null;
    final map = Map<String, dynamic>.from(raw);
    final sessionId = FirestoreValueUtils.stringOrNull(map['sessionId']);
    if (sessionId == null) return null;
    return GroupLiveSession(
      sessionId: sessionId,
      code: FirestoreValueUtils.stringOrNull(map['code']),
      startedAt: FirestoreValueUtils.dateTimeOr(map['startedAt']),
    );
  }

  /// The Firestore payload for this pointer.
  Map<String, dynamic> toFirestore() => {
        'sessionId': sessionId,
        if (code != null) 'code': code,
        'startedAt': Timestamp.fromDate(startedAt),
      };
}

/// A durable focus group: a named roster of people who run focus sessions
/// together.
///
/// The group document holds only what belongs to the group as a whole — its
/// name, who owns it and whether a run is happening right now. The roster lives
/// in `groups/{id}/members` and the upcoming sessions in
/// `groups/{id}/schedule`, so neither grows the group document past what a
/// single read should carry.
@immutable
class FocusGroup {
  /// The group's document id.
  final String id;

  /// The name shown everywhere the group appears.
  final String name;

  /// Optional one-line description.
  final String? description;

  /// The user who created the group. Only they may delete it.
  final String ownerId;

  /// Who can find and join this group.
  final GroupVisibility visibility;

  /// The member cap, always inside [GroupLimits].
  final int maxMembers;

  /// Number of members, resolved at read time.
  ///
  /// Deliberately **not** a stored field: only an owner/admin may write the
  /// group document, so a joining member's own write could never keep a stored
  /// counter in step and it would silently drift. The service fills this in
  /// from a count aggregation for lists and from the live stream on the detail
  /// screen.
  final int memberCount;

  /// When the group was created.
  final DateTime createdAt;

  /// The session this group is running right now, if any.
  final GroupLiveSession? liveSession;

  /// This reader's own role in the group, when the caller knows it.
  ///
  /// Also resolved at read time rather than stored, for the same reason as
  /// [memberCount]: one group document cannot carry a different role per
  /// reader.
  final GroupRole? myRole;

  /// The invite code that currently admits people to this group, when one has
  /// been issued.
  ///
  /// Kept on the group document itself rather than looked up in
  /// `group_invites`, because that collection deliberately allows no document
  /// listing — a code could only be found by guessing it — and because deleting
  /// a group has to revoke its code in the same operation.
  final String? inviteCode;

  const FocusGroup({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.visibility = GroupVisibility.private,
    this.maxMembers = GroupLimits.maxMembersPerGroup,
    this.memberCount = 0,
    required this.createdAt,
    this.liveSession,
    this.myRole,
    this.inviteCode,
  });

  /// Whether a run is happening in this group right now.
  bool get hasLiveSession => liveSession != null;

  /// Seats still free, clamped at zero so a group that somehow ended up over
  /// its cap reports "no room" instead of a negative count.
  int get remainingSlots => (maxMembers - memberCount).clamp(0, maxMembers);

  /// Whether the cap has been reached.
  bool get isFull => memberCount >= maxMembers;

  /// Whether this group is listed in the directory.
  bool get isListed => visibility.isListed;

  /// Whether the signed-in user may edit the group and its schedule.
  bool get canManage => myRole?.canManage ?? false;

  /// Whether the signed-in user owns the group.
  bool get isOwnedByMe => myRole?.isOwner ?? false;

  /// Whether [userId] owns the group, without needing [myRole] resolved.
  bool isOwnedBy(String userId) => ownerId == userId;

  /// Reads a group document.
  ///
  /// [id] is the document id, which Firestore omits from the data map.
  factory FocusGroup.fromFirestore(
    Map<String, dynamic> data, {
    required String id,
    int memberCount = 0,
    GroupRole? myRole,
  }) {
    return FocusGroup(
      id: id,
      name: FirestoreValueUtils.stringOrNull(data['name']) ?? 'Group',
      description: FirestoreValueUtils.stringOrNull(data['description']),
      ownerId: FirestoreValueUtils.stringOrNull(data['ownerId']) ?? '',
      visibility: GroupVisibility.parse(data['visibility']),
      maxMembers: GroupLimits.normalizeMaxMembers(
        FirestoreValueUtils.intOrNull(data['maxMembers']),
      ),
      memberCount: memberCount,
      createdAt: FirestoreValueUtils.dateTimeOr(data['createdAt']),
      liveSession: GroupLiveSession.fromFirestore(data['liveSession']),
      myRole: myRole,
      inviteCode: FirestoreValueUtils.stringOrNull(data['inviteCode']),
    );
  }

  /// Reads a group straight from a snapshot.
  factory FocusGroup.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot, {
    int memberCount = 0,
    GroupRole? myRole,
  }) =>
      FocusGroup.fromFirestore(
        snapshot.data() ?? const {},
        id: snapshot.id,
        memberCount: memberCount,
        myRole: myRole,
      );

  /// The group document payload.
  ///
  /// `memberCount` and `myRole` are intentionally absent: they are resolved per
  /// reader and are never written back.
  Map<String, dynamic> toFirestore() => {
        'name': name,
        if (description != null) 'description': description,
        'ownerId': ownerId,
        'visibility': visibility.wireName,
        'maxMembers': maxMembers,
        'createdAt': Timestamp.fromDate(createdAt),
        if (inviteCode != null) 'inviteCode': inviteCode,
      };

  /// The directory entry for a listed group.
  ///
  /// Holds only what the directory list renders, so browsing costs one small
  /// read per group rather than a full group document plus a member count.
  Map<String, dynamic> toDirectoryEntry() => {
        'name': name,
        if (description != null) 'description': description,
        'ownerId': ownerId,
        'maxMembers': maxMembers,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  FocusGroup copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    GroupVisibility? visibility,
    int? maxMembers,
    int? memberCount,
    DateTime? createdAt,
    GroupRole? myRole,
    String? inviteCode,
    bool clearDescription = false,
    bool clearInviteCode = false,
  }) {
    return FocusGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      description: clearDescription ? null : (description ?? this.description),
      ownerId: ownerId ?? this.ownerId,
      visibility: visibility ?? this.visibility,
      maxMembers: GroupLimits.normalizeMaxMembers(maxMembers ?? this.maxMembers),
      memberCount: memberCount ?? this.memberCount,
      createdAt: createdAt ?? this.createdAt,
      liveSession: liveSession,
      myRole: myRole ?? this.myRole,
      inviteCode: clearInviteCode ? null : (inviteCode ?? this.inviteCode),
    );
  }

  /// A copy carrying a different live-session pointer.
  FocusGroup withLiveSession(GroupLiveSession? session) => FocusGroup(
        id: id,
        name: name,
        description: description,
        ownerId: ownerId,
        visibility: visibility,
        maxMembers: maxMembers,
        memberCount: memberCount,
        createdAt: createdAt,
        liveSession: session,
        myRole: myRole,
        inviteCode: inviteCode,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FocusGroup &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          memberCount == other.memberCount &&
          liveSession?.sessionId == other.liveSession?.sessionId;

  @override
  int get hashCode =>
      id.hashCode ^ name.hashCode ^ memberCount.hashCode;

  @override
  String toString() =>
      'FocusGroup(id: $id, name: $name, members: $memberCount, '
      'visibility: ${visibility.wireName})';
}
