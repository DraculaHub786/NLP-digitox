// Copyright (c) 2026 NLP digitox

import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/models/session_member.dart';

/// A verified outcome for one member of one shared session.
///
/// Stored at `sessionResults/{sid}/{uid}` and written **only** by the
/// completion webhook through a service account — `database.rules.json` sets
/// `.write: false` on the whole node, so no client can fabricate one. This is a
/// read model: the app renders points and credit from it, never derives them.
@immutable
class SessionResult {
  /// The session this result belongs to.
  final String sessionId;

  /// The member the result is about.
  final String userId;

  /// Display name at the time of completion, so a summary can be rendered
  /// without a second lookup that may have since gone.
  final String? displayName;

  /// Verified seconds actually focused.
  final int focusedSec;

  /// Whether the run met the completion criteria (ran to `endAt`, stayed
  /// present, within the break allowance).
  final bool completed;

  /// Points credited for this result, as decided by the server.
  final int points;

  /// How many times the member broke focus during the run.
  final int breaks;

  /// When the webhook wrote the result.
  final DateTime at;

  const SessionResult({
    required this.sessionId,
    required this.userId,
    this.displayName,
    this.focusedSec = 0,
    this.completed = false,
    this.points = 0,
    this.breaks = 0,
    required this.at,
  });

  /// Parse from the Realtime Database value at `sessionResults/{sid}/{uid}`.
  factory SessionResult.fromMap(
    Map<String, dynamic> map, {
    required String sessionId,
    required String userId,
  }) {
    return SessionResult(
      sessionId: sessionId,
      userId: userId,
      displayName: map['displayName'] as String?,
      focusedSec: SessionMember.parseInt(map['focusedSec']) ?? 0,
      completed: map['completed'] as bool? ?? false,
      points: SessionMember.parseInt(map['points']) ?? 0,
      breaks: SessionMember.parseInt(map['breaks']) ?? 0,
      at: map['at'] != null
          ? SessionMember.parseDateTime(map['at'])
          : DateTime.now(),
    );
  }

  /// Parses the whole `sessionResults/{sid}` node into a list.
  static List<SessionResult> listFromSnapshot(
    dynamic raw, {
    required String sessionId,
  }) {
    if (raw is! Map) return const [];
    final results = <SessionResult>[];
    for (final entry in raw.entries) {
      final value = entry.value;
      if (value is! Map) continue;
      try {
        results.add(
          SessionResult.fromMap(
            Map<String, dynamic>.from(value),
            sessionId: sessionId,
            userId: entry.key as String,
          ),
        );
      } catch (e) {
        debugPrint('SessionResult: could not parse ${entry.key}: $e');
      }
    }
    return results;
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'focusedSec': focusedSec,
      'completed': completed,
      'points': points,
      'breaks': breaks,
      'at': at.toIso8601String(),
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SessionResult &&
          runtimeType == other.runtimeType &&
          sessionId == other.sessionId &&
          userId == other.userId &&
          points == other.points &&
          completed == other.completed;

  @override
  int get hashCode =>
      sessionId.hashCode ^
      userId.hashCode ^
      points.hashCode ^
      completed.hashCode;

  @override
  String toString() =>
      'SessionResult($sessionId/$userId completed: $completed, '
      'focused: ${focusedSec}s, points: $points)';
}
