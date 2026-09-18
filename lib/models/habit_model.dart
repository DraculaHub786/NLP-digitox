import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/constants/app_icons.dart';

@immutable
class HabitModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int streak;
  final bool completedToday;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final DateTime? lastCompletedDate;
  final DateTime? lastResetDate;

  const HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.streak = 0,
    this.completedToday = false,
    required this.createdAt,
    this.completedDates = const [],
    this.lastCompletedDate,
    this.lastResetDate,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? streak,
    bool? completedToday,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    DateTime? lastCompletedDate,
    DateTime? lastResetDate,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      completedToday: completedToday ?? this.completedToday,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': iconKeyOf(icon) ?? 'habit_drink_coffee', // safe default key
      'colorValue': color.toARGB32(),
      'streak': streak,
      'completedToday': completedToday ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedDates': completedDates.map((d) => d.millisecondsSinceEpoch).toList(),
      'lastCompletedDate': lastCompletedDate?.millisecondsSinceEpoch,
      'lastResetDate': lastResetDate?.millisecondsSinceEpoch,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      // New format: 'iconKey' (String). Old format: 'iconCodePoint' (int) —
      // migrated on first load, see Step 3. Once every install has re-saved
      // at least once, the codePoint branch can be deleted.
      icon: json['iconKey'] != null
          ? iconFromKey(json['iconKey'] as String)
          : _legacyIconFromCodePoint(json['iconCodePoint'] as int?),
      color: Color(json['colorValue'] as int),
      streak: json['streak'] as int? ?? 0,
      completedToday: (json['completedToday'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.fromMillisecondsSinceEpoch(e as int))
              .toList() ??
          [],
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCompletedDate'] as int)
          : null,
      lastResetDate: json['lastResetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastResetDate'] as int)
          : null,
    );
  }
}

/// Migration shim for habits saved before icons were stored by key. The
/// stored value is the Fluent glyph codePoint, so it can be matched back to
/// the exact icon the user picked (see [iconFromLegacyCodePoint]). Only if
/// the glyph is no longer in the picker do we fall back to the picker's
/// first option.
IconData _legacyIconFromCodePoint(int? codePoint) {
  return iconFromLegacyCodePoint(
    codePoint,
    fallback: iconFromKey('habit_drink_coffee'),
  );
}
