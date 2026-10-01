// Copyright (c) 2026 NLP digitox

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';

/// One member's accumulated record inside a group.
///
/// Stored under `groups/{gid}/stats/{uid}` and written only by the points
/// webhook through a service account — `firestore.rules` sets
/// `allow write: if false` on that subcollection, so no client can inflate its
/// own numbers. The group screen reads the signed-in user's own row to show
/// "your record here".
@immutable
class GroupStats {
  /// The member these numbers belong to.
  final String userId;

  /// How many group sessions this member has completed.
  final int sessionsCompleted;

  /// Total focused time accumulated in this group, in seconds.
  final int focusedSec;

  /// Consecutive completed sessions, reset by a miss.
  final int streak;

  /// When these numbers were last updated by the webhook.
  final DateTime? updatedAt;

  const GroupStats({
    required this.userId,
    this.sessionsCompleted = 0,
    this.focusedSec = 0,
    this.streak = 0,
    this.updatedAt,
  });

  /// An empty record for a member the webhook has not written yet.
  ///
  /// A brand-new member genuinely has no record, and rendering zeros is the
  /// truth about them — not a placeholder.
  static GroupStats empty(String userId) => GroupStats(userId: userId);

  /// Total focused time in whole minutes, for display.
  int get focusedMinutes => focusedSec ~/ Duration.secondsPerMinute;

  /// Whether this member has any recorded activity at all.
  bool get isEmpty =>
      sessionsCompleted == 0 && focusedSec == 0 && streak == 0;

  /// Reads a stats document.
  ///
  /// [userId] is the document id, which Firestore omits from the data map.
  factory GroupStats.fromFirestore(
    Map<String, dynamic> data, {
    required String userId,
  }) {
    return GroupStats(
      userId: userId,
      sessionsCompleted:
          FirestoreValueUtils.intOrNull(data['sessionsCompleted']) ?? 0,
      focusedSec: FirestoreValueUtils.intOrNull(data['focusedSec']) ?? 0,
      streak: FirestoreValueUtils.intOrNull(data['streak']) ?? 0,
      updatedAt: FirestoreValueUtils.dateTimeOrNull(data['updatedAt']),
    );
  }

  /// Reads a stats document straight from a snapshot.
  factory GroupStats.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) =>
      GroupStats.fromFirestore(
        snapshot.data() ?? const {},
        userId: snapshot.id,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupStats &&
          runtimeType == other.runtimeType &&
          userId == other.userId &&
          sessionsCompleted == other.sessionsCompleted &&
          focusedSec == other.focusedSec &&
          streak == other.streak;

  @override
  int get hashCode =>
      userId.hashCode ^
      sessionsCompleted.hashCode ^
      focusedSec.hashCode ^
      streak.hashCode;

  @override
  String toString() =>
      'GroupStats(userId: $userId, sessionsCompleted: $sessionsCompleted, '
      'focusedSec: $focusedSec, streak: $streak)';
}
