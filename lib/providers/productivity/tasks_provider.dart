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
import 'package:nlp_digitox/models/task_model.dart';
import 'package:nlp_digitox/core/services/productivity_service.dart';

class TasksNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  TasksNotifier() : super(const AsyncValue.loading()) {
    loadTasks();
  }

  final _service = ProductivityService.instance;

  Future<void> loadTasks() async {
    state = const AsyncValue.loading();
    try {
      final tasks = await _service.getTasks();
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addTask(TaskModel task) async {
    await _service.addTask(task);
    await loadTasks();
  }

  Future<void> updateTask(TaskModel task) async {
    await _service.updateTask(task);
    await loadTasks();
  }

  Future<void> deleteTask(String id) async {
    await _service.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleTask(String id) async {
    final tasks = state.value;
    if (tasks == null) return;

    final taskIndex = tasks.indexWhere((t) => t.id == id);
    if (taskIndex == -1) return;

    final task = tasks[taskIndex];
    final isCompleted = !task.completed;

    final updatedTask = task.copyWith(
      completed: isCompleted,
      completedAt: isCompleted ? DateTime.now() : null,
    );

    await updateTask(updatedTask);
  }
}

final tasksProvider =
    StateNotifierProvider<TasksNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksNotifier();
});
