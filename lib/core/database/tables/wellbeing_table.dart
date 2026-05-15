
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:nlp_digitox/core/database/converters/enum_list_converter.dart';
import 'package:nlp_digitox/core/database/converters/string_list_converter.dart';
import 'package:nlp_digitox/core/enums/platform_features.dart';

@DataClassName("Wellbeing")
class WellbeingTable extends Table {
  /// Unique ID for wellbeing
  IntColumn get id => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>>? get primaryKey => {id};

  /// Allowed time for short content in SECONDS
  IntColumn get allowedShortsTimeSec =>
      integer().withDefault(const Constant(7 * 60 * 60))(); // 7 hours default

  /// List of feature which are blocked
  TextColumn get blockedFeatures => text()
      .map(const EnumListConverter<PlatformFeatures>(PlatformFeatures.values))
      .withDefault(Constant(jsonEncode([])))();

  /// Flag denoting if the nsfw or adult  websites are blocked or not
  /// i.e if accessibility service is filtering websites or not
  BoolColumn get blockNsfwSites =>
      boolean().withDefault(const Constant(false))();

  /// List of website hosts which are blocked.
  TextColumn get blockedWebsites => text()
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();

  /// List of website hosts which are nsfw.
  TextColumn get nsfwWebsites => text()
      .map(const StringListConverter())
      .withDefault(Constant(jsonEncode([])))();
}
