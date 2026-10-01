// Copyright (c) 2026 NLP digitox
//
// Raw LLM replies fed to AISentimentService.parseSentiment, paired with what a
// correct parser should do with each one.
//
// These are the shapes Groq actually returns for the sentiment prompt: the
// documented five-line format, a JSON object, fenced JSON, JSON wrapped in
// prose, string values, markdown tables, numbered lists, and outright
// refusals. Each case records whether parsing should succeed and, when it
// should, which of the five canonical labels must come back.

/// What a correct parser does with a raw reply.
enum ParseExpectation {
  /// Parsing must succeed and yield at least three canonical labels.
  parses,

  /// Parsing must throw: the reply carries no usable sentiment.
  rejects,
}

/// One parser robustness case.
class SentimentParseCase {
  const SentimentParseCase(
    this.raw,
    this.expectation,
    this.expectedLabels, {
    this.format = 'unknown',
  });

  final String raw;
  final ParseExpectation expectation;

  /// Canonical labels a correct parse must recover.
  final Set<String> expectedLabels;

  /// Human-readable family of the reply shape, for per-format breakdowns.
  final String format;
}

const Set<String> _allFive = {
  'Positive',
  'Neutral',
  'Negative',
  'Anxious',
  'Focused',
};

/// 26 replies covering every output format observed from the Groq model.
const List<SentimentParseCase> kSentimentParseCases = <SentimentParseCase>[
  // ── the documented five-line format ────────────────────────────────
  SentimentParseCase(
    'Positive: 30\nNeutral: 40\nNegative: 10\nAnxious: 10\nFocused: 10',
    ParseExpectation.parses,
    _allFive,
    format: 'lines',
  ),
  SentimentParseCase(
    'Positive: 35\nNeutral: 40\nNegative: 5\nAnxious: 10\nFocused: 10\n',
    ParseExpectation.parses,
    _allFive,
    format: 'lines',
  ),
  SentimentParseCase(
    'Positive: 30.5\nNeutral: 39.5\nNegative: 10\nAnxious: 10\nFocused: 10',
    ParseExpectation.parses,
    _allFive,
    format: 'lines',
  ),
  SentimentParseCase(
    'positive: 30\nneutral: 40\nnegative: 10\nanxious: 10\nfocused: 10',
    ParseExpectation.parses,
    _allFive,
    format: 'lines',
  ),

  // ── bare JSON object ───────────────────────────────────────────────
  SentimentParseCase(
    '{"Positive": 35, "Neutral": 40, "Negative": 10, "Anxious": 10, "Focused": 5}',
    ParseExpectation.parses,
    _allFive,
    format: 'json',
  ),
  SentimentParseCase(
    '{"positive": 35, "neutral": 45, "negative": 5, "anxious": 10, "focused": 5}',
    ParseExpectation.parses,
    _allFive,
    format: 'json',
  ),
  SentimentParseCase(
    '  {"Anxious": 20, "Focused": 5, "Negative": 10, "Neutral": 45, "Positive": 20}  ',
    ParseExpectation.parses,
    _allFive,
    format: 'json',
  ),

  // ── JSON with non-numeric values ───────────────────────────────────
  SentimentParseCase(
    '{"Positive": "35", "Neutral": "40", "Negative": "10", "Anxious": "10", "Focused": "5"}',
    ParseExpectation.parses,
    _allFive,
    format: 'json-string-values',
  ),
  SentimentParseCase(
    '{"Positive": "35%", "Neutral": "40%", "Negative": "10%", "Anxious": "10%", "Focused": "5%"}',
    ParseExpectation.parses,
    _allFive,
    format: 'json-percent-values',
  ),

  // ── fenced / prose-wrapped JSON ────────────────────────────────────
  SentimentParseCase(
    '```json\n{"Positive": 35, "Neutral": 45, "Negative": 5, "Anxious": 10, "Focused": 5}\n```',
    ParseExpectation.parses,
    _allFive,
    format: 'fenced-json',
  ),
  SentimentParseCase(
    '```\n{"Positive": 25, "Neutral": 45, "Negative": 10, "Anxious": 10, "Focused": 10}\n```',
    ParseExpectation.parses,
    _allFive,
    format: 'fenced-json',
  ),
  SentimentParseCase(
    'Here is the analysis you asked for:\n{"Positive": 20, "Neutral": 30, "Negative": 20, "Anxious": 20, "Focused": 10}\nHope this helps!',
    ParseExpectation.parses,
    _allFive,
    format: 'prose-wrapped-json',
  ),

  // ── fenced legacy lines ────────────────────────────────────────────
  SentimentParseCase(
    '```\nPositive: 30\nNeutral: 40\nNegative: 10\nAnxious: 10\nFocused: 10\n```',
    ParseExpectation.parses,
    _allFive,
    format: 'fenced-lines',
  ),

  // ── values that do not sum to 100 (must be normalised) ─────────────
  SentimentParseCase(
    'Positive: 3\nNeutral: 4\nNegative: 1\nAnxious: 1\nFocused: 1',
    ParseExpectation.parses,
    _allFive,
    format: 'lines-normalise',
  ),

  // ── extra labels alongside the five ────────────────────────────────
  SentimentParseCase(
    'Positive: 30\nNeutral: 40\nNegative: 10\nAnxious: 10\nFocused: 10\nOther: 5',
    ParseExpectation.parses,
    _allFive,
    format: 'lines-extra-label',
  ),

  // ── formats the current parser cannot handle ───────────────────────
  SentimentParseCase(
    '1. Positive: 30\n2. Neutral: 40\n3. Negative: 10\n4. Anxious: 10\n5. Focused: 10',
    ParseExpectation.parses,
    _allFive,
    format: 'numbered-list',
  ),
  SentimentParseCase(
    '| Emotion | Percent |\n| --- | --- |\n| Positive | 30 |\n| Neutral | 40 |\n| Negative | 10 |\n| Anxious | 10 |\n| Focused | 10 |',
    ParseExpectation.parses,
    _allFive,
    format: 'markdown-table',
  ),
  SentimentParseCase(
    '- Positive: 30\n- Neutral: 40\n- Negative: 10\n- Anxious: 10\n- Focused: 10',
    ParseExpectation.parses,
    _allFive,
    format: 'bulleted-list',
  ),
  SentimentParseCase(
    'Positive 30\nNeutral 40\nNegative 10\nAnxious 10\nFocused 10',
    ParseExpectation.parses,
    _allFive,
    format: 'no-separator',
  ),

  // ── replies that carry no usable sentiment ─────────────────────────
  SentimentParseCase('', ParseExpectation.rejects, {}, format: 'empty'),
  SentimentParseCase('   \n  ', ParseExpectation.rejects, {}, format: 'empty'),
  SentimentParseCase(
    'I cannot analyze this without more usage data.',
    ParseExpectation.rejects,
    {},
    format: 'refusal',
  ),
  SentimentParseCase(
    'Positive: 50\nNeutral: 50',
    ParseExpectation.rejects,
    {},
    format: 'too-few-labels',
  ),
  SentimentParseCase(
    'Positive: thirty\nNeutral: forty\nNegative: ten\nAnxious: ten\nFocused: ten',
    ParseExpectation.rejects,
    {},
    format: 'non-numeric-values',
  ),
  SentimentParseCase(
    '{"error": "rate limit exceeded"}',
    ParseExpectation.rejects,
    {},
    format: 'error-json',
  ),
  SentimentParseCase(
    '["Positive", "Neutral", "Negative"]',
    ParseExpectation.rejects,
    {},
    format: 'json-array',
  ),
  SentimentParseCase(
    'Positive: -30\nNeutral: 40\nNegative: 10\nAnxious: 10\nFocused: 10',
    ParseExpectation.rejects,
    {},
    format: 'negative-values',
  ),
];
