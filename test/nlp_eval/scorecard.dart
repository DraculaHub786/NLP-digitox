// Copyright (c) 2026 NLP digitox
//
// Scorecard — the reporting layer for the NLP evaluation suites.
//
// Each suite records the numbers it produced here, and the same object then
// renders itself three ways: a human-readable console/markdown scorecard, a
// per-label breakdown table, and machine-readable JSON. Keeping the rendering
// in one place means every suite reports the same set of metrics, so the
// numbers stay comparable across components.

import 'metrics.dart';

/// A single named number on a scorecard.
class MetricEntry {
  const MetricEntry(
    this.name,
    this.value, {
    this.unit = 'pct',
    this.note = '',
  });

  final String name;

  /// The metric value. Null means "not applicable / could not be computed",
  /// which renders as `n/a` rather than a misleading zero.
  final double? value;

  /// How to render [value]: `pct`, `count`, `raw`, or `ms`.
  final String unit;

  final String note;

  String get formatted {
    if (value == null) return 'n/a';
    switch (unit) {
      case 'count':
        return value!.toInt().toString();
      case 'ms':
        return '${value!.toStringAsFixed(0)} ms';
      case 'raw':
        return value!.toStringAsFixed(4);
      case 'pct':
      default:
        return '${(value! * 100).toStringAsFixed(2)}%';
    }
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'value': value,
        'unit': unit,
        'note': note,
      };
}

/// A titled block of pre-rendered text (a confusion matrix, a per-label
/// table) attached to a scorecard.
class ScorecardSection {
  const ScorecardSection(this.title, this.body);

  final String title;
  final String body;
}

/// Everything one evaluation suite measured.
class Scorecard {
  Scorecard({required this.suite, required this.description});

  /// Stable identifier, e.g. `topic_classification`.
  final String suite;

  /// One-line statement of what was measured and against what.
  final String description;

  final List<MetricEntry> metrics = [];
  final List<ScorecardSection> sections = [];
  final List<String> notes = [];
  final Map<String, dynamic> metadata = {};

  /// Record a percentage-style metric (0.0–1.0).
  void pct(String name, double value, {String note = ''}) =>
      metrics.add(MetricEntry(name, value, note: note));

  /// Record an integer count.
  void count(String name, int value, {String note = ''}) =>
      metrics.add(MetricEntry(name, value.toDouble(), unit: 'count', note: note));

  /// Record a dimensionless number (errors, ratios, similarities).
  void raw(String name, double value, {String note = ''}) =>
      metrics.add(MetricEntry(name, value, unit: 'raw', note: note));

  /// Record a metric that could not be computed.
  void notAvailable(String name, {String note = ''}) =>
      metrics.add(MetricEntry(name, null, note: note));

  /// Record a millisecond duration.
  void milliseconds(String name, double value, {String note = ''}) =>
      metrics.add(MetricEntry(name, value, unit: 'ms', note: note));

  void note(String text) => notes.add(text);

  void section(String title, String body) =>
      sections.add(ScorecardSection(title, body));

  /// Attach the standard metric block for a multi-label [EvalReport], plus a
  /// per-label table, so every classification suite reports identical metrics.
  void addClassificationReport(EvalReport report, {String title = 'Per-label'}) {
    pct('Subset accuracy (exact match)', report.subsetAccuracy,
        note: '${report.exactMatches}/${report.total} examples');
    pct('Micro precision', report.microPrecision);
    pct('Micro recall', report.microRecall);
    pct('Micro F1', report.microF1);
    pct('Macro precision', report.macroPrecision);
    pct('Macro recall', report.macroRecall);
    pct('Macro F1', report.macroF1);
    pct('Weighted F1', report.weightedF1);
    count('Examples scored', report.total);

    final table = StringBuffer();
    table.writeln(
      '${'label'.padRight(14)}${'prec'.padLeft(9)}${'rec'.padLeft(9)}'
      '${'F1'.padLeft(9)}${'tp'.padLeft(7)}${'fp'.padLeft(7)}'
      '${'fn'.padLeft(7)}${'support'.padLeft(9)}',
    );
    for (final score in report.perLabel) {
      table.writeln(
        '${score.label.padRight(14)}'
        '${score.precision.toStringAsFixed(3).padLeft(9)}'
        '${score.recall.toStringAsFixed(3).padLeft(9)}'
        '${score.f1.toStringAsFixed(3).padLeft(9)}'
        '${score.truePositives.toString().padLeft(7)}'
        '${score.falsePositives.toString().padLeft(7)}'
        '${score.falseNegatives.toString().padLeft(7)}'
        '${score.support.toString().padLeft(9)}',
      );
    }
    section(title, table.toString());
  }

  /// Attach a confusion matrix under its own heading.
  void addConfusionMatrix(ConfusionMatrix matrix, {String title = 'Confusion matrix'}) {
    pct('Accuracy (single-label argmax)', matrix.accuracy,
        note: '${matrix.correct}/${matrix.total} examples');
    section('$title (counts)', matrix.render());
    section('$title (row-normalised)', matrix.render(normalized: true));
  }

  String toConsole() {
    final buffer = StringBuffer();
    buffer.writeln('=' * 78);
    buffer.writeln('NLP EVAL — $suite');
    buffer.writeln(description);
    buffer.writeln('=' * 78);
    for (final metric in metrics) {
      final suffix = metric.note.isEmpty ? '' : '   (${metric.note})';
      buffer.writeln('  ${metric.name.padRight(42)}${metric.formatted.padLeft(12)}$suffix');
    }
    for (final note in notes) {
      buffer.writeln('  • $note');
    }
    for (final section in sections) {
      buffer.writeln();
      buffer.writeln('[${section.title}]');
      buffer.write(section.body);
    }
    return buffer.toString();
  }

  String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('### $suite');
    buffer.writeln();
    buffer.writeln(description);
    buffer.writeln();
    buffer.writeln('| metric | value | note |');
    buffer.writeln('| --- | ---: | --- |');
    for (final metric in metrics) {
      buffer.writeln('| ${metric.name} | ${metric.formatted} | ${metric.note} |');
    }
    for (final note in notes) {
      buffer.writeln();
      buffer.writeln('> $note');
    }
    for (final section in sections) {
      buffer.writeln();
      buffer.writeln('**${section.title}**');
      buffer.writeln();
      buffer.writeln('```');
      buffer.write(section.body);
      buffer.writeln('```');
    }
    return buffer.toString();
  }

  Map<String, dynamic> toJson() => {
        'suite': suite,
        'description': description,
        'metrics': metrics.map((m) => m.toJson()).toList(),
        'notes': notes,
        'sections': [
          for (final section in sections)
            {'title': section.title, 'body': section.body},
        ],
        'metadata': metadata,
      };
}
