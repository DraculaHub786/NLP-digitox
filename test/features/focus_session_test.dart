import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/features/focus_session/models.dart';
import 'package:flutter/material.dart';

/// Unit tests for FocusSessionService
/// 
/// Note: These tests require mocking SharedPreferences for full execution.
/// This file serves as a test structure template. For integration testing,
/// see MANUAL_TESTING_GUIDE.md
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FocusSessionService Tests', () {

    test('FocusSession model should be created correctly', () {
      final goal = FocusGoal(
        id: '1',
        title: 'Test Session',
        type: FocusGoalType.study,
        targetDuration: const Duration(minutes: 25),
        createdAt: DateTime.now(),
        color: Colors.blue,
      );

      expect(goal.id, '1');
      expect(goal.title, 'Test Session');
      expect(goal.type, FocusGoalType.study);
      expect(goal.targetDuration.inMinutes, 25);
    });

    test('FocusSession should have correct properties', () {
      final goal = FocusGoal(
        id: '2',
        title: 'Work Session',
        type: FocusGoalType.work,
        targetDuration: const Duration(minutes: 30),
        createdAt: DateTime.now(),
        color: Colors.green,
      );

      final session = FocusSession(
        id: 'session-1',
        goal: goal,
        startTime: DateTime.now(),
        elapsed: const Duration(minutes: 10),
        isCompleted: false,
      );

      expect(session.id, 'session-1');
      expect(session.goal.title, 'Work Session');
      expect(session.elapsed.inMinutes, 10);
      expect(session.isCompleted, false);
    });

    test('FocusGoalType enum should have all types', () {
      expect(FocusGoalType.values.length, 7);
      expect(FocusGoalType.values.contains(FocusGoalType.study), true);
      expect(FocusGoalType.values.contains(FocusGoalType.work), true);
      expect(FocusGoalType.values.contains(FocusGoalType.read), true);
      expect(FocusGoalType.values.contains(FocusGoalType.meditation), true);
      expect(FocusGoalType.values.contains(FocusGoalType.exercise), true);
      expect(FocusGoalType.values.contains(FocusGoalType.creative), true);
      expect(FocusGoalType.values.contains(FocusGoalType.custom), true);
    });
  });
}
