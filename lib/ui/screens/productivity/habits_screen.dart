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
import 'package:nlp_digitox/models/habit_model.dart';
import 'package:nlp_digitox/providers/productivity/habits_provider.dart';
import 'package:nlp_digitox/ui/common/modern_background.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/glass_widgets.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final habitsAsync = ref.watch(habitsProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Habits'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: ModernGradientBackground(
        child: SafeArea(
          child: habitsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: Text('Error: $error')),
            data: (habits) {
              final bestStreak = habits.isEmpty
                  ? 0
                  : habits.map((h) => h.streak).reduce((a, b) => a > b ? a : b);
              final completedCount =
                  habits.where((h) => h.completedToday).length;

              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // Statistics Cards
                  Row(
                    children: [
                      Expanded(
                        child: ModernMetricCard(
                          label: 'Active Habits',
                          value: '${habits.length}',
                          icon: FluentIcons.drink_coffee_20_filled,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ModernMetricCard(
                          label: 'Best Streak',
                          value: '$bestStreak',
                          icon: FluentIcons.trophy_20_filled,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  if (habits.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(
                              FluentIcons.drink_coffee_20_regular,
                              size: 64,
                              color: theme.colorScheme.primary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No habits yet',
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap the + button to create your first habit',
                              style: theme.textTheme.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    // Habits List
                    ModernDashboardCard(
                      title: 'Today\'s Habits',
                      subtitle:
                          '$completedCount of ${habits.length} completed',
                      icon:
                          const Icon(FluentIcons.checkmark_circle_20_filled),
                      accentColor: theme.colorScheme.primary,
                      children: [
                        ...habits.map((habit) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: ModernListTile(
                              leading: Icon(habit.icon),
                              title: habit.name,
                              subtitle: '${habit.streak} day streak 🔥',
                              color: habit.color,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Checkbox(
                                    value: habit.completedToday,
                                    onChanged: (_) => ref
                                        .read(habitsProvider.notifier)
                                        .toggleHabit(habit.id),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                        FluentIcons.delete_20_regular),
                                    onPressed: () => _showDeleteDialog(
                                        context, ref, habit),
                                  ),
                                ],
                              ),
                              onTap: () => ref
                                  .read(habitsProvider.notifier)
                                  .toggleHabit(habit.id),
                            ),
                          );
                        }).toList(),
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
        label: 'New Habit',
        onPressed: () => _showAddHabitDialog(context, ref),
      ),
    );
  }

  void _showAddHabitDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    IconData selectedIcon = FluentIcons.drink_coffee_20_filled;
    Color selectedColor = Colors.purple;

    final icons = [
      FluentIcons.drink_coffee_20_filled,
      FluentIcons.brain_circuit_20_filled,
      FluentIcons.phone_dismiss_20_filled,
      FluentIcons.book_20_filled,
      FluentIcons.dumbbell_20_filled,
      FluentIcons.bed_20_filled,
      FluentIcons.food_20_filled,
      FluentIcons.heart_pulse_20_filled,
    ];

    final colors = [
      Colors.purple,
      Colors.blue,
      Colors.teal,
      Colors.orange,
      Colors.red,
      Colors.green,
      Colors.pink,
      Colors.amber,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Habit'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Habit Name',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                const Text('Select Icon:'),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: icons.map((icon) {
                    final isSelected = icon == selectedIcon;
                    return GestureDetector(
                      onTap: () => setState(() => selectedIcon = icon),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? selectedColor.withOpacity(0.3)
                              : Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, color: selectedColor),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
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
                            color: isSelected ? Colors.white : Colors.transparent,
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
                if (nameController.text.trim().isEmpty) return;

                final habit = HabitModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  icon: selectedIcon,
                  color: selectedColor,
                  createdAt: DateTime.now(),
                );

                ref.read(habitsProvider.notifier).addHabit(habit);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, HabitModel habit) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Habit'),
        content: Text('Are you sure you want to delete "${habit.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(habitsProvider.notifier).deleteHabit(habit.id);
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
