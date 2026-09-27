// ignore_for_file: file_names

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/schemas/schema_versions.dart';
import 'package:nlp_digitox/core/utils/db_utils.dart';

/// Adds the `dailyScreenTimeGoalSec` column to the wellbeing table.
///
/// Same rule as [from10To11]: the column definition comes from the [Schema10]
/// snapshot (`schema.wellbeingTable.dailyScreenTimeGoalSec`) and never from the
/// live `WellbeingTable().dailyScreenTimeGoalSec` getter. The live getter is the
/// drift DSL, which the generator replaces with a real column at build time -
/// evaluating it at runtime throws "This method should not be called at
/// runtime", and because [runSafe] swallows the error the column would silently
/// never be added.
Future<void> from9To10(Migrator m, Schema10 schema) async => await runSafe(
      "Migration(9 to 10)",
      () async {
        await m.addColumn(
          schema.wellbeingTable,
          schema.wellbeingTable.dailyScreenTimeGoalSec,
        );
      },
    );
