
import 'package:drift/drift.dart';

@DataClassName("CrashLog")
class CrashLogsTable extends Table {
  /// Unique ID for crash logs
  IntColumn get id => integer().autoIncrement()();

  /// Current version of Digitox app
  TextColumn get appVersion => text().withDefault(const Constant(""))();

  /// [DateTime] when the error was thrown
  DateTimeColumn get timeStamp =>
      dateTime().withDefault(Constant(DateTime(0)))();

  /// The error string
  TextColumn get error => text().withDefault(const Constant(""))();

  /// Stack trace when the error or exception was thrown
  TextColumn get stackTrace => text().withDefault(const Constant(""))();
}
