import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/database/app_database.dart';

/// Covers the `associatedDomains` column added in schema 11 - the field that
/// drives dynamic, limit-triggered website blocking.
///
/// Only the in-memory read/write behaviour lives here; the upgrade path that
/// creates the column on existing installs is covered by
/// `schema_upgrade_test.dart`.
void main() {
  group('associatedDomains', () {
    test('defaults to an empty list when not set', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.into(db.appRestrictionTable).insert(
            const AppRestrictionTableCompanion(
              appPackage: Value('com.example.app'),
            ),
          );

      final row = await db.select(db.appRestrictionTable).getSingle();

      expect(row.associatedDomains, isEmpty);
    });

    test('round-trips a list of hosts through the database', () async {
      const domains = ['instagram.com', 'www.instagram.com'];

      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.into(db.appRestrictionTable).insert(
            const AppRestrictionTableCompanion(
              appPackage: Value('com.instagram.android'),
              associatedDomains: Value(domains),
            ),
          );

      final row = await (db.select(db.appRestrictionTable)
            ..where((t) => t.appPackage.equals('com.instagram.android')))
          .getSingle();

      expect(row.associatedDomains, domains);
    });

    test('replaces the stored set on update', () async {
      final db = AppDatabase(NativeDatabase.memory());
      addTearDown(db.close);

      await db.into(db.appRestrictionTable).insert(
            const AppRestrictionTableCompanion(
              appPackage: Value('com.instagram.android'),
              associatedDomains: Value(['instagram.com']),
            ),
          );

      await (db.update(db.appRestrictionTable)
            ..where((t) => t.appPackage.equals('com.instagram.android')))
          .write(
        const AppRestrictionTableCompanion(
          associatedDomains: Value(['facebook.com', 'fb.com']),
        ),
      );

      final row = await db.select(db.appRestrictionTable).getSingle();

      expect(row.associatedDomains, ['facebook.com', 'fb.com']);
    });
  });
}
