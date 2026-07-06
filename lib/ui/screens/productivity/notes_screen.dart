import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/models/note_model.dart';
import 'package:nlp_digitox/providers/productivity/notes_provider.dart';
import 'package:nlp_digitox/ui/common/modern_cards.dart';
import 'package:nlp_digitox/ui/common/scaffold_shell.dart';
import 'package:nlp_digitox/ui/common/sliver_tabs_bottom_padding.dart';
import 'package:nlp_digitox/ui/common/styled_text.dart';
import 'package:nlp_digitox/ui/common/glass_widgets.dart';

class NotesScreen extends ConsumerWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final notesAsync = ref.watch(notesProvider);

    return ScaffoldShell(
      canGoBack: true,
      items: [
        NavbarItem(
          icon: FluentIcons.note_20_regular,
          filledIcon: FluentIcons.note_20_filled,
          titleText: 'Notes & Lists',
          fab: GlassFAB(
            icon: FluentIcons.add_20_filled,
            label: 'New Note',
            onPressed: () => _showAddNoteDialog(context, ref),
          ),
          sliverBody: notesAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => Center(child: StyledText('Error: $error')),
            data: (notes) {
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Statistics Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                      child: ModernMetricCard(
                        label: 'Total Notes',
                        value: '${notes.length}',
                        icon: FluentIcons.note_20_filled,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),

                  if (notes.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                FluentIcons.note_20_regular,
                                size: 64,
                                color: colorScheme.primary.withValues(alpha: 0.5),
                              ),
                              const SizedBox(height: 16),
                              StyledText(
                                'No notes yet',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                              const SizedBox(height: 8),
                              StyledText(
                                'Tap the + button to create your first note',
                                fontSize: 14,
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    // Notes Grid in a SliverToBoxAdapter
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1,
                          ),
                          itemCount: notes.length,
                          itemBuilder: (context, index) {
                            final note = notes[index];
                            return InkWell(
                              onTap: () => _showNoteDetailDialog(context, ref, note),
                              onLongPress: () => _showDeleteDialog(context, ref, note),
                              borderRadius: BorderRadius.circular(20),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: note.color.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: note.color.withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: note.color.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Icon(
                                            note.icon,
                                            color: note.color,
                                            size: 20,
                                          ),
                                        ),
                                        const Spacer(),
                                        Flexible(
                                          child: StyledText(
                                            _formatDate(note.updatedAt),
                                            fontSize: 10,
                                            color: colorScheme.onSurface.withValues(alpha: 0.5),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    StyledText(
                                      note.title,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onSurface,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    StyledText(
                                      note.content,
                                      fontSize: 12,
                                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final noteDate = DateTime(date.year, date.month, date.day);

    if (noteDate == today) return 'Today';
    if (noteDate == yesterday) return 'Yesterday';

    final diff = today.difference(noteDate).inDays;
    if (diff < 7) return '$diff days ago';

    return '${date.day}/${date.month}/${date.year}';
  }

  void _showAddNoteDialog(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    IconData selectedIcon = FluentIcons.note_20_filled;
    Color selectedColor = cs.primary;

    final icons = [
      FluentIcons.note_20_filled,
      FluentIcons.lightbulb_20_filled,
      FluentIcons.cart_20_filled,
      FluentIcons.people_20_filled,
      FluentIcons.star_20_filled,
      FluentIcons.heart_20_filled,
      FluentIcons.flag_20_filled,
      FluentIcons.calendar_20_filled,
    ];

    final colors = <Color>[
      cs.primary,
      Colors.green,
      Colors.purple,
      cs.tertiary,
      Colors.red,
      Colors.pink,
      Colors.teal,
      cs.secondary,
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('New Note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
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
                              ? selectedColor.withValues(alpha: 0.3)
                              : cs.surfaceContainerHighest.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? selectedColor
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Icon(icon, color: selectedColor, size: 20),
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

                final note = NoteModel(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: titleController.text.trim(),
                  content: contentController.text.trim(),
                  color: selectedColor,
                  icon: selectedIcon,
                  createdAt: DateTime.now(),
                  updatedAt: DateTime.now(),
                );

                ref.read(notesProvider.notifier).addNote(note);
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetailDialog(BuildContext context, WidgetRef ref, NoteModel note) {
    final titleController = TextEditingController(text: note.title);
    final contentController = TextEditingController(text: note.content);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(note.icon, color: note.color),
            const SizedBox(width: 8),
            Expanded(child: Text(note.title)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Content',
                  border: OutlineInputBorder(),
                ),
                maxLines: 10,
              ),
            ],
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _showDeleteDialog(context, ref, note);
            },
            icon: Icon(FluentIcons.delete_20_regular, color: Theme.of(context).colorScheme.error),
            label: Text('Delete', style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) return;

              final updatedNote = note.copyWith(
                title: titleController.text.trim(),
                content: contentController.text.trim(),
                updatedAt: DateTime.now(),
              );

              ref.read(notesProvider.notifier).updateNote(updatedNote);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, NoteModel note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: Text('Are you sure you want to delete "${note.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              ref.read(notesProvider.notifier).deleteNote(note.id);
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
