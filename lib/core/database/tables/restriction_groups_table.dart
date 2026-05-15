
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/adapters/time_of_day_adapter.dart';
import 'package:nlp_digitox/core/database/converters/string_list_converter.dart';

@DataClassName("RestrictionGroup")
class RestrictionGroupsTable extends Table {
  /// Unique ID for each restriction group
  IntColumn get id => integer().autoIncrement()();

  /// Name of the group
  TextColumn get groupName => text().withDefault(const Constant("Social"))();

  /// The timer set for the group in SECONDS
  IntColumn get timerSec => integer().withDefault(const Constant(0))();

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

  /// List of app's packages which are associated with the group.
  TextColumn get distractingApps => text()
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();
}
