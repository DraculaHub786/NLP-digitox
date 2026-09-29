// Copyright (c) 2026 NLP digitox
//
// EvalResultsWriter — collects every suite's Scorecard, prints them so a plain
// `flutter test` run shows the numbers, and persists a markdown + JSON report
// under test/nlp_eval/results/ for the CI job and for human review.
//
// The JSON form is the machine-readable contract: the markdown is for reading,
// the JSON is for tracking a metric over time.

import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'scorecard.dart';

/// Where the evaluation report is written, relative to the package root.
const String kResultsDirectory = 'test/nlp_eval/results';

/// Collects scorecards from all suites and writes them out.
class EvalResultsWriter {
  EvalResultsWriter({Directory? outputDirectory})
      : outputDirectory = outputDirectory ?? Directory(kResultsDirectory);

  final Directory outputDirectory;
  final List<Scorecard> _scorecards = [];
  final Map<String, dynamic> _environment = {};

  List<Scorecard> get scorecards => List.unmodifiable(_scorecards);

  void add(Scorecard card) => _scorecards.add(card);

  /// Record run-level facts (model name, dataset sizes, Flutter version).
  void recordEnvironment(Map<String, dynamic> info) => _environment.addAll(info);

  Scorecard? bySuiteName(String suite) {
    for (final card in _scorecards) {
      if (card.suite == suite) return card;
    }
    return null;
  }

  /// Print every scorecard, then a one-line summary, to stdout.
  ///
  /// Uses `print` deliberately: a test suite's whole purpose here is to publish
  /// its numbers, and `flutter test` only surfaces stdout.
  void printToConsole() {
    for (final card in _scorecards) {
      // ignore: avoid_print
      print(card.toConsole());
    }
    // ignore: avoid_print
    print(summaryTable());
  }

  /// Compact table of the headline numbers from every suite, so the overall
  /// picture is readable without scrolling through the per-suite blocks.
  String summaryTable() {
    final buffer = StringBuffer();
    buffer.writeln();
    buffer.writeln('=' * 78);
    buffer.writeln('NLP / AI EVALUATION SUMMARY');
    buffer.writeln('=' * 78);

    for (final entry in _environment.entries) {
      buffer.writeln('  ${entry.key.padRight(24)}${entry.value}');
    }
    buffer.writeln();

    for (final card in _scorecards) {
      buffer.writeln('  ${card.suite}');
      final headline = card.metadata['headline'];
      if (headline is Map) {
        headline.forEach((key, value) {
          final rendered = value is num
              ? value.toDouble().toStringAsFixed(4)
              : value.toString();
          buffer.writeln('      ${key.toString().padRight(34)}$rendered');
        });
      }
      if (card.sections.any((s) => s.title.contains('Confusion matrix'))) {
        buffer.writeln('      (confusion matrix in the full report below)');
      }
      buffer.writeln();
    }
    return buffer.toString();
  }

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# NLP / AI evaluation report');
    buffer.writeln();
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln();
    if (_environment.isNotEmpty) {
      buffer.writeln('## Run environment');
      buffer.writeln();
      for (final entry in _environment.entries) {
        buffer.writeln('- **${entry.key}**: ${entry.value}');
      }
      buffer.writeln();
    }

    buffer.writeln('## Summary');
    buffer.writeln();
    buffer.writeln('| suite | headline metric | value |');
    buffer.writeln('| --- | --- | ---: |');
    for (final card in _scorecards) {
      final headline = card.metadata['headline'];
      if (headline is Map && headline.isNotEmpty) {
        var first = true;
        headline.forEach((key, value) {
          final rendered = value is num
              ? value.toDouble().toStringAsFixed(4)
              : value.toString();
          buffer.writeln(
            '| ${first ? card.suite : ''} | $key | $rendered |',
          );
          first = false;
        });
      } else {
        buffer.writeln('| ${card.suite} | — | — |');
      }
    }
    buffer.writeln();

    buffer.writeln('## Full scorecards');
    buffer.writeln();
    for (final card in _scorecards) {
      buffer.writeln(card.toMarkdown());
      buffer.writeln();
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'generatedAt': DateTime.now().toIso8601String(),
        'environment': _environment,
        'scorecards': _scorecards.map((c) => c.toJson()).toList(),
      };

  /// Write the markdown and JSON reports, creating the directory if needed.
  Future<void> writeFiles() async {
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }
    await File(p.join(outputDirectory.path, 'nlp_eval_report.md'))
        .writeAsString(toMarkdown());
    await File(p.join(outputDirectory.path, 'nlp_eval_report.json'))
        .writeAsString(
      const JsonEncoder.withIndent('  ').convert(toJson()),
    );
  }
}
