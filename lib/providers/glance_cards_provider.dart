

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GlanceCard {
  dataTotal,
  dataMobile,
  dataWifi,
  focusWeekly,
  focusMonthly,
  focusLifetime,
}

class GlanceCardsNotifier extends StateNotifier<List<GlanceCard>> {
  static const String _key = 'glance_cards_order';

  GlanceCardsNotifier() : super(_defaultCards) {
    _loadCards();
  }

  static final List<GlanceCard> _defaultCards = [
    GlanceCard.dataTotal,
    GlanceCard.dataMobile,
    GlanceCard.dataWifi,
    GlanceCard.focusWeekly,
    GlanceCard.focusMonthly,
    GlanceCard.focusLifetime,
  ];

  Future<void> _loadCards() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key);
      if (saved != null && saved.isNotEmpty) {
        state = saved
            .map((name) => GlanceCard.values.firstWhere(
                  (card) => card.name == name,
                  orElse: () => GlanceCard.dataTotal,
                ))
            .toList();
      }
    } catch (e) {
      print('Error loading glance cards: $e');
    }
  }

  Future<void> updateCards(List<GlanceCard> newCards) async {
    state = newCards;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        _key,
        newCards.map((card) => card.name).toList(),
      );
    } catch (e) {
      print('Error saving glance cards: $e');
    }
  }

  Future<void> resetToDefault() async {
    await updateCards(_defaultCards);
  }
}

final glanceCardsProvider =
    StateNotifierProvider<GlanceCardsNotifier, List<GlanceCard>>((ref) {
  return GlanceCardsNotifier();
});