/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Pawan Nagar
 *  *
 *  * This source code is licensed under the GPL-2.0 license license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/task_model.dart';
import 'package:nlp_digitox/providers/productivity/tasks_provider.dart';
import 'package:nlp_digitox/ui/common/modern_background.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/glass_widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Tasks & To-dos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ModernGradientBackground(
        child: SafeArea(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (tasks) {
              final pendingTasks = tasks.where((t) => !t.completed).length;
              final completedTasks = tasks.where((t) => t.completed).length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Statistics
                  Row(
                    children: [
                      Expanded(
                        child: ModernMetricCard(
                          label: 'Pending',
                          value: '$pendingTasks',
                          icon: FluentIcons.clock_20_filled,
                          color: Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernMetricCard(
                          label: 'Completed',
                          value: '$completedTasks',
                          icon: FluentIcons.checkmark_circle_20_filled,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (tasks.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              FluentIcons.task_list_square_ltr_20_regular,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No tasks yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first task',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Pending Tasks
                  if (pendingTasks > 0) ...[
                    ModernDashboardCard(
                      title: 'Pending Tasks',
                      subtitle: '$pendingTasks tasks remaining',
                      icon: const Icon(
                          FluentIcons.task_list_square_ltr_20_filled),
                      accentColor: Colors.orange,
                      children: [
                        ...tasks.where((t) => !t.completed).map((task) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ModernListTile(
                              leading:
                                  const Icon(FluentIcons.circle_20_regular),
                              title: task.title,
                              subtitle:
                                  '${_priorityText(task.priority)} • ${_formatDueDate(task.dueDate)}',
                              color: task.color,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: task.completed,
                                    onChanged: (_) => ref
                                        .read(tasksProvider.notifier)
                                        .toggleTask(task.id),
                                  ),
                                ],
                              ),
                              onTap: () => ref
                                  .read(tasksProvider.notifier)
                                  .toggleTask(task.id),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Completed Tasks
                  if (completedTasks > 0)
                    ModernDashboardCard(
                      title: 'Completed',
                      subtitle: '$completedTasks tasks done',
                      icon: const Icon(FluentIcons.checkmark_circle_20_filled),
                      accentColor: Colors.green,
                      children: [
                        ...tasks.where((t) => t.completed).map((task) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ModernListTile(
                              leading: const Icon(
                                  FluentIcons.checkmark_circle_20_filled),
                              title: task.title,
                              subtitle: 'Completed',
                              color: Colors.green,
                              trailing: IconButton(
                                icon: const Icon(FluentIcons.delete_20_regular),
                                onPressed: () =>
                                    _showDeleteDialog(context, ref, task),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: GlassFAB(
        icon: FluentIcons.add_20_filled,
        label: 'New Task',
        onPressed: () => _showAddTaskDialog(context, ref),
      ),
    );
  }

  String _priorityText(TaskPriority priority) {
    switch (priority) {
      case TaskPriority.high:
        return 'High';
      case TaskPriority.medium:
        return 'Medium';
      case TaskPriority.low:
        return 'Low';
    }
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(date.year, date.month, date.day);

    if (taskDate == today) return 'Today';
    if (taskDate == tomorrow) return 'Tomorrow';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddTaskDialog(BuildContext context, WidgetRef ref) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDueDate;
    Color selectedColor = Colors.orange;

    final colors = [
      Colors.red,
      Colors.orange,
      Colors.amber,
      Colors.green,
      Colors.blue,
      Colors.purple,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Task Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                const Text('Priority:'),
                const SizedBox(height: 8),
                SegmentedButton<TaskPriority>(
                  segments: const [
                    ButtonSegment(
                      value: TaskPriority.low,
                      label: Text('Low'),
                    ),
                    ButtonSegment(
                      value: TaskPriority.medium,
                      label: Text('Medium'),
                    ),
                    ButtonSegment(
                      value: TaskPriority.high,
                      label: Text('High'),
                    ),
                  ],
                  selected: {selectedPriority},
                  onSelectionChanged: (Set<TaskPriority> newSelection) {
                    setState(() => selectedPriority = newSelection.first);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Due Date:'),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() => selectedDueDate = date);
                        }
                      },
                      icon: const Icon(FluentIcons.calendar_20_regular),
                      label: Text(selectedDueDate == null
                          ? 'Select'
                          : _formatDueDate(selectedDueDate)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text('Select Color:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: colors.map((color) {
                    final isSelected = color == selectedColor;
                    return GestureDetector(
                      onTap: () => setState(() => selectedColor = color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color:
                                isSelected ? Colors.white : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                if (titleController.text.trim().isEmpty) return;

                final task = TaskModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  description: descController.text.trim().isEmpty
                      ? null
                      : descController.text.trim(),
                  priority: selectedPriority,
                  dueDate: selectedDueDate,
                  color: selectedColor,
                  createdAt: DateTime.now(),
                );

                ref.read(tasksProvider.notifier).addTask(task);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, TaskModel task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: Text('Are you sure you want to delete "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(tasksProvider.notifier).deleteTask(task.id);
              Navigator.pop(context);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
