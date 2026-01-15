// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:drift/drift.dart';

import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/database/tables/bedtime_schedule_table.dart';
import 'package:nlp_digitox/core/database/tables/focus_mode_table.dart';
import 'package:nlp_digitox/core/database/tables/notification_settings_table.dart';
import 'package:nlp_digitox/core/database/tables/parental_controls_table.dart';
import 'package:nlp_digitox/core/database/tables/mindful_settings_table.dart';
import 'package:nlp_digitox/core/database/tables/shared_unique_data_table.dart';
import 'package:nlp_digitox/core/database/tables/wellbeing_table.dart';
import 'package:nlp_digitox/core/utils/default_models_utils.dart';

part 'unique_records_dao.g.dart';

@DriftAccessor(
  tables: [
    MindfulSettingsTable,
    ParentalControlsTable,
    BedtimeScheduleTable,
    FocusModeTable,
    WellbeingTable,
    SharedUniqueDataTable,
    NotificationSettingsTable,
  ],
)
class UniqueRecordsDao extends DatabaseAccessor<AppDatabase>
    with _$UniqueRecordsDaoMixin {
  UniqueRecordsDao(super.db);

  /// Saves a single [SharedUniqueData] object to the database.
  Future<void> saveSharedData(SharedUniqueData data) async =>
      into(sharedUniqueDataTable)
          .insert(data, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [SharedUniqueData] object
  /// from the database. If none exists, returns default instance.
  Future<SharedUniqueData> loadSharedData() async =>
      await select(sharedUniqueDataTable).getSingleOrNull() ??
      defaultSharedUniqueDataModel;

  /// Saves a single [MindfulSettings] object to the database.
  Future<void> saveMindfulSettings(MindfulSettings settings) async =>
      into(mindfulSettingsTable)
          .insert(settings, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [MindfulSettings] object
  /// from the database. If none exists, returns default instance.
  Future<MindfulSettings> loadMindfulSettings() async =>
      await select(mindfulSettingsTable).getSingleOrNull() ??
      defaultMindfulSettingsModel;

  /// Saves a single [ParentalControls] object to the database.
  Future<void> saveParentalControls(
    ParentalControls parentalControls,
  ) async =>
      into(parentalControlsTable)
          .insert(parentalControls, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [ParentalControls] object
  /// from the database. If none exists, returns default instance.
  Future<ParentalControls> loadParentalControls() async =>
      await select(parentalControlsTable).getSingleOrNull() ??
      defaultParentalControlsModel;

  /// Saves a single [BedtimeSchedule] object to the database.
  Future<void> saveBedtimeSchedule(BedtimeSchedule bedtimeSchedule) async =>
      into(bedtimeScheduleTable)
          .insert(bedtimeSchedule, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [BedtimeSchedule] object
  /// from the database. If none exists, returns default instance.
  Future<BedtimeSchedule> loadBedtimeSchedule() async =>
      await select(bedtimeScheduleTable).getSingleOrNull() ??
      defaultBedtimeScheduleModel;

  /// Saves a single [FocusMode] object to the database.
  Future<void> saveFocusModeSettings(FocusMode focusMode) async =>
      into(focusModeTable).insert(focusMode, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [FocusMode] object
  /// from the database. If none exists, returns default instance.
  Future<FocusMode> loadFocusModeSettings() async =>
      await select(focusModeTable).getSingleOrNull() ?? defaultFocusModeModel;

  /// Saves a single [Wellbeing] object to the database.
  Future<void> saveWellBeingSettings(Wellbeing wellbeing) async =>
      into(wellbeingTable).insert(wellbeing, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [Wellbeing] object
  /// from the database. If none exists, returns default instance.
  Future<Wellbeing> loadWellBeingSettings() async =>
      await select(wellbeingTable).getSingleOrNull() ?? defaultWellbeingModel;

  /// Saves a single [NotificationSettings] object to the database.
  Future<void> saveNotificationSettings(NotificationSettings settings) async =>
      into(notificationSettingsTable)
          .insert(settings, mode: InsertMode.insertOrReplace);

  /// Loads the first (and likely only) [NotificationSettings] object
  /// from the database. If none exists, returns default instance.
  Future<NotificationSettings> loadNotificationSettings() async =>
      await select(notificationSettingsTable).getSingleOrNull() ??
      defaultNotificationSettingsModel;
}
