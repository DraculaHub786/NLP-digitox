// Copyright (c) 2026 NLP digitox
//
// Gold topic labels for the ChatContextExtractor keyword classifier.
//
// The messages are written the way a user actually types to ditixBot, not to
// flatter the keyword list: single-topic statements, genuine multi-topic
// statements, and a block of negatives (including hard negatives that share a
// substring with a keyword, e.g. "interest" contains "rest"). Labels are the
// topics a human reader would assign; where a label is arguable the comment on
// the line records why it was chosen.

/// One labelled message: [gold] is the set of topics a human would tag.
class TopicExample {
  const TopicExample(this.message, this.gold);

  final String message;
  final Set<String> gold;
}

/// Every topic key the classifier can emit, mirrored from
/// `ChatContextExtractor.topicKeywords`. Kept as the evaluation's label space so
/// a label that is never predicted still scores a recall of zero.
const List<String> kTopicLabels = <String>[
  'sleep',
  'work',
  'study',
  'anxiety',
  'family',
  'social media',
  'focus',
  'health',
  'loneliness',
  'productivity',
  'phone usage',
];

/// The labelled set. 132 messages: 63 single-topic, 24 multi-topic, 45
/// negatives (10 of them hard negatives that trip a keyword on a substring).
const List<TopicExample> kTopicExamples = <TopicExample>[
  // ── sleep (6) ──────────────────────────────────────────────────────
  TopicExample('I stayed up way too late last night and now I am exhausted', {'sleep'}),
  TopicExample('My sleep schedule is completely messed up, I go to bed at 3am', {'sleep'}),
  TopicExample('I keep waking up in the middle of the night to check my phone',
      {'sleep', 'phone usage'}),
  TopicExample('I am so tired all the time, I think it is from scrolling before bedtime',
      {'sleep', 'social media'}),
  TopicExample('Bedtime routine is the hardest part for me', {'sleep'}),
  TopicExample('I slept only four hours because of insomnia', {'sleep'}),

  // ── work (6) ───────────────────────────────────────────────────────
  TopicExample('I have a huge deadline at work tomorrow', {'work'}),
  TopicExample('My boss keeps messaging me after hours', {'work'}),
  TopicExample('I am working from home and cannot separate work from life', {'work'}),
  TopicExample('Too many meetings today, I got nothing done', {'work'}),
  TopicExample('My project is behind schedule and the client is unhappy', {'work'}),
  TopicExample('I need to stop checking work email on weekends', {'work'}),

  // ── study (5) ──────────────────────────────────────────────────────
  TopicExample('Exams are next week and I have not started revision', {'study'}),
  TopicExample('I cannot study without picking up my phone every five minutes',
      {'study', 'phone usage'}),
  TopicExample('My assignment is due tonight and I am only halfway', {'study'}),
  TopicExample('I am studying for a test but keep getting distracted',
      {'study', 'focus'}),
  TopicExample('The syllabus is huge and I am behind on it', {'study'}),

  // ── anxiety (5) ────────────────────────────────────────────────────
  TopicExample('I feel so anxious all the time, my chest is tight', {'anxiety'}),
  TopicExample('I am overwhelmed by how many notifications I get',
      {'anxiety', 'phone usage'}),
  TopicExample('I am stressed about my screen time numbers', {'anxiety', 'phone usage'}),
  TopicExample('I had a panic moment when I saw my weekly usage report',
      {'anxiety', 'phone usage'}),
  TopicExample('I am nervous about how much time I waste', {'anxiety'}),

  // ── family (6) ─────────────────────────────────────────────────────
  TopicExample('I want to be more present with my kids', {'family'}),
  TopicExample('My mom keeps calling and I keep ignoring her for my phone',
      {'family', 'phone usage'}),
  TopicExample('I spend more time on my phone than with my family',
      {'family', 'phone usage'}),
  TopicExample('My brother and I hardly talk anymore', {'family'}),
  TopicExample('My dad is always on his phone at dinner', {'family', 'phone usage'}),
  TopicExample('I want to be home more, present for my parents', {'family'}),

  // ── social media (5) ───────────────────────────────────────────────
  TopicExample('I spend hours on Instagram reels every night', {'social media'}),
  TopicExample('TikTok is eating my evenings', {'social media'}),
  TopicExample('I open YouTube shorts and lose an hour', {'social media'}),
  TopicExample('The endless scrolling on my feed never stops', {'social media'}),
  TopicExample('Reels are the worst thing for my evenings', {'social media'}),

  // ── focus (5) ──────────────────────────────────────────────────────
  TopicExample('I get distracted every few minutes', {'focus'}),
  TopicExample('I cannot concentrate on one task anymore', {'focus'}),
  TopicExample('I keep procrastinating on everything', {'focus'}),
  TopicExample('My attention span is shot', {'focus'}),
  TopicExample('I want to be more mindful about my time', {'focus'}),

  // ── health (5) ─────────────────────────────────────────────────────
  TopicExample('I have not worked out in weeks', {'health'}),
  TopicExample('I want to start going to the gym again', {'health'}),
  TopicExample('My diet is terrible lately', {'health'}),
  TopicExample('Meditation helps me calm down in the evening', {'health'}),
  TopicExample('I want to improve my fitness this year', {'health'}),

  // ── loneliness (5) ─────────────────────────────────────────────────
  TopicExample('I feel really lonely lately', {'loneliness'}),
  TopicExample('I am sad and I do not know why', {'loneliness'}),
  TopicExample('I have been crying a lot this week', {'loneliness'}),
  TopicExample('I feel isolated even though I am always online',
      {'loneliness', 'phone usage'}),
  TopicExample('I feel down a lot in the evenings', {'loneliness'}),

  // ── productivity (5) ───────────────────────────────────────────────
  TopicExample('I want a better morning routine', {'productivity'}),
  TopicExample('I need to organise my schedule', {'productivity'}),
  TopicExample('I am trying to be more productive with my time', {'productivity'}),
  TopicExample('My planning system falls apart every week', {'productivity'}),
  TopicExample('I want to build better habits', {'productivity'}),

  // ── phone usage (5) ────────────────────────────────────────────────
  TopicExample('My screen time was eight hours yesterday', {'phone usage'}),
  TopicExample('I think I am addicted to my phone', {'phone usage'}),
  TopicExample('I want to do a digital detox', {'phone usage'}),
  TopicExample('I am checking notifications constantly', {'phone usage'}),
  TopicExample('My phone battery dies by noon from all the usage', {'phone usage'}),

  // ── multi-topic (24) ───────────────────────────────────────────────
  TopicExample('I stay up late scrolling Instagram', {'sleep', 'social media'}),
  TopicExample('Work stress is keeping me awake at night', {'work', 'anxiety', 'sleep'}),
  TopicExample('I procrastinate at work by scrolling TikTok',
      {'work', 'focus', 'social media'}),
  TopicExample('Exam stress is ruining my sleep', {'study', 'anxiety', 'sleep'}),
  TopicExample('I am lonely so I scroll Instagram all night',
      {'loneliness', 'social media', 'sleep'}),
  TopicExample('My screen time is high because of work deadlines',
      {'phone usage', 'work'}),
  TopicExample('I want to work out but I am always on my phone',
      {'health', 'phone usage'}),
  TopicExample('Family time is ruined by everyone being on their phones',
      {'family', 'phone usage'}),
  TopicExample('I am stressed about exam results and cannot focus',
      {'anxiety', 'study', 'focus'}),
  TopicExample('Going to bed tired after a long work day', {'sleep', 'work'}),
  TopicExample('I feel anxious and lonely and keep checking notifications',
      {'anxiety', 'loneliness', 'phone usage'}),
  TopicExample('My study schedule keeps breaking because of YouTube',
      {'study', 'productivity', 'social media'}),
  TopicExample('My focus at work is destroyed by constant notifications',
      {'work', 'focus', 'phone usage'}),
  TopicExample('I want a morning routine with exercise and no phone',
      {'productivity', 'health', 'phone usage'}),
  TopicExample('Worried about my health because I sit all day on my phone',
      {'anxiety', 'health', 'phone usage'}),
  TopicExample('The kids are on their phones at bedtime',
      {'family', 'phone usage', 'sleep'}),
  TopicExample('I am stressed, sad, and exhausted', {'anxiety', 'loneliness', 'sleep'}),
  TopicExample('Deadline tomorrow and I am scrolling instead of working',
      {'work', 'social media', 'focus'}),
  TopicExample('Meditation plus a screen time detox is my plan',
      {'health', 'phone usage', 'productivity'}),
  TopicExample('I want to talk to my sister more instead of scrolling',
      {'family', 'social media'}),
  TopicExample('Distracted while studying by notifications on my phone',
      {'focus', 'study', 'phone usage'}),
  TopicExample('I am worried about my exam', {'anxiety', 'study'}),
  TopicExample('Tired at work because I scroll at night',
      {'sleep', 'work', 'social media'}),
  TopicExample('Can not sleep, keep thinking about deadlines', {'sleep', 'work'}),

  // ── negatives: no topic applies (35) ───────────────────────────────
  TopicExample('Hello', {}),
  TopicExample('Thanks, that helps', {}),
  TopicExample('What can you do for me?', {}),
  TopicExample('Good morning', {}),
  TopicExample('Can you explain how the app works?', {}),
  TopicExample('Yes please', {}),
  TopicExample('That makes sense', {}),
  TopicExample('Tell me more', {}),
  TopicExample('I do not understand that part', {}),
  TopicExample('Okay, got it', {}),
  TopicExample('Good night', {}),
  TopicExample('How are you doing today?', {}),
  TopicExample('That is a good idea', {}),
  TopicExample('I appreciate the help', {}),
  TopicExample('Let me think about it', {}),
  TopicExample('What is my leaderboard rank?', {}),
  TopicExample('How do I export my data?', {}),
  TopicExample('Set a reminder for five pm', {}),
  TopicExample('I like this application', {}),
  TopicExample('Sounds good to me', {}),
  TopicExample('Can you repeat that please?', {}),
  TopicExample('What time is it?', {}),
  TopicExample('Where do I find the settings?', {}),
  TopicExample('Nice work on the new look', {}),
  TopicExample('Sure, go ahead', {}),

  // ── hard negatives: a keyword matches a substring of an unrelated word ──
  // "interest" contains "rest" (sleep), "test" is a study keyword used here as
  // a verb about software, "plan" appears inside "explained", and "walk"
  // appears inside "walkthrough".
  TopicExample('I am interested in learning more about this', {}),
  TopicExample('Can I test the new feature before it ships?', {}),
  TopicExample('You explained that really clearly', {}),
  TopicExample('The walkthrough of the settings screen was helpful', {}),
  TopicExample('I want to restart the timer', {}),
  TopicExample('That is the best part of the update', {}),
  TopicExample('My concerns are mostly about the interface', {}),
  TopicExample('This is not what I expected', {}),
  TopicExample('Please show me the progress screen', {}),
  TopicExample('Where is the download button?', {}),
];
