/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Pawan Nagar
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/habit_model.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';

class HabitsNotifier extends StateNotifier<AsyncValue<List<HabitModel>>> {
  HabitsNotifier() : super(const AsyncValue.loading()) {
    loadHabits();
  }

  final _service = ProductivityService.instance;

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

    // Calculate streak
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
    );

    await updateHabit(updatedHabit);
  }
}

final habitsProvider =
    StateNotifierProvider<HabitsNotifier, AsyncValue<List<HabitModel>>>((ref) {
  return HabitsNotifier();
});
