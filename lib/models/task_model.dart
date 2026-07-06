

import 'package:flutter/material.dart';

enum TaskPriority { low, medium, high }

@immutable
class TaskModel {
  final String id;
  final String title;
  final String? description;
  final TaskPriority priority;
  final DateTime? dueDate;
  final bool completed;
  final Color color;
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime? lastResetDate;

  const TaskModel({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    this.dueDate,
    this.completed = false,
    required this.color,
    required this.createdAt,
    this.completedAt,
    this.lastResetDate,
  });

  TaskModel copyWith({
    String? id,
    String? title,
    String? description,
    TaskPriority? priority,
    DateTime? dueDate,
    bool? completed,
    Color? color,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? lastResetDate,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      dueDate: dueDate ?? this.dueDate,
      completed: completed ?? this.completed,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.index,
      'dueDate': dueDate?.millisecondsSinceEpoch,
      'completed': completed ? 1 : 0,
      'colorValue': color.value,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedAt': completedAt?.millisecondsSinceEpoch,
      'lastResetDate': lastResetDate?.millisecondsSinceEpoch,
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      priority: TaskPriority.values[json['priority'] as int? ?? 0],
      dueDate: json['dueDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['dueDate'] as int)
          : null,
      completed: (json['completed'] as int? ?? 0) == 1,
      color: Color(json['colorValue'] as int),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedAt: json['completedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['completedAt'] as int)
          : null,
      lastResetDate: json['lastResetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastResetDate'] as int)
          : null,
    );
  }
}
