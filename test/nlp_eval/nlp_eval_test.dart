// Copyright (c) 2026 NLP digitox
//
// The NLP / AI evaluation runner.
//
// Every suite here scores production code — the same functions the app calls —
// against the hand-labelled datasets in `datasets/`, then appends a Scorecard to
// a shared EvalResultsWriter. After the last suite the report is printed to
// stdout (so `flutter test` shows it) and written to
// `test/nlp_eval/results/nlp_eval_report.{md,json}`.
//
// Five suites run offline and are fully deterministic:
//   1. topic_classification   — ChatContextExtractor keyword classifier
//   2. sentiment_parser       — AISentimentService.parseSentiment robustness
//   3. rule_sentiment         — AISentimentService.computeBaseSentiment
//   4. daily_score_parser     — DailySentimentScoringService.parseScoreResponse
//   5. agent_behaviour        — AIChatbotService prompt routing + title normaliser

import 'package:flutter_test/flutter_test.dart';
import 'package:nlp_digitox/core/services/ai_chatbot_service.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/core/services/daily_sentiment_scoring_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'datasets/agent_dataset.dart';
import 'datasets/rule_sentiment_dataset.dart';
import 'datasets/sentiment_parse_dataset.dart';
import 'datasets/topic_dataset.dart';
import 'metrics.dart';
import 'results_writer.dart';
import 'scorecard.dart';

/// Accumulates every suite's scorecard across the tests in this file.
late EvalResultsWriter writer;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues(<String, Object>{});

  setUpAll(() {
    writer = EvalResultsWriter();
    writer.recordEnvironment({
      'suite': 'NLP / AI evaluation',
      'dataset: topics': kTopicExamples.length,
      'dataset: sentiment parse replies': kSentimentParseCases.length,
      'dataset: rule scenarios': kRuleScenarios.length,
      'dataset: agent routing': kAgentRoutingCases.length,
      'dataset: agent titles': kTitleCases.length,
      'sentiment labels': kTopicLabels.length,
    });
  });

  tearDownAll(() async {
    writer.printToConsole();
    await writer.writeFiles();
  });

  // ═══════════════════════════════════════════════════════════════════
  // 1. Topic classification
  // ═══════════════════════════════════════════════════════════════════

  test('topic_classification', () {
    final examples = <LabelledExample>[
      for (final topicCase in kTopicExamples)
        LabelledExample(
          input: topicCase.message,
          gold: topicCase.gold,
          predicted: ChatContextExtractor.classifyTopics(topicCase.message),
        ),
    ];

    final report = evaluate(examples, kTopicLabels);
    final matrix = buildConfusionMatrix(examples, kTopicLabels);

    final card = Scorecard(
      suite: 'topic_classification',
      description:
          'ChatContextExtractor.classifyTopics (11-topic keyword classifier) '
          'scored against ${kTopicExamples.length} hand-labelled chat messages.',
    )..addClassificationReport(report);

    card.addConfusionMatrix(matrix);

    // Precision specifically on the examples whose gold set is empty. A keyword
    // classifier's characteristic failure is a false positive on a message that
    // is about nothing, so it is worth its own number.
    var negatives = 0;
    var cleanNegatives = 0;
    for (final topicCase in kTopicExamples) {
      if (topicCase.gold.isNotEmpty) continue;
      negatives++;
      final predicted = ChatContextExtractor.classifyTopics(topicCase.message);
      if (predicted.isEmpty) {
        cleanNegatives++;
      }
    }
    card.pct(
      'Empty-gold precision (no false positives)',
      negatives == 0 ? 0 : cleanNegatives / negatives,
      note: '$cleanNegatives/$negatives negative messages stayed empty',
    );

    var singleGold = 0;
    for (final topicCase in kTopicExamples) {
      if (topicCase.gold.length == 1) singleGold++;
    }
    var multiGold = 0;
    for (final topicCase in kTopicExamples) {
      if (topicCase.gold.length > 1) multiGold++;
    }

    card
      ..count('Single-topic messages', singleGold)
      ..count('Multi-topic messages', multiGold)
      ..count('Negative messages', negatives)
      ..count('Labels in the space', kTopicLabels.length)
      ..count('Topics in the keyword dictionary', ChatContextExtractor.topicKeywords.length)
      ..note(
        'The confusion matrix covers only the ${matrix.total} single-topic '
        'messages: a multi-topic example has no single gold class to sit in, so '
        'it is scored in the micro/macro F1 block above but omitted from the '
        'matrix. Accuracy above is therefore over single-topic cases only.',
      )
      ..note(
        'Micro F1 pools every tp/fp/fn, so the frequent topics dominate it. '
        'Macro F1 weights all eleven topics equally, which is the stricter '
        'number when a rare topic such as loneliness matters.',
      );

    card.metadata['headline'] = <String, dynamic>{
      'micro F1': report.microF1,
      'macro F1': report.macroF1,
      'weighted F1': report.weightedF1,
      'subset accuracy': report.subsetAccuracy,
      'single-label accuracy': matrix.accuracy,
      'false-positive-free negatives': negatives == 0 ? 0.0 : cleanNegatives / negatives,
    };

    writer.add(card);

    // Guards: the suite must not silently degrade into scoring nothing.
    //
    // buildConfusionMatrix admits an example only when BOTH the gold set and
    // the predicted set hold exactly one label — a multi-label row has no
    // single square to sit in. `singleGold` counts the gold side alone, so the
    // two totals diverge by exactly those single-topic messages the classifier
    // tagged with zero or several topics (i.e. its false positives and misses).
    // The matrix is therefore checked against the eligibility rule it actually
    // implements, and separately against being empty.
    var matrixEligible = 0;
    for (final topicCase in kTopicExamples) {
      if (topicCase.gold.length != 1) continue;
      final predicted = ChatContextExtractor.classifyTopics(topicCase.message);
      if (predicted.length == 1) matrixEligible++;
    }

    expect(report.total, kTopicExamples.length);
    expect(matrix.total, matrixEligible);
    expect(matrix.total, greaterThan(0));
    expect(report.microF1, greaterThan(0.5));
  });

  // ═══════════════════════════════════════════════════════════════════
  // 2. Sentiment response parser
  // ═══════════════════════════════════════════════════════════════════

  test('sentiment_parser', () {
    final service = AISentimentService.instance;

    final examples = <LabelledExample>[];
    final decisionTotal = <String, int>{};
    final decisionCorrect = <String, int>{};
    var decisionRight = 0;
    var normChecked = 0;
    var normOk = 0;

    for (final parseCase in kSentimentParseCases) {
      Set<String> predicted;
      var parsed = false;
      try {
        final result = service.parseSentiment(parseCase.raw);
        predicted = result.keys.toSet();
        parsed = true;

        final total = result.values.fold(0.0, (sum, value) => sum + value);
        normChecked++;
        if ((total - 100).abs() < 0.01) normOk++;
      } on FormatException {
        predicted = <String>{};
      }

      final shouldParse = parseCase.expectation == ParseExpectation.parses;
      if (parsed == shouldParse) {
        decisionRight++;
        decisionCorrect[parseCase.format] = (decisionCorrect[parseCase.format] ?? 0) + 1;
      }
      decisionTotal[parseCase.format] = (decisionTotal[parseCase.format] ?? 0) + 1;

      // Gold labels only count when the reply really does carry sentiment.
      examples.add(
        LabelledExample(
          input: parseCase.format,
          gold: shouldParse ? parseCase.expectedLabels : <String>{},
          predicted: predicted,
        ),
      );
    }

    const sentimentLabels = <String>[
      'Positive',
      'Neutral',
      'Negative',
      'Anxious',
      'Focused',
    ];
    final report = evaluate(examples, sentimentLabels);

    var parsesExpected = 0;
    for (final parseCase in kSentimentParseCases) {
      if (parseCase.expectation == ParseExpectation.parses) parsesExpected++;
    }

    final card = Scorecard(
      suite: 'sentiment_parser',
      description:
          'AISentimentService.parseSentiment scored against '
          '${kSentimentParseCases.length} raw model replies '
          '($parsesExpected of which carry usable sentiment).',
    );

    card
      ..pct(
        'Parse-decision accuracy',
        decisionRight / kSentimentParseCases.length,
        note: '$decisionRight/${kSentimentParseCases.length} replies handled correctly',
      )
      ..count('Replies that should parse', parsesExpected)
      ..count('Replies that should be rejected', kSentimentParseCases.length - parsesExpected);

    card.addClassificationReport(report, title: 'Per-label (parsed label sets)');

    card
      ..pct(
        'Normalisation correctness',
        normChecked == 0 ? 0 : normOk / normChecked,
        note: '$normOk/$normChecked successful parses summed to 100 (+/- 0.01)',
      )
      ..count('Successful parses', normChecked);

    // Per-format breakdown: which reply shapes the parser gets right.
    final perFormat = StringBuffer();
    perFormat.writeln(
      '${'format'.padRight(26)}${'correct'.padLeft(9)}${'total'.padLeft(8)}',
    );
    final formats = decisionTotal.keys.toList()..sort();
    for (final format in formats) {
      perFormat.writeln(
        '${format.padRight(26)}'
        '${(decisionCorrect[format] ?? 0).toString().padLeft(9)}'
        '${decisionTotal[format].toString().padLeft(8)}',
      );
    }
    card.section('Per reply format', perFormat.toString());

    card.note(
      'Per-label F1 here measures label recovery on replies that both should '
      'and do parse: a reply the parser wrongly rejects contributes false '
      'negatives for all five labels, so parse-decision accuracy is the more '
      'direct measure of parser health.',
    );

    card.metadata['headline'] = <String, dynamic>{
      'parse-decision accuracy': decisionRight / kSentimentParseCases.length,
      'label micro F1': report.microF1,
      'label macro F1': report.macroF1,
      'normalisation correctness': normChecked == 0 ? 0.0 : normOk / normChecked,
    };

    writer.add(card);

    expect(report.total, kSentimentParseCases.length);
    expect(decisionRight, greaterThan(kSentimentParseCases.length ~/ 2));
  });

  // ═══════════════════════════════════════════════════════════════════
  // 3. Rule-based sentiment scorer
  // ═══════════════════════════════════════════════════════════════════

  test('rule_sentiment', () {
    final service = AISentimentService.instance;

    const labels = <String>[
      'Positive',
      'Neutral',
      'Negative',
      'Anxious',
      'Focused',
    ];

    final examples = <LabelledExample>[];
    final predictedCounts = <String, int>{};
    var totalAbsoluteError = 0.0;

    for (final scenario in kRuleScenarios) {
      final distribution = service.computeBaseSentiment(
        screenTimeHours: scenario.screenHours,
        goalHours: scenario.goalHours,
        streakDays: scenario.streakDays,
        habitsCompleted: scenario.habitsCompleted,
        tasksCompleted: scenario.tasksCompleted,
      );

      final predictedLabel = argMax(distribution, labels);
      if (predictedLabel != null) {
        predictedCounts[predictedLabel] = (predictedCounts[predictedLabel] ?? 0) + 1;
      }

      // Distance from a perfectly neutral day, as a crude sanity signal that
      // the scorer is actually responsive to the inputs rather than flat.
      final spread = distribution.values.fold(0.0, (max, value) => value > max ? value : max);
      totalAbsoluteError += (100 - spread) / 100;

      examples.add(
        LabelledExample(
          input: scenario.rationale,
          gold: {scenario.gold},
          predicted: {predictedLabel ?? 'none'},
        ),
      );
    }

    final report = evaluate(examples, labels);
    final matrix = buildConfusionMatrix(examples, labels);

    final card = Scorecard(
      suite: 'rule_sentiment',
      description:
          'AISentimentService.computeBaseSentiment scored against '
          '${kRuleScenarios.length} usage scenarios. Gold is the emotion a '
          'digital-wellbeing analyst would name; the prediction is the highest '
          'of the five returned percentages.',
    );

    card.addClassificationReport(report);
    card.addConfusionMatrix(matrix);

    final predictedTable = StringBuffer();
    predictedTable.writeln('${'argmax label'.padRight(14)}${'times chosen'.padLeft(13)}');
    final sortedPredicted = predictedCounts.keys.toList()..sort();
    for (final label in sortedPredicted) {
      predictedTable.writeln(
        '${label.padRight(14)}${predictedCounts[label].toString().padLeft(13)}',
      );
    }
    card.section('How often each label was the argmax', predictedTable.toString());

    card
      ..count('Scenarios', kRuleScenarios.length)
      ..raw('Mean (1 - top share)', totalAbsoluteError / kRuleScenarios.length)
      ..note(
        'computeBaseSentiment returns a five-label distribution, not a class. '
        'The app displays all five values, so this suite is a diagnostic on '
        'which label the highest percentage lands on, not a claim that the '
        'scorer is meant to output a single class.',
      )
      ..note(
        'The rule set starts every day from a Neutral prior of 40 points while '
        'Positive starts at 28 and Focused at 10, so Neutral wins the argmax '
        'unless the good-habit bonuses (streak, habits, tasks) or the '
        'over-goal penalty are large. That prior is the main driver of the '
        'confusion matrix below.',
      )
      ..note(
        'Positive and Focused receive identical bonuses in every branch of the '
        'rule set, so the scorer cannot separate them; they are expected to '
        'absorb each other in the confusion matrix.',
      );

    card.metadata['headline'] = <String, dynamic>{
      'argmax accuracy': report.subsetAccuracy,
      'macro F1': report.macroF1,
      'micro F1': report.microF1,
      'weighted F1': report.weightedF1,
    };

    writer.add(card);

    expect(report.total, kRuleScenarios.length);
    expect(predictedCounts, isNotEmpty);
  });
// ═══════════════════════════════════════════════════════════════════
  // 4. Daily score parser
  // ═══════════════════════════════════════════════════════════════════

  test('daily_score_parser', () {
    // (raw reply, expected value) — null means the reply must be rejected.
    // These are the decorations models actually attach to a requested bare
    // number, plus the out-of-range replies that must not be trusted.
    const cases = <List<Object?>>[
      <Object?>['0.3', 0.3],
      <Object?>['-0.7', -0.7],
      <Object?>['0', 0.0],
      <Object?>['1.0', 1.0],
      <Object?>['-1.0', -1.0],
      <Object?>['  0.42  ', 0.42],
      <Object?>['+0.25', 0.25],
      <Object?>['0.3\n', 0.3],
      <Object?>['Score: -0.4', -0.4],
      <Object?>['-0.4\n', -0.4],
      <Object?>['```\n-0.4\n```', -0.4],
      <Object?>['```0.55```', 0.55],
      <Object?>['The score is 0.6 out of 1.0', 0.6],
      <Object?>['-0.75.', -0.75],
      <Object?>['.5', 0.5],
      <Object?>['1.5', null],
      <Object?>['-1.5', null],
      <Object?>['4.2', null],
      <Object?>['no number here', null],
      <Object?>['', null],
      <Object?>['   ', null],
    ];

    var correct = 0;
    var rejectCorrect = 0;
    var rejectTotal = 0;
    final failures = <String>[];

    for (final row in cases) {
      final raw = row[0] as String;
      final expected = row[1] as double?;
      final actual = DailySentimentScoringService.parseScoreResponse(raw);

      final matches = expected == null
          ? actual == null
          : (actual != null && (actual - expected).abs() < 1e-9);

      if (matches) {
        correct++;
        if (expected == null) {
          rejectCorrect++;
        }
      } else {
        failures.add('"$raw" expected ${expected ?? 'reject'} got ${actual ?? 'reject'}');
      }
      if (expected == null) rejectTotal++;
    }

    final card = Scorecard(
      suite: 'daily_score_parser',
      description:
          'DailySentimentScoringService.parseScoreResponse scored against '
          '${cases.length} raw model replies, including the decorated forms a '
          'bare double.tryParse would have rejected.',
    );

    card
      ..pct(
        'Exact-match accuracy',
        correct / cases.length,
        note: '$correct/${cases.length} replies parsed to the expected value',
      )
      ..pct(
        'Rejection correctness',
        rejectTotal == 0 ? 0 : rejectCorrect / rejectTotal,
        note: '$rejectCorrect/$rejectTotal unusable or out-of-range replies were rejected',
      )
      ..count('Cases', cases.length)
      ..count('Usable replies', cases.length - rejectTotal)
      ..count('Replies that must be rejected', rejectTotal);

    if (failures.isNotEmpty) {
      card.section('Mismatches', failures.map((f) => '- $f').join('\n'));
      card.note('${failures.length} mismatch(es) listed above.');
    }

    // A 2x2 accept/reject confusion table, so the report shows which direction
    // the parser errs in.
    var trueAccept = 0, falseReject = 0, trueReject = 0, falseAccept = 0;
    for (final row in cases) {
      final raw = row[0] as String;
      final expected = row[1] as double?;
      final actual = DailySentimentScoringService.parseScoreResponse(raw);
      if (expected != null && actual != null) {
        trueAccept++;
      } else if (expected != null && actual == null) {
        falseReject++;
      } else if (expected == null && actual == null) {
        trueReject++;
      } else {
        falseAccept++;
      }
    }
    card.section(
      'Accept/reject confusion matrix',
      '                     parser accepts   parser rejects\n'
          ' should parse      ${trueAccept.toString().padLeft(13)}   '
          '${falseReject.toString().padLeft(14)}\n'
          ' should reject     ${falseAccept.toString().padLeft(13)}   '
          '${trueReject.toString().padLeft(14)}\n',
    );

    card.metadata['headline'] = <String, dynamic>{
      'exact-match accuracy': correct / cases.length,
      'rejection correctness': rejectTotal == 0 ? 0.0 : rejectCorrect / rejectTotal,
    };

    writer.add(card);

    expect(correct, cases.length,
        reason: 'every daily-score case must parse as specified: $failures');
  });

  // ═══════════════════════════════════════════════════════════════════
  // 5. AI agent behaviour
  // ═══════════════════════════════════════════════════════════════════

  test('agent_behaviour', () {
    final agent = AIChatbotService.instance;

    // ── 5a. Prompt routing ───────────────────────────────────────────
    const buckets = <String>[
      'Anxious',
      'Negative',
      'Focused',
      'Positive',
      'Neutral',
    ];

    final routingExamples = <LabelledExample>[];
    for (final routingCase in kAgentRoutingCases) {
      final prompts = agent.getSuggestedPrompts(routingCase.sentiment);

      // The bucket is identified by which starter set came back; compare the
      // returned list against each bucket's canonical list.
      var matched = 'none';
      for (final bucket in buckets) {
        final canonical = agent.getSuggestedPrompts(_bucketProbe(bucket));
        if (canonical.length == prompts.length &&
            List.generate(canonical.length, (i) => canonical[i] == prompts[i])
                .every((same) => same)) {
          matched = bucket;
          break;
        }
      }

      routingExamples.add(
        LabelledExample(
          input: routingCase.description,
          gold: {routingCase.expectedBucket},
          predicted: {matched},
        ),
      );
    }

    final routingReport = evaluate(routingExamples, buckets);
    final routingMatrix = buildConfusionMatrix(routingExamples, buckets);

    final card = Scorecard(
      suite: 'agent_behaviour',
      description:
          'Deterministic AIChatbotService behaviour: prompt routing '
          '(${kAgentRoutingCases.length} sentiment vectors) and session-title '
          'normalisation (${kTitleCases.length} messages).',
    );

    card.addClassificationReport(routingReport, title: 'Prompt routing per bucket');
    card.addConfusionMatrix(routingMatrix, title: 'Prompt routing confusion matrix');

    // ── 5b. Title normalisation ──────────────────────────────────────
    var titlesCorrect = 0;
    final titleFailures = <String>[];
    for (final titleCase in kTitleCases) {
      final actual = AIChatbotService.titleFromMessage(titleCase.message);
      if (actual == titleCase.expected) {
        titlesCorrect++;
      } else {
        titleFailures.add(
          '"${titleCase.message}" expected "${titleCase.expected}" got "$actual"',
        );
      }
    }

    card
      ..pct(
        'Title normalisation accuracy',
        titlesCorrect / kTitleCases.length,
        note: '$titlesCorrect/${kTitleCases.length} titles produced as expected',
      )
      ..count('Routing cases', kAgentRoutingCases.length)
      ..count('Title cases', kTitleCases.length)
      ..note(
        'Prompt routing is a five-way classification scored over the bucket the '
        'returned starter set belongs to. Ties resolve to whichever key the '
        'sentiment map yields first, which is why two identical vectors with '
        'different key order can legitimately route to different buckets; '
        'those cases are labelled to the behaviour the production reduce '
        'produces.',
      );

    if (titleFailures.isNotEmpty) {
      card.section('Title mismatches', titleFailures.map((f) => '- $f').join('\n'));
    }

    card.metadata['headline'] = <String, dynamic>{
      'routing accuracy': routingReport.subsetAccuracy,
      'routing macro F1': routingReport.macroF1,
      'title accuracy': titlesCorrect / kTitleCases.length,
    };

    writer.add(card);

    expect(routingReport.total, kAgentRoutingCases.length);
    expect(routingReport.subsetAccuracy, greaterThan(0.8));
    expect(titlesCorrect, kTitleCases.length,
        reason: 'title normaliser mismatches: $titleFailures');
  });
}

/// Build a sentiment vector whose dominant label is [bucket], used to discover
/// the canonical starter set for that bucket rather than duplicating the prompt
/// strings here (they would drift out of sync with the service).
Map<String, double> _bucketProbe(String bucket) {
  final probe = <String, double>{
    'Positive': 0,
    'Neutral': 0,
    'Negative': 0,
    'Anxious': 0,
    'Focused': 0,
  };
  // Neutral has no case in the service switch, so it always falls through to
  // the default set; probing it as the highest value is what reaches that.
  probe[bucket] = 100;
  return probe;
}
