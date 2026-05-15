
import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/database/app_database.dart';
import 'package:nlp_digitox/core/enums/reminder_type.dart';

@DataClassName("AppRestriction")
class AppRestrictionTable extends Table {
  /// Package name of the related app
  TextColumn get appPackage => text()();

  @override
  Set<Column<Object>>? get primaryKey => {appPackage};

  /// The timer set for the app in SECONDS
  IntColumn get timerSec => integer().withDefault(const Constant(0))();

  /// The number of times user can launch this app
  IntColumn get launchLimit => integer().withDefault(const Constant(0))();

  /// [TimeOfDay] in minutes from where the active period will start.
  /// It is stored as total minutes.
  IntColumn get activePeriodStart => integer()
      .map(const TimeOfDayAdapterConverter())
      .withDefault(const Constant(0))();

  /// [TimeOfDay] in minutes when the active period will end
  /// It is stored as total minutes.
  IntColumn get activePeriodEnd => integer()
      .map(const TimeOfDayAdapterConverter())
      .withDefault(const Constant(0))();

  /// Total duration of active period from start to end in MINUTES
  IntColumn get periodDurationInMins =>
      integer().withDefault(const Constant(0))();

  /// ID of the [RestrictionGroup] this app is associated with or NULL
  IntColumn get associatedGroupId =>
      integer().nullable().withDefault(const Constant(null))();

  /// Flag denoting if this app can access internet or not
  BoolColumn get canAccessInternet =>
      boolean().withDefault(const Constant(true))();

  /// [ReminderType] Type of reminders to show when using timed app
  TextColumn get reminderType =>
      textEnum<ReminderType>().withDefault(Constant(ReminderType.toast.name))();
}
