// ignore_for_file: file_names

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/schemas/schema_versions.dart';
import 'package:nlp_digitox/core/database/tables/wellbeing_table.dart';
import 'package:nlp_digitox/core/utils/db_utils.dart';

/// Adds the [dailyScreenTimeGoalSec] column to the wellbeing table.
/// Since the Schema9 snapshot doesn't know about this new column, we use the
/// live [Wellbeing] data class to construct the column definition, then cast
/// to the expected type.
Future<void> from9To10(Migrator m, Schema9 schema) async => await runSafe(
      "Migration(9 to 10)",
      () async {
        await m.addColumn(
          schema.wellbeingTable,
          WellbeingTable().dailyScreenTimeGoalSec as GeneratedColumn<Object>,
        );
      },
    );
