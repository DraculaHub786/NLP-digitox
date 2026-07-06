

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nlp_digitox/providers/glance_cards_provider.dart';

class GlanceCustomizationDialog extends ConsumerStatefulWidget {
  const GlanceCustomizationDialog({super.key});

  @override
  ConsumerState<GlanceCustomizationDialog> createState() =>
      _GlanceCustomizationDialogState();
}

class _GlanceCustomizationDialogState
    extends ConsumerState<GlanceCustomizationDialog> {
  late List<GlanceCard> _cards;

  @override
  void initState() {
    super.initState();
    _cards = List.from(ref.read(glanceCardsProvider));
  }

  String _getCardTitle(GlanceCard card) {
    switch (card) {
      case GlanceCard.dataTotal:
        return 'Total Data Usage';
      case GlanceCard.dataMobile:
        return 'Mobile Data Usage';
      case GlanceCard.dataWifi:
        return 'WiFi Data Usage';
      case GlanceCard.focusWeekly:
        return 'Weekly Focus Time';
      case GlanceCard.focusMonthly:
        return 'Monthly Focus Time';
      case GlanceCard.focusLifetime:
        return 'Lifetime Focus Time';
    }
  }

  IconData _getCardIcon(GlanceCard card) {
    switch (card) {
      case GlanceCard.dataTotal:
      case GlanceCard.dataMobile:
      case GlanceCard.dataWifi:
        return Icons.data_usage;
      case GlanceCard.focusWeekly:
      case GlanceCard.focusMonthly:
      case GlanceCard.focusLifetime:
        return Icons.timer;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Customize Glance Cards'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Long press and drag to reorder cards',
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _cards.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex--;
                    }
                    final card = _cards.removeAt(oldIndex);
                    _cards.insert(newIndex, card);
                  });
                },
                itemBuilder: (context, index) {
                  final card = _cards[index];
                  return Card(
                    key: ValueKey(card),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(_getCardIcon(card)),
                      title: Text(_getCardTitle(card)),
                      trailing: const Icon(Icons.drag_handle),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(glanceCardsProvider.notifier).resetToDefault();
            Navigator.pop(context);
          },
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            ref.read(glanceCardsProvider.notifier).updateCards(_cards);
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}