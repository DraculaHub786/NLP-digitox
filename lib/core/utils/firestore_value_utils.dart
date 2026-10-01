// Copyright (c) 2026 NLP digitox

import 'package:cloud_firestore/cloud_firestore.dart';

/// Tolerant readers for values coming back out of Cloud Firestore.
///
/// Firestore types are wider than the models that consume them: a field the
/// client wrote as an `int` returns as an `int`, but the same field written by
/// the Admin SDK, a webhook or an older build can come back as a `double`, a
/// [Timestamp], an ISO `String` or an `int` of milliseconds. Reading those
/// values with a bare cast throws inside a `snapshots()` listener, which
/// silently kills the whole stream — so every field read in the group models
/// goes through here instead.
abstract final class FirestoreValueUtils {
  const FirestoreValueUtils._();

  /// Reads a value as a `String`, or null when it is absent or empty.
  static String? stringOrNull(dynamic value) =>
      value is String && value.isNotEmpty ? value : null;

  /// Reads a value as an `int`, tolerating a `double` or a numeric string.
  static int? intOrNull(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  /// Reads a value as a `bool`, defaulting to [fallback].
  static bool boolOr(dynamic value, {bool fallback = false}) =>
      value is bool ? value : fallback;

  /// Reads a value as a `DateTime`.
  ///
  /// Accepts a Firestore [Timestamp], an ISO-8601 string, or milliseconds since
  /// the epoch. Returns null when nothing usable is present, so callers decide
  /// whether a missing timestamp is fatal or simply "not set".
  static DateTime? dateTimeOrNull(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is num) return DateTime.fromMillisecondsSinceEpoch(value.toInt());
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// Reads a value as a `DateTime`, falling back to [fallback] — now by
  /// default — so a model can always produce a usable sort key.
  static DateTime dateTimeOr(dynamic value, {DateTime? fallback}) =>
      dateTimeOrNull(value) ?? fallback ?? DateTime.now();

  /// Reads a value as a `Map<String, dynamic>`, or an empty map.
  static Map<String, dynamic> mapOrEmpty(dynamic value) {
    if (value is Map) return Map<String, dynamic>.from(value);
    return const {};
  }

  /// Reads a value as a `List<String>`, dropping anything that is not a string.
  static List<String> stringListOrEmpty(dynamic value) {
    if (value is List) return value.whereType<String>().toList();
    return const [];
  }
}
