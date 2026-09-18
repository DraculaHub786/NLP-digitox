import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';

/// Central registry of every icon selectable for habits/notes.
///
/// Every icon in the app that a user can pick MUST be listed here as a
/// literal const. Do not construct `IconData` dynamically anywhere else —
/// that's what breaks `--release` icon tree-shaking.
const Map<String, IconData> kSelectableIcons = {
  // Habit icons (from habits_screen.dart icon picker)
  'habit_drink_coffee': FluentIcons.drink_coffee_20_filled,
  'habit_brain_circuit': FluentIcons.brain_circuit_20_filled,
  'habit_phone_dismiss': FluentIcons.phone_dismiss_20_filled,
  'habit_book': FluentIcons.book_20_filled,
  'habit_dumbbell': FluentIcons.dumbbell_20_filled,
  'habit_bed': FluentIcons.bed_20_filled,
  'habit_food': FluentIcons.food_20_filled,
  'habit_heart_pulse': FluentIcons.heart_pulse_20_filled,

  // Note icons (from notes_screen.dart icon picker)
  'note_note': FluentIcons.note_20_filled,
  'note_lightbulb': FluentIcons.lightbulb_20_filled,
  'note_cart': FluentIcons.cart_20_filled,
  'note_people': FluentIcons.people_20_filled,
  'note_star': FluentIcons.star_20_filled,
  'note_heart': FluentIcons.heart_20_filled,
  'note_flag': FluentIcons.flag_20_filled,
  'note_calendar': FluentIcons.calendar_20_filled,
};

/// Reverse lookup: `IconData` -> its registry key, for serialization.
///
/// Compares by (codePoint, fontFamily, fontPackage) since IconData doesn't
/// override `==`.
String? iconKeyOf(IconData icon) {
  for (final entry in kSelectableIcons.entries) {
    final candidate = entry.value;
    if (candidate.codePoint == icon.codePoint &&
        candidate.fontFamily == icon.fontFamily &&
        candidate.fontPackage == icon.fontPackage) {
      return entry.key;
    }
  }
  return null;
}

/// Forward lookup used when loading from storage. Falls back to a safe
/// default if the key is missing/unrecognized (e.g. old data, or an icon
/// that was later removed from the picker).
IconData iconFromKey(String? key) {
  if (key == null) return _fallbackIcon;
  return kSelectableIcons[key] ?? _fallbackIcon;
}

const IconData _fallbackIcon = FluentIcons.question_circle_20_filled;
