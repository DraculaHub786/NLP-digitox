
import 'package:drift/drift.dart';
import 'dart:convert';

import 'package:nlp_digitox/models/notification_schedule.dart';

class NotificationScheduleListConverter
    extends TypeConverter<List<NotificationSchedule>, String> {
  const NotificationScheduleListConverter();

  @override
  List<NotificationSchedule> fromSql(String fromDb) {
    List<dynamic> jsonList = json.decode(fromDb);
    return jsonList.map((e) => NotificationSchedule.fromMap(e)).toList();
  }

  @override
  String toSql(List<NotificationSchedule> value) =>
      jsonEncode(value.map((e) => e.toMap()).toList());
}
