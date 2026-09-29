// Copyright (c) 2026 NLP digitox
//
// Evaluation primitives for the NLP/AI components.
//
// Everything here is deliberately multi-label: the topic classifier can tag a
// single message with several topics, and the sentiment labeller predicts one
// dominant label. Treating a single-label prediction as a one-element label set
// lets both be scored by the same code path and keeps the numbers comparable.

import 'dart:math' as math;

/// Per-label precision / recall / F1 with the raw counts behind them.
class PerLabelScore {
  const PerLabelScore({
    required this.label,
    required this.truePositives,
    required this.falsePositives,
    required this.falseNegatives,
    required this.support,
  });

  final String label;
  final int truePositives;
  final int falsePositives;
  final int falseNegatives;

  /// Number of gold examples that carry this label.
  final int support;

  double get precision => truePositives + falsePositives == 0
      ? 0
      : truePositives / (truePositives + falsePositives);

  double get recall => truePositives + falseNegatives == 0
      ? 0
      : truePositives / (truePositives + falseNegatives);

  double get f1 => precision + recall == 0
      ? 0
      : 2 * precision * recall / (precision + recall);

  @override
  String toString() =>
      '$label: P=${precision.toStringAsFixed(3)} '
      'R=${recall.toStringAsFixed(3)} F1=${f1.toStringAsFixed(3)} '
      '(tp=$truePositives fp=$falsePositives fn=$falseNegatives n=$support)';
}

/// Aggregate scores over a labelled set.
class EvalReport {
  const EvalReport({
    required this.perLabel,
    required this.exactMatches,
    required this.total,
  });

  final List<PerLabelScore> perLabel;

  /// Examples whose predicted label set exactly equals the gold set.
  final int exactMatches;
  final int total;

  /// Fraction of examples where gold == predicted (subset accuracy).
  double get subsetAccuracy => total == 0 ? 0 : exactMatches / total;

  /// Micro averages pool every tp/fp/fn across labels, so frequent labels
  /// dominate. Use this as the headline when label frequency is skewed.
  double get microPrecision => _micro(
        (s) => s.truePositives,
        (s) => s.truePositives + s.falsePositives,
      );

  double get microRecall => _micro(
        (s) => s.truePositives,
        (s) => s.truePositives + s.falseNegatives,
      );

  double get microF1 => _f1(microPrecision, microRecall);

  /// Macro averages weight every label equally regardless of support — the
  /// number to quote when a rare label matters as much as a common one.
  double get macroPrecision => _macro((s) => s.precision);
  double get macroRecall => _macro((s) => s.recall);
  double get macroF1 => _macro((s) => s.f1);

  /// Support-weighted average, i.e. the score a random example is likely to see.
  double get weightedF1 {
    if (total == 0) return 0;
    final weighted = perLabel.fold(0.0, (sum, s) => sum + s.f1 * s.support);
    return weighted / total;
  }

  double _micro(
    int Function(PerLabelScore) numerator,
    int Function(PerLabelScore) denominator,
  ) {
    final num = perLabel.fold(0, (sum, s) => sum + numerator(s));
    final den = perLabel.fold(0, (sum, s) => sum + denominator(s));
    return den == 0 ? 0 : num / den;
  }

  double _macro(double Function(PerLabelScore) metric) {
    if (perLabel.isEmpty) return 0;
    final sum = perLabel.fold(0.0, (acc, s) => acc + metric(s));
    return sum / perLabel.length;
  }

  static double _f1(double precision, double recall) => precision + recall == 0
      ? 0
      : 2 * precision * recall / (precision + recall);
}

/// A gold/predicted pair. Either side may carry several labels.
class LabelledExample {
  const LabelledExample({
    required this.input,
    required this.gold,
    required this.predicted,
  });

  final String input;
  final Set<String> gold;
  final Set<String> predicted;
}

/// Score [examples], reporting a row for every label in [labels].
///
/// [labels] must be passed explicitly so a label that is never predicted still
/// shows up with a recall of zero — silently dropping it would overstate the
/// macro average.
EvalReport evaluate(
  List<LabelledExample> examples,
  List<String> labels,
) {
  final scores = <PerLabelScore>[];

  for (final label in labels) {
    var tp = 0, fp = 0, fn = 0, support = 0;
    for (final example in examples) {
      final inGold = example.gold.contains(label);
      final inPred = example.predicted.contains(label);
      if (inGold) support++;
      if (inGold && inPred) {
        tp++;
      } else if (!inGold && inPred) {
        fp++;
      } else if (inGold && !inPred) {
        fn++;
      }
    }
    scores.add(
      PerLabelScore(
        label: label,
        truePositives: tp,
        falsePositives: fp,
        falseNegatives: fn,
        support: support,
      ),
    );
  }

  final exact = examples
      .where(
        (e) => e.gold.length == e.predicted.length && e.gold.containsAll(e.predicted),
      )
      .length;

  return EvalReport(
    perLabel: scores,
    exactMatches: exact,
    total: examples.length,
  );
}

/// Gold -> predicted misclassification counts, for printing a readable
/// confusion table. Only meaningful for single-label tasks.
Map<String, Map<String, int>> confusionMatrix(
  List<LabelledExample> examples,
  List<String> labels,
) {
  final matrix = <String, Map<String, int>>{
    for (final gold in labels) gold: {for (final pred in labels) pred: 0},
  };
  for (final example in examples) {
    if (example.gold.length != 1 || example.predicted.length != 1) continue;
    final gold = example.gold.first;
    final pred = example.predicted.first;
    if (gold == pred) continue;
    final row = matrix[gold];
    if (row != null && row.containsKey(pred)) {
      row[pred] = row[pred]! + 1;
    }
  }
  return matrix;
}

/// Full gold x predicted confusion matrix over [labels], including the
/// diagonal.
///
/// [confusionMatrix] above deliberately omits correct predictions because it
/// exists to enumerate mistakes; this type keeps them so accuracy and
/// per-class recall are recoverable from the same object the table is
/// rendered from.
class ConfusionMatrix {
  const ConfusionMatrix({
    required this.labels,
    required this.counts,
    required this.total,
    required this.correct,
  });

  final List<String> labels;

  /// `counts[gold][predicted]` — every cell present, zero when unobserved.
  final Map<String, Map<String, int>> counts;

  /// Examples that produced a square in the matrix (single-label on both
  /// sides). Multi-label examples are skipped, exactly as in
  /// [confusionMatrix].
  final int total;

  /// Examples where gold == predicted.
  final int correct;

  /// Fraction of scored examples the model labelled correctly.
  double get accuracy => total == 0 ? 0 : correct / total;

  /// Confusion table. When [normalized] is set each row sums to 1.0, i.e. the
  /// cells read as per-class recall rather than raw counts.
  String render({bool normalized = false, int labelWidth = 13}) {
    final buffer = StringBuffer();
    final header = StringBuffer(' '.padRight(labelWidth));
    for (final label in labels) {
      header.write(label.padLeft(9));
    }
    buffer.writeln('${header.toString()}  (rows = gold, cols = predicted)');

    for (final gold in labels) {
      final buffer2 = StringBuffer(gold.padRight(labelWidth));
      final row = counts[gold] ?? const <String, int>{};
      final rowTotal = row.values.fold(0, (sum, value) => sum + value);
      for (final predicted in labels) {
        final value = row[predicted] ?? 0;
        final cell = normalized && rowTotal > 0
            ? (value / rowTotal).toStringAsFixed(2)
            : value.toString();
        buffer2.write(cell.padLeft(9));
      }
      buffer.writeln(buffer2.toString());
    }
    return buffer.toString();
  }
}

/// Build a full confusion matrix over [examples].
///
/// Only single-label examples contribute, mirroring [confusionMatrix]: a
/// multi-label row has no single square to sit in. Predictions outside
/// [labels] are ignored rather than crashing, so an unexpected classifier
/// output shows up as a missing cell instead of a test error.
ConfusionMatrix buildConfusionMatrix(
  List<LabelledExample> examples,
  List<String> labels,
) {
  final counts = <String, Map<String, int>>{
    for (final gold in labels) gold: {for (final pred in labels) pred: 0},
  };

  var total = 0;
  var correct = 0;
  for (final example in examples) {
    if (example.gold.length != 1 || example.predicted.length != 1) continue;
    final gold = example.gold.first;
    final predicted = example.predicted.first;
    if (!counts.containsKey(gold)) continue;
    if (!counts[gold]!.containsKey(predicted)) continue;
    counts[gold]![predicted] = counts[gold]![predicted]! + 1;
    total++;
    if (gold == predicted) correct++;
  }

  return ConfusionMatrix(
    labels: labels,
    counts: counts,
    total: total,
    correct: correct,
  );
}

/// Mean absolute error between two label->value maps over [labels].
///
/// Missing keys count as zero on both sides, so a model that omits a label is
/// charged the full distance rather than being silently excused.
double meanAbsoluteError(
  Map<String, double> predicted,
  Map<String, double> gold,
  List<String> labels,
) {
  if (labels.isEmpty) return 0;
  var sum = 0.0;
  for (final label in labels) {
    sum += ((predicted[label] ?? 0) - (gold[label] ?? 0)).abs();
  }
  return sum / labels.length;
}

/// Root-mean-square error between two label->value maps over [labels].
double rootMeanSquareError(
  Map<String, double> predicted,
  Map<String, double> gold,
  List<String> labels,
) {
  if (labels.isEmpty) return 0;
  var sum = 0.0;
  for (final label in labels) {
    final difference = (predicted[label] ?? 0) - (gold[label] ?? 0);
    sum += difference * difference;
  }
  return math.sqrt(sum / labels.length);
}

/// Cosine similarity between two label->value maps over [labels]; 1.0 means
/// the vectors point the same way regardless of magnitude, so it measures
/// whether the model ranked the five labels the same way as the gold answer.
double cosineSimilarity(
  Map<String, double> predicted,
  Map<String, double> gold,
  List<String> labels,
) {
  var dot = 0.0, predictedNorm = 0.0, goldNorm = 0.0;
  for (final label in labels) {
    final p = predicted[label] ?? 0;
    final g = gold[label] ?? 0;
    dot += p * g;
    predictedNorm += p * p;
    goldNorm += g * g;
  }
  if (predictedNorm == 0 || goldNorm == 0) return 0;
  return dot / (math.sqrt(predictedNorm) * math.sqrt(goldNorm));
}

/// The label with the highest value, or null for an empty map.
///
/// Ties resolve to the label that comes first in [labels], which keeps the
/// result deterministic — important when a rule-based scorer emits exactly
/// equal percentages.
String? argMax(Map<String, double> values, List<String> labels) {
  String? best;
  var bestValue = double.negativeInfinity;
  for (final label in labels) {
    final value = values[label];
    if (value == null) continue;
    if (value > bestValue) {
      bestValue = value;
      best = label;
    }
  }
  return best;
}
