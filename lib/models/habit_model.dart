/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Pawan Nagar
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter/material.dart';

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

  const HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.streak = 0,
    this.completedToday = false,
    required this.createdAt,
    this.completedDates = const [],
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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconCodePoint': icon.codePoint,
      'colorValue': color.value,
      'streak': streak,
      'completedToday': completedToday ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedDates': completedDates.map((d) => d.millisecondsSinceEpoch).toList(),
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
      color: Color(json['colorValue'] as int),
      streak: json['streak'] as int? ?? 0,
      completedToday: (json['completedToday'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.fromMillisecondsSinceEpoch(e as int))
              .toList() ??
          [],
    );
  }
}
