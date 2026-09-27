import 'dart:io';

import 'package:sqlite3/sqlite3.dart' as raw;

/// Creates an on-disk SQLite database that looks exactly like what an older app
/// version left behind, then stamps `PRAGMA user_version` so drift runs the
/// matching upgrade steps the next time `AppDatabase` opens the file.
///
/// The DDL is not guessed: every column, its nullability and its default are
/// copied from the `Shape` classes in
/// `lib/core/database/schemas/schema_versions.dart`, which is the same source
/// drift uses to build the migrator for each step.
///
/// [version] must be 9 or 10:
///  * **10** contains `app_restriction_table` only (drift then runs 10 -> 11).
///  * **9** contains `app_restriction_table` (identical to v10 - it is the same
///    `Shape26` in both schemas) plus the pre-`dailyScreenTimeGoalSec`
///    `wellbeing_table` (`Shape19`), so drift runs 9 -> 10 and then 10 -> 11.
void createLegacyDatabase(File file, {required int version}) {
  if (version != 9 && version != 10) {
    throw ArgumentError.value(version, 'version', 'only schema 9 and 10 exist');
  }

  final database = raw.sqlite3.open(file.path);

  database.execute(_appRestrictionTableDdl);
  database.execute(_appRestrictionRowInsert);

  if (version <= 9) {
    // Schema 9's `wellbeing_table` (Shape19): no daily_screen_time_goal_sec.
    database.execute(_wellbeingTableV9Ddl);
    database.execute(_wellbeingRowInsert);
  }

  database.execute('PRAGMA user_version = $version');
  database.dispose();
}

/// `app_restriction_table` as of schema 9 and 10 (Shape26). Schema 9 and schema
/// 10 use the exact same column set, so one DDL covers both.
const String _appRestrictionTableDdl = '''
  CREATE TABLE app_restriction_table (
    app_package TEXT NOT NULL,
    timer_sec INTEGER NOT NULL DEFAULT 0,
    launch_limit INTEGER NOT NULL DEFAULT 0,
    active_period_start INTEGER NOT NULL DEFAULT 0,
    active_period_end INTEGER NOT NULL DEFAULT 0,
    period_duration_in_mins INTEGER NOT NULL DEFAULT 0,
    associated_group_id INTEGER NULL DEFAULT NULL,
    can_access_internet INTEGER NOT NULL DEFAULT 1
      CHECK (can_access_internet IN (0, 1)),
    reminder_type TEXT NOT NULL DEFAULT 'toast',
    PRIMARY KEY (app_package)
  )
''';

const String _appRestrictionRowInsert =
    'INSERT INTO app_restriction_table (app_package, timer_sec, launch_limit) '
    "VALUES ('com.example.legacy', 300, 2)";

/// Schema 9's `wellbeing_table` (Shape19): `id` 0, `allowed_shorts_time_sec`
/// 1800 (30 min in v9), the three text columns `'[]'` and `block_nsfw_sites` 0.
const String _wellbeingTableV9Ddl = '''
  CREATE TABLE wellbeing_table (
    id INTEGER NOT NULL DEFAULT 0,
    allowed_shorts_time_sec INTEGER NOT NULL DEFAULT 1800,
    blocked_features TEXT NOT NULL DEFAULT '[]',
    block_nsfw_sites INTEGER NOT NULL DEFAULT 0
      CHECK (block_nsfw_sites IN (0, 1)),
    blocked_websites TEXT NOT NULL DEFAULT '[]',
    nsfw_websites TEXT NOT NULL DEFAULT '[]',
    PRIMARY KEY (id)
  )
''';

const String _wellbeingRowInsert =
    'INSERT INTO wellbeing_table (id) VALUES (0)';

/// The v9 default of `allowed_shorts_time_sec` (30 minutes, in seconds).
const int legacyAllowedShortsTimeSec = 30 * 60;

/// The default `from9To10` must give the newly added
/// `daily_screen_time_goal_sec` column (4 hours, in seconds).
const int dailyScreenTimeGoalSecDefault = 4 * 60 * 60;
