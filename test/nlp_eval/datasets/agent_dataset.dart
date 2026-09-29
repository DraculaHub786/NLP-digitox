// Copyright (c) 2026 NLP digitox
//
// Cases for the deterministic parts of the AI agent's behaviour — the parts
// that can be scored without calling Groq:
//
//  * `AIChatbotService.getSuggestedPrompts` — routes the user to a set of
//    conversation starters from the dominant sentiment. A real five-way
//    classifier over the sentiment vector.
//  * `AIChatbotService.titleFromMessage` — the session-title normaliser.

/// One routing case: a sentiment vector and the bucket the agent should pick.
class AgentRoutingCase {
  const AgentRoutingCase(this.sentiment, this.expectedBucket, this.description);

  final Map<String, double> sentiment;

  /// `Anxious`, `Negative`, `Focused`, `Positive`, or `Neutral` (the fallback).
  final String expectedBucket;

  final String description;
}

/// 30 routing cases, including ties and incomplete vectors.
const List<AgentRoutingCase> kAgentRoutingCases = <AgentRoutingCase>[
  AgentRoutingCase(
    {'Positive': 10, 'Neutral': 20, 'Negative': 10, 'Anxious': 45, 'Focused': 15},
    'Anxious',
    'Anxious clearly dominant',
  ),
  AgentRoutingCase(
    {'Positive': 5, 'Neutral': 15, 'Negative': 55, 'Anxious': 20, 'Focused': 5},
    'Negative',
    'Negative clearly dominant',
  ),
  AgentRoutingCase(
    {'Positive': 10, 'Neutral': 10, 'Negative': 5, 'Anxious': 5, 'Focused': 70},
    'Focused',
    'Focused clearly dominant',
  ),
  AgentRoutingCase(
    {'Positive': 60, 'Neutral': 15, 'Negative': 5, 'Anxious': 10, 'Focused': 10},
    'Positive',
    'Positive clearly dominant',
  ),
  AgentRoutingCase(
    {'Positive': 15, 'Neutral': 65, 'Negative': 5, 'Anxious': 10, 'Focused': 5},
    'Neutral',
    'Neutral dominant falls through to the default starter set',
  ),
  AgentRoutingCase(
    {'Positive': 24, 'Neutral': 24, 'Negative': 20, 'Anxious': 26, 'Focused': 6},
    'Anxious',
    'Anxious wins by two points',
  ),
  AgentRoutingCase(
    {'Positive': 30, 'Neutral': 29, 'Negative': 20, 'Anxious': 11, 'Focused': 10},
    'Positive',
    'Positive wins by one point',
  ),
  AgentRoutingCase(
    {'Positive': 20, 'Neutral': 20, 'Negative': 31, 'Anxious': 19, 'Focused': 10},
    'Negative',
    'Negative wins by one point',
  ),
  AgentRoutingCase(
    {'Positive': 20, 'Neutral': 20, 'Negative': 10, 'Anxious': 10, 'Focused': 31},
    'Focused',
    'Focused wins by one point',
  ),
  AgentRoutingCase(
    {'Anxious': 40, 'Negative': 40, 'Neutral': 20, 'Positive': 0, 'Focused': 0},
    'Anxious',
    'Anxious/Negative tie, Anxious first in the map',
  ),
  AgentRoutingCase(
    {'Negative': 40, 'Anxious': 40, 'Neutral': 20, 'Positive': 0, 'Focused': 0},
    'Negative',
    'Same tie, Negative first in the map',
  ),
  AgentRoutingCase(
    {'Anxious': 80, 'Neutral': 20},
    'Anxious',
    'Only two labels present, Anxious dominant',
  ),
  AgentRoutingCase(
    {'Neutral': 50, 'Focused': 50},
    'Neutral',
    'Neutral/Focused tie with Neutral first',
  ),
  AgentRoutingCase(
    {'Focused': 50, 'Neutral': 50},
    'Focused',
    'Neutral/Focused tie with Focused first',
  ),
  AgentRoutingCase(
    {'Positive': 100},
    'Positive',
    'Single-label vector',
  ),
  AgentRoutingCase(
    {'Anxious': 1, 'Negative': 1, 'Focused': 1, 'Positive': 1, 'Neutral': 96},
    'Neutral',
    'Nearly all neutral',
  ),
  AgentRoutingCase(
    {
      'Positive': 30.0,
      'Neutral': 45.0,
      'Negative': 10.0,
      'Anxious': 10.0,
      'Focused': 5.0,
    },
    'Neutral',
    'The canonical fallback sentiment vector',
  ),
  AgentRoutingCase(
    {
      'Positive': 38.0,
      'Neutral': 30.0,
      'Negative': 8.0,
      'Anxious': 8.0,
      'Focused': 16.0,
    },
    'Positive',
    'Recommended-state vector',
  ),
  AgentRoutingCase(
    {
      'Positive': 12.0,
      'Neutral': 26.0,
      'Negative': 24.0,
      'Anxious': 28.0,
      'Focused': 10.0,
    },
    'Anxious',
    'Stressful-day vector, Anxious just ahead',
  ),
  AgentRoutingCase(
    {
      'Positive': 14.0,
      'Neutral': 24.0,
      'Negative': 26.0,
      'Anxious': 26.0,
      'Focused': 10.0,
    },
    'Negative',
    'Stressful-day vector, Negative just ahead of Anxious',
  ),
  AgentRoutingCase(
    {
      'Positive': 18.0,
      'Neutral': 22.0,
      'Negative': 8.0,
      'Anxious': 7.0,
      'Focused': 45.0,
    },
    'Focused',
    'Deep-work vector',
  ),
  AgentRoutingCase(
    {'Positive': 0, 'Neutral': 0, 'Negative': 0, 'Anxious': 0, 'Focused': 100},
    'Focused',
    'Maximum focus',
  ),
  AgentRoutingCase(
    {'Positive': 0, 'Neutral': 0, 'Negative': 0, 'Anxious': 100, 'Focused': 0},
    'Anxious',
    'Maximum anxiety',
  ),
  AgentRoutingCase(
    {'Positive': 0.1, 'Neutral': 0.1, 'Negative': 0.1, 'Anxious': 0.2, 'Focused': 0.1},
    'Anxious',
    'Fractional values, tiny spread',
  ),
  AgentRoutingCase(
    {'Positive': 0, 'Neutral': 100, 'Negative': 0, 'Anxious': 0, 'Focused': 0},
    'Neutral',
    'Purely neutral',
  ),
  AgentRoutingCase(
    {'Positive': 20, 'Neutral': 20, 'Negative': 20, 'Anxious': 20, 'Focused': 20},
    'Positive',
    'Perfect five-way tie resolves to the first key',
  ),
  AgentRoutingCase(
    {'Anxious': 20, 'Negative': 20, 'Focused': 20, 'Positive': 20, 'Neutral': 20},
    'Anxious',
    'Perfect five-way tie with a different key order',
  ),
  AgentRoutingCase(
    {'Positive': 33, 'Neutral': 33.5, 'Negative': 11, 'Anxious': 11, 'Focused': 11.5},
    'Neutral',
    'Neutral marginally ahead',
  ),
  AgentRoutingCase(
    {'Positive': 40, 'Neutral': 20, 'Negative': 40, 'Anxious': 0, 'Focused': 0},
    'Positive',
    'Positive/Negative tie, Positive first',
  ),
  AgentRoutingCase(
    {'Positive': 5, 'Neutral': 5, 'Negative': 5, 'Anxious': 5, 'Focused': 5},
    'Positive',
    'All-equal small vector',
  ),
];

/// One session-title case: an opening message and the title it should produce.
class TitleCase {
  const TitleCase(this.message, this.expected, this.description);

  final String message;
  final String expected;
  final String description;
}

/// 16 title-normalisation cases, including the Unicode boundaries the previous
/// `substring(0, 30)` implementation got wrong.
const List<TitleCase> kTitleCases = <TitleCase>[
  TitleCase('Hello there', 'Hello there', 'short message is unchanged'),
  TitleCase('', 'New Chat', 'empty message falls back'),
  TitleCase('     ', 'New Chat', 'whitespace-only message falls back'),
  TitleCase(
    'I keep scrolling at night and I want to stop',
    'I keep scrolling at night and ...',
    'truncated to the first 30 characters plus ellipsis',
  ),
  TitleCase(
    'Exactly thirty characters here',
    'Exactly thirty characters here',
    'exactly 30 characters is not truncated',
  ),
  TitleCase(
    'Thirty one characters here now',
    'Thirty one characters here now',
    'exactly 30 characters is not truncated',
  ),
  TitleCase(
    'Line one\nLine two\nLine three',
    'Line one Line two Line three',
    'newlines collapse to single spaces',
  ),
  TitleCase(
    'Tabs\tand    multiple   spaces',
    'Tabs and multiple spaces',
    'runs of whitespace collapse',
  ),
  TitleCase(
    '   Leading and trailing   ',
    'Leading and trailing',
    'surrounding whitespace is trimmed',
  ),
  TitleCase(
    'I am feeling anxious about my exam results tomorrow morning',
    'I am feeling anxious about my ...',
    'truncation keeps the space that lands on the boundary',
  ),
  TitleCase(
    'Short but with emoji at the end',
    'Short but with emoji at the en...',
    '31 characters truncates to 30 plus ellipsis',
  ),
  TitleCase(
    'A message that is just under thirty chars',
    'A message that is just under t...',
    '41 characters truncates to 30 plus ellipsis',
  ),
  TitleCase('One', 'One', 'single word'),
  TitleCase('\n\nNewline first\n\n', 'Newline first', 'leading newlines are stripped'),
  TitleCase(
    'Multi\n\nparagraph\nmessage\nthat goes on for a while here',
    'Multi paragraph message that g...',
    'multi-paragraph message collapses then truncates',
  ),
  TitleCase(
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
    'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa...',
    '36 identical characters truncate to 30 plus ellipsis',
  ),
];
