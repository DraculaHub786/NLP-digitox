// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/foundation.dart';

/// Represents a member in a shared session
@immutable
class SessionMember {
  /// User ID of the member
  final String userId;

  /// Device ID (for multi-device support)
  final String? deviceId;

  /// Display name of the member
  final String displayName;

  /// When the member joined the session
  final DateTime joinedAt;

  /// Whether the member is currently active
  final bool isActive;

  /// Last activity timestamp
  final DateTime lastActive;

  const SessionMember({
    required this.userId,
    this.deviceId,
    required this.displayName,
    required this.joinedAt,
    required this.isActive,
    required this.lastActive,
  });

  /// Parse from Firebase RTDB map (the nested map under a userId key)
  /// The [userId] is the key from the parent map, since RTDB omits it from value.
  factory SessionMember.fromMap(Map<String, dynamic> map, {String? userId}) {
    final resolvedUserId = userId ?? map['userId'] as String? ?? '';
    return SessionMember(
      userId: resolvedUserId,
      deviceId: map['deviceId'] as String?,
      displayName: map['displayName'] as String? ?? 'Unknown',
      joinedAt: _parseDateTime(map['joinedAt']),
      isActive: map['isActive'] as bool? ?? false,
      lastActive: _parseDateTime(map['lastActive']),
    );
  }

  /// Robust date parser: handles ISO strings, int timestamps, and null
  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  /// Serialize for Firebase RTDB — stored under sessions/{id}/members/{userId}
  /// We store userId inside the value too for easy reconstruction when fetched as a list.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'deviceId': deviceId,
      'displayName': displayName,
      // Store as ISO string for readability; lastActive can use server timestamp on update
      'joinedAt': joinedAt.toIso8601String(),
      'isActive': isActive,
      'lastActive': lastActive.toIso8601String(),
    };
  }

  SessionMember copyWith({
    String? userId,
    String? deviceId,
    String? displayName,
    DateTime? joinedAt,
    bool? isActive,
    DateTime? lastActive,
  }) {
    return SessionMember(
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      displayName: displayName ?? this.displayName,
      joinedAt: joinedAt ?? this.joinedAt,
      isActive: isActive ?? this.isActive,
      lastActive: lastActive ?? this.lastActive,
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
      'SessionMember(userId: $userId, displayName: $displayName, isActive: $isActive)';
}

/// Represents a shared focus/wellness session/group
@immutable
class SharedSession {
  /// Unique identifier for the session
  final String id;

  /// Display name of the session
  final String name;

  /// Description of the session's purpose
  final String? description;

  /// User ID of the session owner
  final String ownerId;

  /// Maximum members allowed (0 = unlimited)
  final int maxMembers;

  /// Current members in the session
  final List<SessionMember> members;

  /// Session visibility (public/private)
  final bool isPublic;

  /// When the session was created
  final DateTime createdAt;

  /// Optional goal or theme for the session
  final String? theme;

  /// Whether the session is currently active
  final bool isActive;

  /// Session-wide restriction settings (optional)
  final SessionSettings? settings;

  const SharedSession({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.maxMembers = 0,
    this.members = const [],
    this.isPublic = false,
    required this.createdAt,
    this.theme,
    this.isActive = true,
    this.settings,
  });

  /// Member count
  int get memberCount => members.length;

  /// Active member count
  int get activeMembers => members.where((m) => m.isActive).length;

  /// Parse from Firebase RTDB snapshot value.
  ///
  /// Firebase RTDB stores members as a nested Map:
  ///   { "userId1": { displayName: ..., isActive: ... }, "userId2": { ... } }
  /// NOT as a list. This factory handles both the old list format (migration
  /// safety) and the correct nested-map format.
  factory SharedSession.fromMap(Map<String, dynamic> map) {
    final members = _parseMembers(map['members']);

    return SharedSession(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Session',
      description: map['description'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      maxMembers: map['maxMembers'] as int? ?? 0,
      members: members,
      isPublic: map['isPublic'] as bool? ?? false,
      createdAt: SessionMember._parseDateTime(map['createdAt']),
      theme: map['theme'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      settings: map['settings'] != null
          ? SessionSettings.fromMap(
              Map<String, dynamic>.from(map['settings'] as Map))
          : null,
    );
  }

  /// Robustly parses the members field from RTDB.
  /// Handles:
  ///  - null / missing → []
  ///  - Map<String, dynamic> (correct RTDB format) → parse each entry
  ///  - List (legacy local format) → parse each entry
  static List<SessionMember> _parseMembers(dynamic rawMembers) {
    if (rawMembers == null) return [];

    if (rawMembers is Map) {
      // Firebase RTDB nested map: { userId: { ...memberData } }
      final result = <SessionMember>[];
      for (final entry in rawMembers.entries) {
        try {
          final memberData = Map<String, dynamic>.from(entry.value as Map);
          result.add(SessionMember.fromMap(memberData, userId: entry.key as String));
        } catch (e) {
          debugPrint('SharedSession: Error parsing member ${entry.key}: $e');
        }
      }
      return result;
    }

    if (rawMembers is List) {
      // Legacy list format (in-memory only, can be removed after migration)
      final result = <SessionMember>[];
      for (final item in rawMembers) {
        try {
          result.add(SessionMember.fromMap(Map<String, dynamic>.from(item as Map)));
        } catch (e) {
          debugPrint('SharedSession: Error parsing member from list: $e');
        }
      }
      return result;
    }

    debugPrint('SharedSession: Unknown members format: ${rawMembers.runtimeType}');
    return [];
  }

  /// Serialize for Firebase RTDB.
  /// Members are stored as a nested map: { userId: { ...data } }
  Map<String, dynamic> toMap() {
    // Build the nested members map keyed by userId
    final membersMap = <String, dynamic>{};
    for (final m in members) {
      membersMap[m.userId] = m.toMap();
    }

    return {
      'id': id,
      'name': name,
      'description': description,
      'ownerId': ownerId,
      'maxMembers': maxMembers,
      'members': membersMap,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'theme': theme,
      'isActive': isActive,
      'settings': settings?.toMap(),
    };
  }

  SharedSession copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    int? maxMembers,
    List<SessionMember>? members,
    bool? isPublic,
    DateTime? createdAt,
    String? theme,
    bool? isActive,
    SessionSettings? settings,
  }) {
    return SharedSession(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      maxMembers: maxMembers ?? this.maxMembers,
      members: members ?? this.members,
      isPublic: isPublic ?? this.isPublic,
      createdAt: createdAt ?? this.createdAt,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      settings: settings ?? this.settings,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SharedSession &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ownerId == other.ownerId &&
          memberCount == other.memberCount;

  @override
  int get hashCode => id.hashCode ^ ownerId.hashCode ^ memberCount.hashCode;

  @override
  String toString() =>
      'SharedSession(id: $id, name: $name, members: $memberCount)';
}

/// Settings for a shared session
@immutable
class SessionSettings {
  /// Shared daily app usage limit (in minutes)
  final int? sharedDailyLimit;

  /// Enforced focus apps for all members
  final List<String>? focusApps;

  /// Blocked apps for all members
  final List<String>? blockedApps;

  /// Whether members can see each other's activity
  final bool showMemberActivity;

  /// Whether to enforce sync behavior across members
  final bool enforceSync;

  const SessionSettings({
    this.sharedDailyLimit,
    this.focusApps,
    this.blockedApps,
    this.showMemberActivity = true,
    this.enforceSync = false,
  });

  factory SessionSettings.fromMap(Map<String, dynamic> map) {
    return SessionSettings(
      sharedDailyLimit: map['sharedDailyLimit'] as int?,
      focusApps: (map['focusApps'] as List?)?.cast<String>(),
      blockedApps: (map['blockedApps'] as List?)?.cast<String>(),
      showMemberActivity: map['showMemberActivity'] as bool? ?? true,
      enforceSync: map['enforceSync'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sharedDailyLimit': sharedDailyLimit,
      'focusApps': focusApps,
      'blockedApps': blockedApps,
      'showMemberActivity': showMemberActivity,
      'enforceSync': enforceSync,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionSettings &&
          runtimeType == other.runtimeType &&
          sharedDailyLimit == other.sharedDailyLimit &&
          showMemberActivity == other.showMemberActivity &&
          enforceSync == other.enforceSync;

  @override
  int get hashCode =>
      sharedDailyLimit.hashCode ^
      showMemberActivity.hashCode ^
      enforceSync.hashCode;
}
