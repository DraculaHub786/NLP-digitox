import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

/// Central registry mapping stable string keys to [IconData].
///
/// WHY THIS EXISTS:
/// `IconData.codePoint` is just an integer glyph index — it only means
/// "coffee cup" (or whatever) inside the specific icon *font* it came from
/// (here, FluentUI). The same integer looked up in a different font
/// (e.g. MaterialIcons) resolves to an unrelated or blank glyph. Persisting
/// only the codePoint and hardcoding a font on reload is what caused icons
/// to change after saving.
///
/// On top of that, `IconData(json['x'] as int, ...)` built dynamically at
/// runtime is invisible to Flutter's icon-font tree-shaker: the tree-shaker
/// can only prove an icon is "used" when it sees a `const IconData(...)`
/// literal (or a const from a package like `FluentIcons.xxx`) referenced
/// directly in the source. A dynamically-reconstructed IconData can have its
/// glyph stripped from the packaged font in release builds, producing a
/// blank/missing icon — the "shaking tree" issue.
///
/// THE FIX: never persist a codePoint. Persist this small string key
/// instead, and always look the icon up through this const map. Every value
/// in [habitIcons] / [noteIcons] is a compile-time const reference to a
/// `FluentIcons.*` constant, so the tree-shaker can always prove it's used —
/// this is immune to tree-shaking regardless of whether `--no-tree-shake-icons`
/// is passed in CI.
class AppIcons {
  AppIcons._();

  // ---- Habit icons (used by habits_screen.dart picker) ----
  static const Map<String, IconData> habitIcons = {
    'coffee': FluentIcons.drink_coffee_20_filled,
    'brain': FluentIcons.brain_circuit_20_filled,
    'phone_dismiss': FluentIcons.phone_dismiss_20_filled,
    'book': FluentIcons.book_20_filled,
    'dumbbell': FluentIcons.dumbbell_20_filled,
    'bed': FluentIcons.bed_20_filled,
    'food': FluentIcons.food_20_filled,
    'heart_pulse': FluentIcons.heart_pulse_20_filled,
  };

  // ---- Note icons (used by notes_screen.dart picker) ----
  static const Map<String, IconData> noteIcons = {
    'note': FluentIcons.note_20_filled,
    'lightbulb': FluentIcons.lightbulb_20_filled,
    'cart': FluentIcons.cart_20_filled,
    'people': FluentIcons.people_20_filled,
    'star': FluentIcons.star_20_filled,
    'heart': FluentIcons.heart_20_filled,
    'flag': FluentIcons.flag_20_filled,
    'calendar': FluentIcons.calendar_20_filled,
  };

  static const String defaultHabitIconKey = 'coffee';
  static const String defaultNoteIconKey = 'note';

  /// Look up a habit icon by key. Falls back to the default if the key is
  /// missing/unknown (e.g. old data, or a future app version removed an icon).
  static IconData habitIcon(String? key) =>
      habitIcons[key] ?? habitIcons[defaultHabitIconKey]!;

  /// Look up a note icon by key. Falls back to the default if the key is
  /// missing/unknown.
  static IconData noteIcon(String? key) =>
      noteIcons[key] ?? noteIcons[defaultNoteIconKey]!;

  /// Reverse lookup used when a picker hands back raw IconData and it needs
  /// to be turned into a key for persistence.
  static String keyForHabitIcon(IconData icon) {
    for (final entry in habitIcons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return defaultHabitIconKey;
  }

  static String keyForNoteIcon(IconData icon) {
    for (final entry in noteIcons.entries) {
      if (entry.value == icon) return entry.key;
    }
    return defaultNoteIconKey;
  }
}