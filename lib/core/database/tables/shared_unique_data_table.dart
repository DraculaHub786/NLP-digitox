
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/converters/string_list_converter.dart';

@DataClassName("SharedUniqueData")
class SharedUniqueDataTable extends Table {
  /// Unique ID for Shared Data
  IntColumn get id => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  /// List of app's packages which are excluded from the aggregated usage statistics.
  TextColumn get excludedApps => text()
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();
}
