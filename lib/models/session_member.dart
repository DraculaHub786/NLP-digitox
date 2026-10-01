// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';

/// Where a member is in the session lifecycle.
///
/// A session is a *lobby* until the host starts it, so there are two distinct
/// "I am here" states before the timer runs: [joined] (in the room, not ready)
/// and [ready] (in the room, has confirmed they can focus). Both count as
/// present. Once the timer starts they are [focusing]. A member who loses their
/// connection is [away]; one who deliberately exits is [left].
enum MemberStatus {
  joined,
  ready,
  focusing,
  away,
  left;

  /// Whether the member should be shown as still in the room.
  ///
  /// [away] counts as present on purpose: the app backgrounds its whole process
  /// during a focus run, so a dropped heartbeat is the normal case, not an exit.
  /// Only [left] means the member is gone.
  bool get isPresent => this != MemberStatus.left;

  /// Whether this member has confirmed they are ready to start.
  bool get isReady =>
      this == MemberStatus.ready || this == MemberStatus.focusing;

  /// Wire value persisted in the Realtime Database.
  String get wireName => name;

  /// Parses a stored status, tolerating anything unrecognised.
  ///
  /// Falls back to [MemberStatus.joined] rather than throwing: an unknown value
  /// means a newer client wrote it, and refusing to parse would make an entire
  /// member row disappear from the UI.
  static MemberStatus parse(dynamic raw) {
    if (raw is String) {
      for (final status in MemberStatus.values) {
        if (status.name == raw) return status;
      }
    }
    return MemberStatus.joined;
  }

  /// The label shown on a member row.
  String get label {
    switch (this) {
      case MemberStatus.joined:
        return 'In lobby';
      case MemberStatus.ready:
        return 'Ready';
      case MemberStatus.focusing:
        return 'Focused';
      case MemberStatus.away:
        return 'Away';
      case MemberStatus.left:
        return 'Left';
    }
  }
}

/// A member's authority inside a session.
enum MemberRole {
  host,
  member;

  String get wireName => name;

  static MemberRole parse(dynamic raw) {
    if (raw is String) {
      for (final role in MemberRole.values) {
        if (role.name == raw) return role;
      }
    }
    return MemberRole.member;
  }
}

/// Represents a member in a shared session.
///
/// Extracted from `shared_session_model.dart` into its own file and re-exported
/// from there, so every existing import path keeps working.
@immutable
class SessionMember {
  /// User ID of the member.
  final String userId;

  /// Device ID (for multi-device support).
  final String? deviceId;

  /// Display name of the member.
  final String displayName;

  /// When the member joined the session.
  final DateTime joinedAt;

  /// Whether the member counts as active.
  ///
  /// Kept as a stored field rather than derived from [status] because it is what
  /// older sessions and every existing caller read; [status] is the richer
  /// signal and the two are written together.
  final bool isActive;

  /// Last activity timestamp — the heartbeat's `lastSeen`.
  final DateTime? lastActive;

  /// Profile picture URL, when the member has one.
  final String? photoUrl;

  /// Host or ordinary member.
  final MemberRole role;

  /// Lifecycle position of this member.
  final MemberStatus status;

  /// When the member left, if they did.
  final DateTime? leftAt;

  /// How many times this member broke focus by stopping early.
  final int breaks;

  /// When the member's device finished the run and reported completion.
  final DateTime? completedAt;

  /// The invite code this member used, validated by the security rules.
  final String? code;

  const SessionMember({
    required this.userId,
    this.deviceId,
    required this.displayName,
    required this.joinedAt,
    required this.isActive,
    this.lastActive,
    this.photoUrl,
    this.role = MemberRole.member,
    this.status = MemberStatus.joined,
    this.leftAt,
    this.breaks = 0,
    this.completedAt,
    this.code,
  });

  /// Whether this member is the session host.
  bool get isHost => role == MemberRole.host;

  /// Whether the member finished the run.
  bool get hasCompleted => completedAt != null;

  /// Whether the member is still in the room.
  bool get isPresent => leftAt == null && status.isPresent;

  /// Whether the member confirmed readiness before the host started.
  bool get isReady => status.isReady;

  /// Parse from a Realtime Database map (the nested map under a userId key).
  ///
  /// The [userId] is the key from the parent map, since RTDB omits it from the
  /// value.
  factory SessionMember.fromMap(Map<String, dynamic> map, {String? userId}) {
    final resolvedUserId = userId ?? map['userId'] as String? ?? '';
    final status = map['status'] != null
        ? MemberStatus.parse(map['status'])
        // A member written before `status` existed carries only `isActive`.
        : (map['isActive'] as bool? ?? false)
            ? MemberStatus.joined
            : MemberStatus.away;

    return SessionMember(
      userId: resolvedUserId,
      deviceId: map['deviceId'] as String?,
      displayName: map['displayName'] as String? ?? 'Unknown',
      joinedAt: parseDateTime(map['joinedAt']),
      isActive: map['isActive'] as bool? ?? status.isPresent,
      lastActive:
          map['lastActive'] != null ? parseDateTime(map['lastActive']) : null,
      photoUrl: map['photoUrl'] as String?,
      role: MemberRole.parse(map['role']),
      status: status,
      leftAt: map['leftAt'] != null ? parseDateTime(map['leftAt']) : null,
      breaks: parseInt(map['breaks']) ?? 0,
      completedAt:
          map['completedAt'] != null ? parseDateTime(map['completedAt']) : null,
      code: map['code'] as String?,
    );
  }

  /// Robust date parser: handles ISO strings, int timestamps, and null.
  static DateTime parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Parses an int from a value that may have round-tripped through JSON as a
  /// `double`, returning null for anything unusable.
  static int? parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  /// Serialize for the Realtime Database — stored under
  /// `sessions/{id}/members/{userId}`.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.wireName,
      'status': status.wireName,
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'lastActive': lastActive?.toIso8601String(),
      'leftAt': leftAt?.toIso8601String(),
      'breaks': breaks,
      'completedAt': completedAt?.toIso8601String(),
      'code': code,
    };
  }

  SessionMember copyWith({
    String? userId,
    String? deviceId,
    String? displayName,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? lastActive,
    String? photoUrl,
    MemberRole? role,
    MemberStatus? status,
    DateTime? leftAt,
    int? breaks,
    DateTime? completedAt,
    String? code,
    bool clearLeftAt = false,
    bool clearCompletedAt = false,
  }) {
    return SessionMember(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      status: status ?? this.status,
      leftAt: clearLeftAt ? null : (leftAt ?? this.leftAt),
      breaks: breaks ?? this.breaks,
      completedAt: clearCompletedAt ? null : (completedAt ?? this.completedAt),
      code: code ?? this.code,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionMember &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          deviceId == other.deviceId &&
          isActive == other.isActive;

  @override
  int get hashCode => userId.hashCode ^ deviceId.hashCode ^ isActive.hashCode;

  @override
  String toString() =>
      'SessionMember(userId: $userId, displayName: $displayName, '
      'status: ${status.wireName}, isActive: $isActive)';
}
