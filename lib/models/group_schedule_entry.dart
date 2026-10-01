// Copyright (c) 2026 NLP digitox

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nlp_digitox/core/constants/session_limits.dart';
import 'package:nlp_digitox/core/utils/firestore_value_utils.dart';

/// One planned session on a group's schedule.
///
/// Stored under `groups/{gid}/schedule/{id}`. It is a *plan*, not a session:
/// nothing is running until someone taps start, and a plan that passes while
/// nobody starts simply becomes past. Keeping the two apart is what lets a
/// group hold a recurring meeting without leaving a trail of empty sessions
/// behind it.
@immutable
class GroupScheduleEntry {
  /// The document id inside `schedule/`.
  final String id;

  /// What the session is for — shown as the row title.
  final String title;

  /// When it is planned to begin, in the device's local time.
  final DateTime startsAt;

  /// How long the shared run lasts, in seconds. Always inside
  /// [SessionLimits] bounds, because it is handed straight to the session the
  /// host starts.
  final int durationSec;

  /// The focus category, as the session's `type` wire value.
  final String type;

  /// The user who added the plan.
  final String createdBy;

  /// When the plan was added.
  final DateTime createdAt;

  const GroupScheduleEntry({
    required this.id,
    required this.title,
    required this.startsAt,
    this.durationSec = SessionLimits.defaultDurationSec,
    this.type = 'study',
    required this.createdBy,
    required this.createdAt,
  });

  /// When the planned session is due to end.
  DateTime get endsAt =>
      startsAt.add(Duration(seconds: SessionLimits.normalizeDurationSec(durationSec)));

  /// Whether the planned start has already passed.
  bool get isPast => DateTime.now().isAfter(startsAt);

  /// The run length in whole minutes, for display.
  int get durationMinutes =>
      SessionLimits.normalizeDurationSec(durationSec) ~/ 60;

  /// Reads a schedule document.
  ///
  /// [id] is the document id, which Firestore omits from the data map.
  factory GroupScheduleEntry.fromFirestore(
    Map<String, dynamic> data, {
    required String id,
  }) {
    return GroupScheduleEntry(
      id: id,
      title: FirestoreValueUtils.stringOrNull(data['title']) ?? 'Focus session',
      startsAt: FirestoreValueUtils.dateTimeOr(data['startsAt']),
      durationSec: SessionLimits.normalizeDurationSec(
        FirestoreValueUtils.intOrNull(data['durationSec']),
      ),
      type: FirestoreValueUtils.stringOrNull(data['type']) ?? 'study',
      createdBy: FirestoreValueUtils.stringOrNull(data['createdBy']) ?? '',
      createdAt: FirestoreValueUtils.dateTimeOr(data['createdAt']),
    );
  }

  /// Reads a schedule document straight from a snapshot.
  factory GroupScheduleEntry.fromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) =>
      GroupScheduleEntry.fromFirestore(
        snapshot.data() ?? const {},
        id: snapshot.id,
      );

  /// The Firestore payload for this plan.
  Map<String, dynamic> toFirestore() => {
        'title': title,
        'startsAt': Timestamp.fromDate(startsAt),
        'durationSec': SessionLimits.normalizeDurationSec(durationSec),
        'type': type,
        'createdBy': createdBy,
        'createdAt': Timestamp.fromDate(createdAt),
      };

  GroupScheduleEntry copyWith({
    String? id,
    String? title,
    DateTime? startsAt,
    int? durationSec,
    String? type,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return GroupScheduleEntry(
      id: id ?? this.id,
      title: title ?? this.title,
      startsAt: startsAt ?? this.startsAt,
      durationSec: durationSec ?? this.durationSec,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Ascending by start time, so a schedule list is always in reading order.
  static int compareByStart(GroupScheduleEntry a, GroupScheduleEntry b) =>
      a.startsAt.compareTo(b.startsAt);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupScheduleEntry &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          startsAt == other.startsAt &&
          durationSec == other.durationSec;

  @override
  int get hashCode =>
      id.hashCode ^ title.hashCode ^ startsAt.hashCode ^ durationSec.hashCode;

  @override
  String toString() =>
      'GroupScheduleEntry(id: $id, title: $title, startsAt: $startsAt, '
      'durationSec: $durationSec)';
}
