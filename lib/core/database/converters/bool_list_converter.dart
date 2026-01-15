// Based on code from Mindful by Pawan Nagar (https://github.com/akaMrNagar/Mindful)

import 'package:drift/drift.dart';
import 'dart:convert';

class BoolListConverter extends TypeConverter<List<bool>, String> {
  const BoolListConverter();

  @override
  List<bool> fromSql(String fromDb) {
    List<dynamic> jsonList = json.decode(fromDb);
    return jsonList.map((item) => item as bool).toList();
  }

  @override
  String toSql(List<bool> value) {
    return json.encode(value);
  }
}