import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/config/design_tokens.dart';
import 'package:nlp_digitox/models/task_model.dart';
import 'package:nlp_digitox/providers/productivity/tasks_provider.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/glass_widgets.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final tasksAsync = ref.watch(tasksProvider);

    return ScaffoldShell(
      canGoBack: true,
      items: [
        NavbarItem(
          icon: FluentIcons.reading_list_20_regular,
          filledIcon: FluentIcons.reading_list_20_filled,
          titleText: 'Tasks & To-dos',
          fab: GlassFAB(
            icon: FluentIcons.add_20_filled,
            label: 'New Task',
            onPressed: () => _showAddTaskDialog(context, ref),
          ),
          sliverBody: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: StyledText('Error: $error')),
            data: (tasks) {
              final pendingTasks = tasks.where((t) => !t.completed).length;
              final completedTasks = tasks.where((t) => t.completed).length;

              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Statistics Cards
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ModernMetricCard(
                              label: 'Pending',
                              value: '$pendingTasks',
                              icon: FluentIcons.clock_20_filled,
                              color: colorScheme.tertiary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ModernMetricCard(
                              label: 'Completed',
                              value: '$completedTasks',
                              icon: FluentIcons.checkmark_circle_20_filled,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (tasks.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                FluentIcons.task_list_square_ltr_20_regular,
                                size: 64,
                                color: colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              StyledText(
                                'No tasks yet',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 8),
                              StyledText(
                                'Tap the + button to create your first task',
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Pending Tasks
                  if (pendingTasks > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                        child: ModernDashboardCard(
                          title: 'Pending Tasks',
                          subtitle: '$pendingTasks tasks remaining',
                          icon: const Icon(FluentIcons.task_list_square_ltr_20_filled),
                          accentColor: colorScheme.tertiary,
                          children: [
                            ...tasks.where((t) => !t.completed).map((task) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ModernListTile(
                                  leading: const Icon(FluentIcons.circle_20_regular),
                                  title: task.title,
                                  subtitle: '${_priorityText(task.priority)} • ${_formatDueDate(task.dueDate)}',
                                  color: task.color,
                                  trailing: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Row(
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
                                  ),
                                  onTap: () => ref
                                      .read(tasksProvider.notifier)
                                      .toggleTask(task.id),
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                  // Completed Tasks
                  if (completedTasks > 0)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                        child: ModernDashboardCard(
                          title: 'Completed',
                          subtitle: '$completedTasks tasks done',
                          icon: const Icon(FluentIcons.checkmark_circle_20_filled),
                          accentColor: colorScheme.primary,
                          children: [
                            ...tasks.where((t) => t.completed).map((task) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: ModernListTile(
                                  leading: const Icon(FluentIcons.checkmark_circle_20_filled),
                                  title: task.title,
                                  subtitle: 'Completed',
                                  color: colorScheme.primary,
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
                      ),
                    ),

                  const SliverTabsBottomPadding(),
                ],
              );
            },
          ),
        )
      ],
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
    final cs = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final descController = TextEditingController();
    TaskPriority selectedPriority = TaskPriority.medium;
    DateTime? selectedDueDate;
    Color selectedColor = cs.tertiary;

    final colors = <Color>[
      cs.tertiary,
      cs.primary,
      cs.secondary,
      cs.primaryContainer,
      cs.error,
      GlassTokens.of(context).statusGood,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
      builder: (context, setState) => AlertDialog(
          backgroundColor: GlassTokens.of(context).fillTop,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
          ),
          title: const Text('New Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Task Title',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide:
                          BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide:
                          BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    filled: true,
                    fillColor: cs.surfaceContainerHighest.withValues(alpha: 0.3),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide:
                          BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide:
                          BorderSide(color: cs.outline.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(GlassTokens.radiusCard),
                      borderSide: BorderSide(color: cs.primary, width: 1.5),
                    ),
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
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
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
        backgroundColor: GlassTokens.of(context).fillTop,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GlassTokens.radiusCard),
        ),
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
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
