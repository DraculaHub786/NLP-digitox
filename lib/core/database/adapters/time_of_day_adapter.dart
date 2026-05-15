
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimeOfDayAdapter extends TimeOfDay {
  TimeOfDayAdapter.now() : super.now();

  TimeOfDayAdapter.fromDateTime(super.time) : super.fromDateTime();

  const TimeOfDayAdapter.zero() : super(hour: 0, minute: 0);

  const TimeOfDayAdapter({
    required super.hour,
    required super.minute,
  });

  const TimeOfDayAdapter.fromMinutes(int totalMinutes)
      : super(
          hour: totalMinutes ~/ 60,
          minute: totalMinutes % 60,
        );

  /// Converts the [TimeOfDay] from hour and minutes to minutes only
  int get toMinutes => (hour * 60) + minute;

  /// Returns the difference in Duration
  /// i.e, DURATION = END.difference(START)
  Duration difference(TimeOfDayAdapter other) {
    int end = toMinutes;
    int start = other.toMinutes;

    return ((end < start) ? ((24 * 60) - start) + end : end - start).minutes;
  }
}

class TimeOfDayAdapterConverter extends TypeConverter<TimeOfDayAdapter, int>
    with JsonTypeConverter2 {
  const TimeOfDayAdapterConverter();

  @override
  TimeOfDayAdapter fromSql(int fromDb) => TimeOfDayAdapter.fromMinutes(fromDb);

  @override
  int toSql(TimeOfDayAdapter value) {
    return value.toMinutes;
  }

  @override
  TimeOfDayAdapter fromJson(json) => TimeOfDayAdapter.fromMinutes(json as int);

  @override
  toJson(TimeOfDayAdapter value) => value.toMinutes;
}
