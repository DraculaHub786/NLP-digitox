// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:drift/drift.dart';
import 'dart:convert';

class StringListConverter extends TypeConverter<List<String>, String> {
  const StringListConverter();

  @override
  List<String> fromSql(String fromDb) {
    List<dynamic> jsonList = json.decode(fromDb);
    return jsonList.map((item) => item as String).toList();
  }

  @override
  String toSql(List<String> value) {
    return json.encode(value.toSet().toList());
  }
}
