import 'package:flutter/material.dart';

enum FocusGoalType {
  study,
  work,
  read,
  meditation,
  exercise,
  creative,
  custom,
}

class FocusGoal {
  final String id;
  final String title;
  final FocusGoalType type;
  final Duration targetDuration;
  final DateTime createdAt;
  final String? description;
  final Color color;

  FocusGoal({
    required this.id,
    required this.title,
    required this.type,
    required this.targetDuration,
    required this.createdAt,
    this.description,
    required this.color,
  });

  factory FocusGoal.fromJson(Map<String, dynamic> json) {
    return FocusGoal(
      id: json['id'] as String,
      title: json['title'] as String,
      type: FocusGoalType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FocusGoalType.custom,
      ),
      targetDuration: Duration(minutes: json['targetMinutes'] as int),
      createdAt: DateTime.parse(json['createdAt'] as String),
      description: json['description'] as String?,
      color: Color(json['color'] as int),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type.name,
      'targetMinutes': targetDuration.inMinutes,
      'createdAt': createdAt.toIso8601String(),
      'description': description,
      'color': color.toARGB32(),
    };
  }
}

class FocusSession {
  final String id;
  final FocusGoal goal;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration elapsed;
  final bool isCompleted;
  final int distractionCount;

  FocusSession({
    required this.id,
    required this.goal,
    required this.startTime,
    this.endTime,
    required this.elapsed,
    required this.isCompleted,
    this.distractionCount = 0,
  });

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      id: json['id'] as String,
      goal: FocusGoal.fromJson(json['goal'] as Map<String, dynamic>),
      startTime: DateTime.parse(json['startTime'] as String),
      endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
      elapsed: Duration(seconds: json['elapsedSeconds'] as int),
      isCompleted: json['isCompleted'] as bool,
      distractionCount: json['distractionCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'goal': goal.toJson(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime?.toIso8601String(),
      'elapsedSeconds': elapsed.inSeconds,
      'isCompleted': isCompleted,
      'distractionCount': distractionCount,
    };
  }

  FocusSession copyWith({
    Duration? elapsed,
    DateTime? endTime,
    bool? isCompleted,
    int? distractionCount,
  }) {
    return FocusSession(
      id: id,
      goal: goal,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      elapsed: elapsed ?? this.elapsed,
      isCompleted: isCompleted ?? this.isCompleted,
      distractionCount: distractionCount ?? this.distractionCount,
    );
  }
}
