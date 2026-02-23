// Copyright (c) 2024 NLP digitox

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/habit_model.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';
import 'package:nlp_digitox/core/services/productivity_points_service.dart';

class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  HabitsNotifier() : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final _service = ProductivityService.instance;
  final _pointsService = ProductivityPointsService.instance;

  Future<void> loadHabits() async {
    state = const AsyncValue.loading();
    try {
      final habits = await _service.getHabits();
      state = AsyncValue.data(habits);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addHabit(HabitModel habit) async {
    final currentHabits = state.value ?? [];
    if (currentHabits.length >= 4) {
      throw Exception('Maximum 4 habits allowed');
    }
    await _service.addHabit(habit);
    await loadHabits();
  }

  Future<void> updateHabit(HabitModel habit) async {
    await _service.updateHabit(habit);
    await loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    await _service.deleteHabit(id);
    await loadHabits();
  }

  Future<void> toggleHabit(String id) async {
    final habits = state.value;
    if (habits == null) return;

    final habitIndex = habits.indexWhere((h) => h.id == id);
    if (habitIndex == -1) return;

    final habit = habits[habitIndex];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final isCompletedToday = !habit.completedToday;
    final updatedCompletedDates = List<DateTime>.from(habit.completedDates);

    if (isCompletedToday) {
      updatedCompletedDates.add(today);
    } else {
      updatedCompletedDates.removeWhere((date) =>
          date.year == today.year &&
          date.month == today.month &&
          date.day == today.day);
    }
    int newStreak = 0;
    if (isCompletedToday) {
      newStreak = 1;
      final sortedDates = updatedCompletedDates.toList()..sort();
      
      for (int i = sortedDates.length - 2; i >= 0; i--) {
        final currentDate = sortedDates[i + 1];
        final previousDate = sortedDates[i];
        final difference = currentDate.difference(previousDate).inDays;
        
        if (difference == 1) {
          newStreak++;
        } else {
          break;
        }
      }
    }

    final updatedHabit = habit.copyWith(
      completedToday: isCompletedToday,
      completedDates: updatedCompletedDates,
      streak: newStreak,
      lastCompletedDate: isCompletedToday ? now : habit.lastCompletedDate,
    );

    await updateHabit(updatedHabit);

    if (isCompletedToday) {
      await _pointsService.awardHabitCompletionPoints(
        habitId: habit.id,
        habitName: habit.name,
        showNotification: true,
      );
    }
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitModel>>>((ref) {
  return HabitsNotifier();
});
