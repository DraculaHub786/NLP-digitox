import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

/// Get the SQLITE database file path: /data/user/0/com.nlp.digitox/app_flutter/NLP_digitox.sqlite
Future<String> getSqliteDbPath() async => path.join(
      (await getApplicationDocumentsDirectory()).path,
      'NLP_digitox.sqlite',
    );

/// Invoke the method in the [try/catch] block and print the error if it occurred
Future<void> runSafe(String tag, Future<void> Function() method) async {
  try {
    await method();
  } catch (e) {
    debugPrint("Error Occurred [$tag] : ${e.toString()}");
  }
}
