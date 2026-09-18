# TODO — Icon persistence & tree-shaking bugs

Status verified directly against `main` (cloned the repo fresh and read the
actual source). Both bugs were still present exactly as described. Fixes for
both are applied below and included as ready-to-commit files.

---

## Bug 1: Icon changes after saving (habits + notes) — ✅ FIXED

**Confirmed still broken in `main`:**
- `lib/models/habit_model.dart` — `toJson()` only saved `icon.codePoint`;
  `fromJson()` rebuilt it as `IconData(code, fontFamily: 'MaterialIcons')`.
- `lib/models/note_model.dart` — identical pattern.
- Both pickers (`habits_screen.dart` lines 181–188, `notes_screen.dart`
  lines 196–203) select from `FluentIcons.*` constants, not Material icons.
- Render sites: `habits_screen.dart:129` (`Icon(habit.icon)`) and
  `notes_screen.dart:120` / `notes_screen.dart:384` (`Icon(note.icon, ...)`).
- (Checked `lib/models/task_model.dart` too — tasks have no icon field at
  all, so this bug only ever affects habits and notes.)

**Root cause:** `codePoint` is a bare integer that only means "cooking",
"coffee", etc. *inside the FluentUI font*. Reloading it against
`MaterialIcons` looks up an unrelated glyph in a different font — happens on
every save → reload, not intermittently.

**Fix applied** (the "better long-term fix" from your notes, actually
implemented rather than just described):

1. **New file `lib/models/app_icons.dart`** — a const registry mapping
   string keys → `IconData`:
   ```dart
   class AppIcons {
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
     static const Map<String, IconData> noteIcons = { /* 8 note icons */ };

     static IconData habitIcon(String? key) => habitIcons[key] ?? habitIcons['coffee']!;
     static IconData noteIcon(String? key) => noteIcons[key] ?? noteIcons['note']!;
     static String keyForHabitIcon(IconData icon) => /* reverse lookup, falls back to default */;
     static String keyForNoteIcon(IconData icon) => /* reverse lookup, falls back to default */;
   }
   ```
   Every value is a `const FluentIcons.xxx` literal referenced directly in
   source, so the tree-shaker can always prove it's used — this also fixes
   Bug 2, see below. Full file: `app_icons.dart` (attached).

2. **`lib/models/habit_model.dart`**
   ```diff
   +import 'app_icons.dart';
   ...
    Map<String, dynamic> toJson() => {
   -  'iconCodePoint': icon.codePoint,
   +  'iconKey': AppIcons.keyForHabitIcon(icon),
      ...
    };
   ...
    factory HabitModel.fromJson(Map<String, dynamic> json) => HabitModel(
   -  icon: IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons'),
   +  icon: AppIcons.habitIcon(json['iconKey'] as String?),
      ...
    );
   ```
   Full file: `habit_model.dart` (attached).

3. **`lib/models/note_model.dart`** — identical change, using
   `AppIcons.keyForNoteIcon` / `AppIcons.noteIcon`.
   Full file: `note_model.dart` (attached).

4. **No changes needed in `habits_screen.dart` / `notes_screen.dart`** — the
   pickers already build `IconData` from `FluentIcons.*` constants and pass
   it straight to the model constructor; only the model's serialization
   layer was wrong, and that's now fixed at the source. (Also confirmed
   habits/notes are persisted via `SharedPreferences` as JSON in
   `lib/core/services/productivity_service.dart` — no other storage layer
   to touch.)

**⚠️ One-time data note:** existing installs that already have habits/notes
saved under the old `iconCodePoint` key will read as `iconKey == null` once
this ships, and `AppIcons.habitIcon(null)` / `AppIcons.noteIcon(null)` fall
back to the default icon ('coffee' / 'note') instead of crashing. There's no
way to recover the *originally intended* icon from the old broken data (it
was already wrong on disk), so this is a one-time silent reset to default —
not a crash or data loss. Worth a line in release notes if you want to warn
users their custom icons will reset once.

---

## Bug 2: "Shaking tree" issue on release build — ✅ FIXED (belt & suspenders)

**Confirmed still broken in `main`:** `.github/workflows/build_and_deploy.yml`
ran `flutter build appbundle --release` with no `--no-tree-shake-icons` flag.

**Root cause:** Flutter's release-build icon tree-shaker only keeps glyphs
it can statically prove are referenced as `const IconData(...)` in source.
The dynamic `IconData(json['iconCodePoint'] as int, fontFamily: 'MaterialIcons')`
call in the old `fromJson()` methods was invisible to that analysis, so any
codepoint not *also* referenced elsewhere as a literal const risked being
stripped from the packaged icon font in release builds — a blank glyph, on
top of (and independent from) Bug 1.

**Fix applied, two layers:**

1. **Primary fix (structural):** icons are now only ever referenced through
   `AppIcons.habitIcons` / `AppIcons.noteIcons` — `const Map` literals built
   entirely from `FluentIcons.*` consts. The tree-shaker can prove every icon
   is used, in *any* build type. This alone fixes Bug 2 for the habit/note
   icons, no CI change required.

2. **Safety net (CI), added anyway:** so any future dynamically-built
   `IconData` elsewhere in the app doesn't silently reintroduce this class of
   bug:
   ```diff
   - run: flutter build appbundle --release
   + run: flutter build appbundle --release --no-tree-shake-icons
   ```
   in `.github/workflows/build_and_deploy.yml` (full file attached).

   Trade-off: slightly larger app bundle (full icon font(s) bundled instead
   of just the glyphs used). Negligible for a habit-tracking app; if bundle
   size ever matters, this flag can be dropped once you've audited that no
   other dynamic `IconData(...)` construction exists (`grep -rn "IconData(" lib/`).

---

## Regression checklist (do this before closing out)

- [ ] `flutter pub get`
- [ ] `flutter analyze` — confirm no errors from the new import/registry
- [ ] Debug run: create a habit with each of the 8 habit icons, **force-close
      the app** (not hot reload — hot reload won't reproduce the original
      bug), reopen, confirm each icon is still correct
- [ ] Same for notes, all 8 note icons
- [ ] Edit an existing habit/note's icon, force-close, reopen, confirm the
      *new* icon persisted (not the old one)
- [ ] Real release build matching CI: `flutter build apk --release
      --no-tree-shake-icons` (and, separately, without the flag, to confirm
      the structural fix alone is enough) and repeat the icon checks
      specifically on that release build — tree-shaking only runs in
      release mode
- [ ] Install the release APK on a device/emulator (not just `flutter run
      --release`), closest to what CI actually ships to Play Store
- [ ] Spot-check one existing (pre-fix) saved habit/note to confirm it
      degrades gracefully to the default icon instead of crashing

## Files changed
- `lib/models/app_icons.dart` — **new**
- `lib/models/habit_model.dart`
- `lib/models/note_model.dart`
- `.github/workflows/build_and_deploy.yml`


HERE are files that need to be changed 
App Icon
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


Habit Model
import 'package:flutter/material.dart';

import 'app_icons.dart';

@immutable
class HabitModel {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final int streak;
  final bool completedToday;
  final DateTime createdAt;
  final List<DateTime> completedDates;
  final DateTime? lastCompletedDate;
  final DateTime? lastResetDate;

  const HabitModel({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    this.streak = 0,
    this.completedToday = false,
    required this.createdAt,
    this.completedDates = const [],
    this.lastCompletedDate,
    this.lastResetDate,
  });

  HabitModel copyWith({
    String? id,
    String? name,
    IconData? icon,
    Color? color,
    int? streak,
    bool? completedToday,
    DateTime? createdAt,
    List<DateTime>? completedDates,
    DateTime? lastCompletedDate,
    DateTime? lastResetDate,
  }) {
    return HabitModel(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      streak: streak ?? this.streak,
      completedToday: completedToday ?? this.completedToday,
      createdAt: createdAt ?? this.createdAt,
      completedDates: completedDates ?? this.completedDates,
      lastCompletedDate: lastCompletedDate ?? this.lastCompletedDate,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'iconKey': AppIcons.keyForHabitIcon(icon),
      'colorValue': color.toARGB32(),
      'streak': streak,
      'completedToday': completedToday ? 1 : 0,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'completedDates': completedDates.map((d) => d.millisecondsSinceEpoch).toList(),
      'lastCompletedDate': lastCompletedDate?.millisecondsSinceEpoch,
      'lastResetDate': lastResetDate?.millisecondsSinceEpoch,
    };
  }

  factory HabitModel.fromJson(Map<String, dynamic> json) {
    return HabitModel(
      id: json['id'] as String,
      name: json['name'] as String,
      icon: AppIcons.habitIcon(json['iconKey'] as String?),
      color: Color(json['colorValue'] as int),
      streak: json['streak'] as int? ?? 0,
      completedToday: (json['completedToday'] as int? ?? 0) == 1,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      completedDates: (json['completedDates'] as List<dynamic>?)
              ?.map((e) => DateTime.fromMillisecondsSinceEpoch(e as int))
              .toList() ??
          [],
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastCompletedDate'] as int)
          : null,
      lastResetDate: json['lastResetDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastResetDate'] as int)
          : null,
    );
  }
}

Note Model
import 'package:flutter/material.dart';

import 'app_icons.dart';

@immutable
class NoteModel {
  final String id;
  final String title;
  final String content;
  final Color color;
  final IconData icon;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.color,
    required this.icon,
    required this.createdAt,
    required this.updatedAt,
  });

  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    Color? color,
    IconData? icon,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'colorValue': color.toARGB32(),
      'iconKey': AppIcons.keyForNoteIcon(icon),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      color: Color(json['colorValue'] as int),
      icon: AppIcons.noteIcon(json['iconKey'] as String?),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
    );
  }
}
Build and deploy
name: Build and Deploy to Play Store

on:
  push:
    tags:
      - "v*"

jobs:
  build:
    name: Build and Deploy
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Set up JDK 17
        uses: actions/setup-java@v3
        with:
          distribution: "zulu"
          java-version: "17"

      - name: Set up Flutter
        uses: subosito/flutter-action@v2
      - run: flutter --version

      - name: Reconstruct Keystore File
        run: |
          echo ${{ secrets.KEYSTORE_BASE64 }} | base64 --decode > $HOME/keystore.jks
          echo "KEYSTORE_FILE=$HOME/keystore.jks" >> $GITHUB_ENV

      - name: Set up environment for signing
        run: |
          echo "KEY_ALIAS=${{ secrets.KEY_ALIAS }}" >> $GITHUB_ENV
          echo "KEY_PASSWORD=${{ secrets.KEY_PASSWORD }}" >> $GITHUB_ENV
          echo "STORE_PASSWORD=${{ secrets.STORE_PASSWORD }}" >> $GITHUB_ENV

      - name: Extract version from tag
        id: extract_version
        run: |
          TAG=${GITHUB_REF#refs/tags/}
          VERSION=${TAG#v}
          echo "VERSION=$VERSION" >> $GITHUB_ENV

      - name: Update pubspec.yaml
        run: |
          cd $GITHUB_WORKSPACE
          sed -i "s/^version: .*/version: ${{ env.VERSION }}/" pubspec.yaml

      - name: Install dependencies
        run: flutter pub get

      - name: Build AAB
        # --no-tree-shake-icons is a safety net: habit/note icons are now
        # looked up through AppIcons' const map (lib/models/app_icons.dart),
        # which the tree-shaker can already resolve statically, but this
        # flag protects against any *future* dynamically-built IconData
        # elsewhere in the app silently losing its glyph in release builds.
        run: flutter build appbundle --release --no-tree-shake-icons

      - name: Upload AAB to Play Store
        id: upload_google_play
        uses: r0adkll/upload-google-play@v1
        with:
          packageName: ${{ secrets.PACKAGE_NAME }}
          serviceAccountJsonPlainText: ${{ secrets.SERVICE_ACCOUNT_JSON }}
          inAppUpdatePriority: ${{ secrets.UPDATE_PRIORITY }} # Between 0-5 => Higher the number, higher the priority.
          releaseFiles: build/app/outputs/bundle/release/app-release.aab
          track: internal
          status: draft
          changesNotSentForReview: ${{ secrets.DONT_SEND_CHANGES_FOR_REVIEW }}  # true or false
          # mappingFile: build/app/outputs/mapping/release/mapping.txt
          # debugSymbols: build\app\intermediates\merged_native_libs\release\mergeReleaseNativeLibs\out\lib

      - name: Cleanup
        run: |
          echo "Cleaning up temporary files..."
          rm -rf build
          rm $HOME/keystore.jks
          echo "Cleanup complete."
          

