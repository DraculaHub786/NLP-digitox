// Copyright (c) 2026 NLP digitox

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';

/// A member's authority inside a group.
///
/// Three levels rather than two, because a group is durable: the person who
/// created it will not always be the person maintaining it, and handing out
/// `admin` is the only way to let someone else run a scheduled session without
/// also letting them delete the group.
enum GroupRole {
  /// Created the group. Only the owner may delete it or change roles.
  owner,

  /// May edit the group, invite, manage the schedule and remove members.
  admin,

  /// May read the group, see the schedule and start/join its sessions.
  member;

  /// Wire value stored in Firestore.
  ///
  /// Spelled out rather than relying on `name` so a future rename of the Dart
  /// enum cannot silently invalidate every stored membership document.
  String get wireName {
    switch (this) {
      case GroupRole.owner:
        return 'owner';
      case GroupRole.admin:
        return 'admin';
      case GroupRole.member:
        return 'member';
    }
  }

  /// Whether this role may edit the group, invite and manage the schedule.
  bool get canManage => this == GroupRole.owner || this == GroupRole.admin;

  /// Whether this role may delete the group or change other members' roles.
  bool get isOwner => this == GroupRole.owner;

  /// The label shown on a member row.
  String get label {
    switch (this) {
      case GroupRole.owner:
        return 'Owner';
      case GroupRole.admin:
        return 'Admin';
      case GroupRole.member:
        return 'Member';
    }
  }

  /// Parses a stored role, tolerating anything unrecognised.
  ///
  /// Falls back to [GroupRole.member] — the least privileged role — rather than
  /// throwing or defaulting to admin: an unknown value means a newer client
  /// wrote it, and guessing upwards would grant authority nobody granted.
  static GroupRole parse(dynamic raw) {
    if (raw is String) {
      for (final role in GroupRole.values) {
        if (role.wireName == raw) return role;
      }
    }
    return GroupRole.member;
  }
}

/// One person's membership in a group.
///
/// Stored as its own document under `groups/{gid}/members/{uid}` rather than as
/// a map field on the group, for two reasons: the security rules can test
/// membership with `exists()` instead of fetching and parsing the parent
/// document on every access, and a member cannot add or promote anyone by
/// rewriting the group document itself.
@immutable
class GroupMember {
  /// The member's user id — also the document id inside `members/`.
  final String userId;

  /// Display name at the moment they joined.
  ///
  /// Denormalised on purpose: the roster renders from this subcollection alone,
  /// so drawing a group of 25 people costs one listener, not 25 profile reads.
  final String displayName;

  /// Profile picture URL at the moment they joined, when they had one.
  final String? photoUrl;

  /// This member's authority in the group.
  final GroupRole role;

  /// When they joined.
  final DateTime joinedAt;

  /// When their profile details here were last refreshed.
  final DateTime? updatedAt;

  const GroupMember({
    required this.userId,
    required this.displayName,
    this.photoUrl,
    this.role = GroupRole.member,
    required this.joinedAt,
    this.updatedAt,
  });

  /// Whether this member may edit the group and its schedule.
  bool get canManage => role.canManage;

  /// Whether this member owns the group.
  bool get isOwner => role.isOwner;

  /// The single character shown in the fallback avatar.
  String get initial =>
      displayName.trim().isEmpty ? '?' : displayName.trim()[0].toUpperCase();

  /// Reads a membership document.
  ///
  /// [userId] is the document id, which Firestore omits from the data map, so
  /// it must be supplied by the caller.
  factory GroupMember.fromFirestore(
    Map<String, dynamic> data, {
    required String userId,
  }) {
    return GroupMember(
      userId: userId,
      displayName:
          FirestoreValueUtils.stringOrNull(data['displayName']) ?? 'Member',
      photoUrl: FirestoreValueUtils.stringOrNull(data['photoUrl']),
      role: GroupRole.parse(data['role']),
      joinedAt: FirestoreValueUtils.dateTimeOr(data['joinedAt']),
      updatedAt: FirestoreValueUtils.dateTimeOrNull(data['updatedAt']),
    );
  }

  /// Reads a membership document straight from a snapshot.
  factory GroupMember.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) =>
      GroupMember.fromFirestore(
        snapshot.data() ?? const {},
        userId: snapshot.id,
      );

  /// The Firestore payload for this membership.
  ///
  /// `userId` is written even though it duplicates the document id: a membership
  /// document that is read on its own — or exported for moderation — should say
  /// who it belongs to without the reader having to know its path.
  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        'displayName': displayName,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'role': role.wireName,
        'joinedAt': Timestamp.fromDate(joinedAt),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  GroupMember copyWith({
    String? userId,
    String? displayName,
    String? photoUrl,
    GroupRole? role,
    DateTime? joinedAt,
    DateTime? updatedAt,
    bool clearPhotoUrl = false,
  }) {
    return GroupMember(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      role: role ?? this.role,
      joinedAt: joinedAt ?? this.joinedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          role == other.role &&
          displayName == other.displayName;

  @override
  int get hashCode => userId.hashCode ^ role.hashCode ^ displayName.hashCode;

  @override
  String toString() =>
      'GroupMember(userId: $userId, role: ${role.wireName}, '
      'displayName: $displayName)';
}
