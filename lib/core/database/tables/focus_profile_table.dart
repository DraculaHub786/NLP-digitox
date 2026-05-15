
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/converters/string_list_converter.dart';
import 'package:nlp_digitox/core/enums/session_type.dart';

@DataClassName("FocusProfile")
class FocusProfileTable extends Table {
  /// Selected session type
  IntColumn get sessionType => intEnum<SessionType>()();

  @override
  Set<Column<Object>>? get primaryKey => {sessionType};

  /// Duration in SECONDS for the focus session
  IntColumn get sessionDuration => integer().withDefault(const Constant(0))();

  /// Flag indicating if to enforce the session or not.
  /// If 'True' user cannot end session until the time ends.
  BoolColumn get enforceSession =>
      boolean().withDefault(const Constant(false))();

  /// Flag indicating if to start DND during the focus session
  BoolColumn get shouldStartDnd =>
      boolean().withDefault(const Constant(false))();

  /// List of app's packages which are selected as distracting apps.
  TextColumn get distractingApps => text()
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();
}
