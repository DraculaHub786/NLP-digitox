import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/database/app_database.dart';

import 'support/legacy_database_fixture.dart';

/// Exercises the hand-written upgrade steps in `lib/core/database/migrations`.
///
/// Each step runs inside `runSafe`, which swallows every exception, so a step
/// that throws is indistinguishable from a step that succeeded. The only way to
/// notice is to open a real database file whose `user_version` is old, let
/// `AppDatabase` run the upgrade, and then read the migrated tables back:
/// a step that silently failed leaves the new column missing, so the first
/// read or write of it throws instead of returning a value.
void main() {
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('digitox_schema_upgrade');
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  File databaseFile() =>
      File('${tempDir.path}${Platform.pathSeparator}digitox.sqlite');

  group('from10To11', () {
    test('adds associatedDomains and keeps the existing row readable',
        () async {
      final file = databaseFile();
      createLegacyDatabase(file, version: 10);

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final rows = await db.select(db.appRestrictionTable).get();

      expect(rows, hasLength(1), reason: 'the v10 row must survive');
      expect(rows.single.appPackage, 'com.example.legacy');
      expect(
        rows.single.associatedDomains,
        isEmpty,
        reason: 'the added column must fall back to its empty-list default',
      );

      // A silently failed ADD COLUMN would make this write - and the read after
      // it - throw, instead of round-tripping the value.
      await (db.update(db.appRestrictionTable)
            ..where((t) => t.appPackage.equals('com.example.legacy')))
          .write(
        const AppRestrictionTableCompanion(
          associatedDomains: Value(['example.com']),
        ),
      );

      final updated = await db.select(db.appRestrictionTable).getSingle();
      expect(updated.associatedDomains, ['example.com']);
    });
  });

  group('from9To10', () {
    test('adds dailyScreenTimeGoalSec with its default', () async {
      final file = databaseFile();
      createLegacyDatabase(file, version: 9);

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final wellbeing = await db.select(db.wellbeingTable).getSingle();

      expect(wellbeing.dailyScreenTimeGoalSec, dailyScreenTimeGoalSecDefault);
    });

    test('leaves the values already stored in the v9 row untouched', () async {
      final file = databaseFile();
      createLegacyDatabase(file, version: 9);

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      final wellbeing = await db.select(db.wellbeingTable).getSingle();

      expect(
        wellbeing.allowedShortsTimeSec,
        legacyAllowedShortsTimeSec,
        reason: 'the upgrade must not rewrite existing data',
      );
    });

    test('runs 10 -> 11 afterwards, so both new columns end up usable',
        () async {
      final file = databaseFile();
      createLegacyDatabase(file, version: 9);

      final db = AppDatabase(NativeDatabase(file));
      addTearDown(db.close);

      // `user_version` finishes at 11, so the 9 -> 10 step failing silently
      // would leave `wellbeing_table` without `daily_screen_time_goal_sec` and
      // the first select below would throw.
      await db.select(db.wellbeingTable).getSingle();
      final appRows = await db.select(db.appRestrictionTable).get();

      expect(appRows.single.associatedDomains, isEmpty);
    });
  });
}
