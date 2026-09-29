// ignore_for_file: file_names

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/schemas/schema_versions.dart';
import 'package:nlp_digitox/core/utils/db_utils.dart';

/// Adds the `associatedDomains` column to the app restriction table.
///
/// The column definition must come from the [Schema11] snapshot
/// (`schema.appRestrictionTable.associatedDomains`) and NOT from the live
/// `AppRestrictionTable().associatedDomains` getter: the live getters are the
/// drift DSL, which the generator replaces with real columns at build time, so
/// evaluating one at runtime throws "This method should not be called at
/// runtime". Because [runSafe] swallows every error, that failure was silent -
/// the migration reported success while the column was never added, and the
/// first read/write of `associatedDomains` afterwards failed.
Future<void> from10To11(Migrator m, Schema11 schema) async => await runSafe(
      "Migration(10 to 11)",
      () async {
        await m.addColumn(
          schema.appRestrictionTable,
          schema.appRestrictionTable.associatedDomains,
        );
      },
    );
