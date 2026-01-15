// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:flutter/material.dart';
import 'package:nlp_digitox/core/enums/usage_type.dart';
import 'package:nlp_digitox/core/extensions/ext_date_time.dart';
import 'package:nlp_digitox/core/utils/date_time_utils.dart';

/// Filtering model to filter apps based on different filtering parameters.
@immutable
class UsageFilterModel {
  /// Search query to filter apps by name
  final String query;

  /// Flag indicating if to reverse the resulted list
  final bool reverse;

  /// Flag indicating if to include app with no usage or not
  final bool includeAll;

  /// Usage type used for filtering and sorting
  final UsageType usageType;

  /// The selected day [DateTime] with time values stripped out
  final DateTime selectedDay;

  /// The selected week in the statistics tab
  final DateTimeRange selectedWeek;

  const UsageFilterModel({
    this.query = "",
    this.reverse = false,
    this.includeAll = true,
    this.usageType = UsageType.screenUsage,
    required this.selectedDay,
    required this.selectedWeek,
  });

  /// Create constant filter with Today as selected day and current week as week range
  ///
  /// Along with setting include all to TRUE
  static UsageFilterModel constant({bool includeAll = true}) =>
      UsageFilterModel(
        selectedDay: dateToday,
        includeAll: includeAll,
        selectedWeek: dateToday.weekRange,
      );

  UsageFilterModel copyWith({
    String? query,
    bool? reverse,
    bool? includeAll,
    UsageType? usageType,
    DateTime? selectedDay,
    DateTimeRange? selectedWeek,
  }) {
    return UsageFilterModel(
      query: query ?? this.query,
      reverse: reverse ?? this.reverse,
      includeAll: includeAll ?? this.includeAll,
      usageType: usageType ?? this.usageType,
      selectedDay: selectedDay ?? this.selectedDay,
      selectedWeek: selectedWeek ?? this.selectedWeek,
    );
  }
}
