import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/core/enums/session_phase.dart';
import 'package:nlp_digitox/models/session_member.dart';

// `SessionMember` and its enums now live in `session_member.dart`. They are
// re-exported here so every existing `import 'shared_session_model.dart'`
// keeps compiling unchanged.
export 'package:nlp_digitox/models/session_member.dart';

/// Who can find and join a session.
///
/// Replaces the old bare `isPublic` boolean at the protocol level. `invite` is
/// the default because a link that can be forwarded is still a private room —
/// it is not listed anywhere — whereas `public` puts the session in Discover for
/// every signed-in user.
enum SessionVisibility {
  /// Joinable only by someone who was handed the session ID directly.
  private,

  /// Joinable with the invite code/link; never listed.
  invite,

  /// Listed in Discover, joinable by anyone.
  public;

  String get wireName => name;

  /// Whether the session is discoverable by strangers.
  bool get isListed => this == SessionVisibility.public;

  /// Whether joining requires a code that was handed out.
  bool get requiresCode => this != SessionVisibility.public;

  static SessionVisibility parse(dynamic raw) {
    if (raw is String) {
      for (final value in SessionVisibility.values) {
        if (value.name == raw) return value;
      }
    }
    // Anything unrecognised — including a session written before `visibility`
    // existed — is treated as invite-only rather than public. Failing closed
    // matters here: reading "unknown" as `public` would expose a private room.
    return SessionVisibility.invite;
  }

  String get label {
    switch (this) {
      case SessionVisibility.private:
        return 'Private';
      case SessionVisibility.invite:
        return 'Invite only';
      case SessionVisibility.public:
        return 'Public';
    }
  }
}

/// The stored lifecycle state of a session.
///
/// Deliberately only three values: `finished` is not stored, it is *derived*
/// from `runStartAt + countdownSec + durationSec` against the server clock, so
/// every device agrees without anyone writing a second timestamp.
enum SharedSessionState {
  lobby,
  running,
  cancelled;

  String get wireName => name;

  static SharedSessionState parse(dynamic raw) {
    if (raw is String) {
      for (final value in SharedSessionState.values) {
        if (value.name == raw) return value;
      }
    }
    return SharedSessionState.lobby;
  }
}

/// Settings for a shared session.
@immutable
class SessionSettings {
  /// Shared daily app usage limit (in minutes).
  final int? sharedDailyLimit;

  /// Enforced focus apps for all members.
  final List<String>? focusApps;

  /// Blocked apps for all members.
  final List<String>? blockedApps;

  /// Whether members can see each other's activity.
  final bool showMemberActivity;

  /// Whether to enforce sync behavior across members.
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
      sharedDailyLimit:
          SessionMember.parseInt(map['sharedDailyLimit']),
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

/// Represents a shared focus/wellness session.
///
/// A session is a *room* first and a *timer* second: members gather in the
/// lobby, mark themselves ready, and then the host starts one synchronised run.
/// The run is defined by `runStartAt` (a server timestamp) plus `durationSec`,
/// so no clock ticks are ever streamed — see [phaseAt].
@immutable
class SharedSession {
  /// Unique identifier for the session.
  final String id;

  /// Display name of the session.
  final String name;

  /// Description of the session's purpose.
  final String? description;

  /// User ID of the session owner.
  final String ownerId;

  /// Maximum members allowed in this session, the owner included.
  ///
  /// Always inside `[1, SessionLimits.maxMembersPerSession]`. This is the
  /// plan's `capacity`; the name is kept because the cap is already enforced in
  /// three layers under it.
  final int maxMembers;

  /// Current members in the session.
  final List<SessionMember> members;

  /// Who can find and join this session.
  final SessionVisibility visibility;

  /// When the session was created.
  final DateTime createdAt;

  /// Optional goal or theme for the session.
  final String? theme;

  /// Whether the session is still open (not completed and not cancelled).
  final bool isActive;

  /// When the owner completed the session (null while it is still running).
  final DateTime? completedAt;

  /// Session-wide restriction settings (optional).
  final SessionSettings? settings;

  /// Wire value of the focus category — see `sessionTypeFromWire`.
  ///
  /// Held as a `String` rather than a `SessionType` so this model has no
  /// dependency on the Material-importing enums file; the UI converts it.
  final String type;

  /// How long the synchronised run lasts, in seconds. Immutable once running.
  final int durationSec;

  /// The shared countdown shown before the run starts, in seconds.
  final int countdownSec;

  /// Stored lifecycle state.
  final SharedSessionState state;

  /// The server timestamp written when the host started the run.
  ///
  /// Null until then. This single value is what synchronises every device.
  final DateTime? runStartAt;

  /// The group this session was started from, when it came from one.
  final String? groupId;

  /// The invite code that names this session, when it has one.
  final String? inviteCode;

  const SharedSession({
    required this.id,
    required this.name,
    this.description,
    required this.ownerId,
    this.maxMembers = SessionLimits.maxMembersPerSession,
    this.members = const [],
    SessionVisibility? visibility,
    bool isPublic = false,
    required this.createdAt,
    this.theme,
    this.isActive = true,
    this.completedAt,
    this.settings,
    this.type = 'study',
    this.durationSec = SessionLimits.defaultDurationSec,
    this.countdownSec = SessionLimits.defaultCountdownSec,
    this.state = SharedSessionState.lobby,
    this.runStartAt,
    this.groupId,
    this.inviteCode,
  }) : visibility = visibility ??
            (isPublic ? SessionVisibility.public : SessionVisibility.invite);

  /// Member count.
  int get memberCount => members.length;

  /// Active member count.
  int get activeMembers => members.where((m) => m.isActive).length;

  /// Members who have not left the room.
  List<SessionMember> get presentMembers =>
      members.where((m) => m.isPresent).toList();

  /// Members who marked themselves ready before the host started.
  int get readyCount => presentMembers.where((m) => m.isReady).length;

  /// How many members finished the run.
  int get completedCount => members.where((m) => m.hasCompleted).length;

  /// Seats still free. Clamped at zero so a session that somehow ended up over
  /// its cap reports "no room" instead of a negative count.
  int get remainingSlots => (maxMembers - memberCount).clamp(0, maxMembers);

  /// Whether the cap has been reached, so nobody else may join.
  bool get isFull => memberCount >= maxMembers;

  /// Whether the session is discoverable in Discover.
  bool get isPublic => visibility == SessionVisibility.public;

  /// A finished session: the owner marked it complete, so it no longer accepts
  /// presence heartbeats.
  bool get isCompleted => completedAt != null;

  /// Whether the host cancelled the run.
  bool get isCancelled => state == SharedSessionState.cancelled;

  /// Whether the lobby is still open to new members.
  ///
  /// Only the lobby accepts joins — someone arriving mid-run would join a timer
  /// they cannot align with, which is why the plan excludes it from v1. The
  /// security rules enforce the same condition server-side.
  bool get isLobby =>
      state == SharedSessionState.lobby && !isCompleted && isActive;

  /// The instant the shared timer starts: `runStartAt` plus the countdown.
  ///
  /// Null while the session is still in its lobby.
  DateTime? get startEffective {
    final start = runStartAt;
    if (start == null) return null;
    return start.add(Duration(seconds: countdownSec));
  }

  /// The instant the shared run ends.
  ///
  /// Null while the session is still in its lobby, or when it is open-ended
  /// (`durationSec == 0`).
  DateTime? get endAt {
    final start = startEffective;
    if (start == null || durationSec <= 0) return null;
    return start.add(Duration(seconds: durationSec));
  }

  /// Milliseconds since the epoch at which the run starts, or null in the
  /// lobby.
  int? get startEffectiveMs => startEffective?.millisecondsSinceEpoch;

  /// Milliseconds since the epoch at which the run ends, or null.
  int? get endAtMs => endAt?.millisecondsSinceEpoch;

  /// The total span of the run including its countdown, in milliseconds.
  int get totalSpanMs => (countdownSec + durationSec) * Duration.millisecondsPerSecond;

  /// Whether [userId] should be paid the completion bonus for this session.
  ///
  /// Two conditions must both hold:
  ///   * the session was actually *completed* — a session also goes inactive
  ///     when its owner merely leaves, and that must not pay out, and
  ///   * the user is still a member, so someone who left before completion
  ///     gets nothing.
  bool isEligibleForCompletionPayout(String userId) =>
      isCompleted && members.any((m) => m.userId == userId);

  /// The config a group focus run should apply, never null.
  ///
  /// A session can legitimately have no stored settings — it was created by a
  /// client that omitted them, or it predates shared settings entirely. Group
  /// focus must still work then: each member simply keeps their own focus
  /// duration and blocklist, which is what an empty [SessionSettings] means to
  /// the focus engine.
  SessionSettings get groupFocusSettings => settings ?? const SessionSettings();

  /// Whether the group-focus action should be offered for this session.
  ///
  /// Deliberately independent of [settings]: the capability belongs to *any*
  /// active, unfinished session.
  bool get canStartGroupFocus => isActive && !isCompleted;

  /// The member record for [userId], or null if they are not in the room.
  SessionMember? memberFor(String userId) {
    for (final member in members) {
      if (member.userId == userId) return member;
    }
    return null;
  }

  /// Whether [userId] owns this session.
  bool isOwnedBy(String userId) => ownerId == userId;

  /// Derives the live phase from the stored state and the **server** clock.
  ///
  /// [serverNowMs] must come from `SessionClock`, never from
  /// `DateTime.now()`: two phones whose clocks differ by minutes would
  /// otherwise disagree about when the run started and end at different times,
  /// which is the single failure the whole design exists to prevent.
  SessionPhase phaseAt(int serverNowMs) {
    if (isCancelled) return SessionPhase.cancelled;
    // A session the owner finished by hand is over even if it never ran.
    if (isCompleted) return SessionPhase.finished;

    final startMs = startEffectiveMs;
    if (startMs == null) return SessionPhase.lobby;
    if (serverNowMs < startMs) return SessionPhase.countdown;

    final endMs = endAtMs;
    if (endMs != null && serverNowMs >= endMs) return SessionPhase.finished;
    return SessionPhase.running;
  }

  /// Seconds left in the countdown, or null when not counting down.
  int? countdownRemainingSecAt(int serverNowMs) {
    final startMs = startEffectiveMs;
    if (startMs == null || serverNowMs >= startMs) return null;
    return ((startMs - serverNowMs) / Duration.millisecondsPerSecond).ceil();
  }

  /// Seconds left in the run, floored at zero. Null outside a running phase.
  int? remainingSecAt(int serverNowMs) {
    final endMs = endAtMs;
    if (endMs == null) return null;
    final remainingMs = endMs - serverNowMs;
    if (remainingMs <= 0) return 0;
    return (remainingMs / Duration.millisecondsPerSecond).ceil();
  }

  /// How far through the run [serverNowMs] is, from 0.0 to 1.0.
  double progressAt(int serverNowMs) {
    final startMs = startEffectiveMs;
    final span = endAtMs != null && startMs != null ? endAtMs! - startMs : 0;
    if (span <= 0) return isCompleted ? 1 : 0;
    return ((serverNowMs - startMs!) / span).clamp(0.0, 1.0);
  }
/// Parse from a Firebase RTDB snapshot value.
  ///
  /// Firebase RTDB stores members as a nested Map:
  ///   { "userId1": { displayName: ..., isActive: ... }, "userId2": { ... } }
  /// NOT as a list. This factory handles both the old list format (migration
  /// safety) and the correct nested-map format.
  factory SharedSession.fromMap(Map<String, dynamic> raw) {
    // Callers pass the snapshot value straight through, which RTDB types as
    // `Object?`. Copying it once here means every field read below is typed and
    // a surprise shape fails loudly instead of half-populating the session.
    final map = Map<String, dynamic>.from(raw);

    return SharedSession(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? 'Session',
      description: map['description'] as String?,
      ownerId: map['ownerId'] as String? ?? '',
      maxMembers:
          SessionLimits.normalizeMaxMembers(SessionMember.parseInt(map['maxMembers'])),
      members: _parseMembers(map['members']),
      visibility: _parseVisibility(map),
      createdAt: SessionMember.parseDateTime(map['createdAt']),
      theme: map['theme'] as String?,
      isActive: map['isActive'] as bool? ?? true,
      completedAt: map['completedAt'] != null
          ? SessionMember.parseDateTime(map['completedAt'])
          : null,
      settings: map['settings'] is Map
          ? SessionSettings.fromMap(
              Map<String, dynamic>.from(map['settings'] as Map))
          : null,
      type: map['type'] as String? ?? 'study',
      durationSec: _parseDuration(map['durationSec']),
      countdownSec: _parseCountdown(map['countdownSec']),
      state: SharedSessionState.parse(map['state']),
      runStartAt: map['runStartAt'] != null
          ? SessionMember.parseDateTime(map['runStartAt'])
          : null,
      groupId: map['groupId'] as String?,
      inviteCode: map['inviteCode'] as String?,
    );
  }

  /// Reads visibility, falling back to the older `isPublic` boolean.
  ///
  /// A session created before `visibility` existed carries only `isPublic`, and
  /// reading it as "invite" rather than "public" would quietly de-list every
  /// existing public room — so the legacy flag is still honoured.
  static SessionVisibility _parseVisibility(Map<String, dynamic> map) {
    final raw = map['visibility'];
    if (raw is String) return SessionVisibility.parse(raw);
    return (map['isPublic'] as bool? ?? false)
        ? SessionVisibility.public
        : SessionVisibility.invite;
  }

  /// Clamps a stored duration into the supported range.
  ///
  /// The same bounds live in `database.rules.json`; a value outside them can
  /// only come from an edited client or a hand-written node, and a 30-hour run
  /// would leave members with apps blocked long after they stopped.
  static int _parseDuration(dynamic value) {
    final parsed = SessionMember.parseInt(value);
    if (parsed == null) return SessionLimits.defaultDurationSec;
    if (parsed < SessionLimits.minDurationSec) return SessionLimits.minDurationSec;
    if (parsed > SessionLimits.maxDurationSec) return SessionLimits.maxDurationSec;
    return parsed;
  }

  /// Countdown length, clamped so a run can never start instantly or stall.
  static int _parseCountdown(dynamic value) {
    final parsed = SessionMember.parseInt(value);
    if (parsed == null) return SessionLimits.defaultCountdownSec;
    return parsed.clamp(SessionLimits.minCountdownSec, SessionLimits.maxCountdownSec);
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
          result.add(
            SessionMember.fromMap(memberData, userId: entry.key as String),
          );
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
      // Both spellings are written: `visibility` is what the rules and this
      // client read, and `isPublic` is kept so a client still on the previous
      // build reads the same room the same way instead of de-listing it.
      'visibility': visibility.wireName,
      'isPublic': isPublic,
      'createdAt': createdAt.toIso8601String(),
      'theme': theme,
      'isActive': isActive,
      // Omitted entirely while the session is running — sending an explicit
      // null through `set()` would delete/create the key spuriously.
      if (completedAt != null) 'completedAt': completedAt!.toIso8601String(),
      'settings': settings?.toMap(),
      'type': type,
      'durationSec': durationSec,
      'countdownSec': countdownSec,
      'state': state.wireName,
      if (runStartAt != null) 'runStartAt': runStartAt!.toIso8601String(),
      if (groupId != null) 'groupId': groupId,
      if (inviteCode != null) 'inviteCode': inviteCode,
    };
  }

  SharedSession copyWith({
    String? id,
    String? name,
    String? description,
    String? ownerId,
    int? maxMembers,
    List<SessionMember>? members,
    SessionVisibility? visibility,
    bool? isPublic,
    DateTime? createdAt,
    String? theme,
    bool? isActive,
    DateTime? completedAt,
    SessionSettings? settings,
    String? type,
    int? durationSec,
    int? countdownSec,
    SharedSessionState? state,
    DateTime? runStartAt,
    String? groupId,
    String? inviteCode,
    bool clearRunStartAt = false,
  }) {
    return SharedSession(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      maxMembers:
          SessionLimits.normalizeMaxMembers(maxMembers ?? this.maxMembers),
      members: members ?? this.members,
      // An explicit `visibility` wins; otherwise an explicit `isPublic` flips
      // between public and invite-only, and neither leaves it unchanged.
      visibility: visibility ??
          (isPublic == null
              ? this.visibility
              : (isPublic ? SessionVisibility.public : SessionVisibility.invite)),
      createdAt: createdAt ?? this.createdAt,
      theme: theme ?? this.theme,
      isActive: isActive ?? this.isActive,
      completedAt: completedAt ?? this.completedAt,
      settings: settings ?? this.settings,
      type: type ?? this.type,
      durationSec: durationSec ?? this.durationSec,
      countdownSec: countdownSec ?? this.countdownSec,
      state: state ?? this.state,
      runStartAt: clearRunStartAt ? null : (runStartAt ?? this.runStartAt),
      groupId: groupId ?? this.groupId,
      inviteCode: inviteCode ?? this.inviteCode,
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
      'SharedSession(id: $id, name: $name, members: $memberCount, '
      'state: ${state.wireName})';
}
