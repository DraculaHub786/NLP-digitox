# NLP / AI evaluation report

Generated: 2026-10-01T23:34:29.174470

## Run environment

- **suite**: NLP / AI evaluation
- **dataset: topics**: 117
- **dataset: sentiment parse replies**: 27
- **dataset: rule scenarios**: 38
- **dataset: agent routing**: 30
- **dataset: agent titles**: 16
- **sentiment labels**: 11

## Summary

| suite | headline metric | value |
| --- | --- | ---: |
| topic_classification | micro F1 | 0.9018 |
|  | macro F1 | 0.8990 |
|  | weighted F1 | 1.0257 |
|  | subset accuracy | 0.7863 |
|  | single-label accuracy | 0.9737 |
|  | false-positive-free negatives | 0.8000 |
| sentiment_parser | parse-decision accuracy | 0.7778 |
|  | label micro F1 | 0.8235 |
|  | label macro F1 | 0.8235 |
|  | normalisation correctness | 1.0000 |
| rule_sentiment | argmax accuracy | 0.6316 |
|  | macro F1 | 0.4609 |
|  | micro F1 | 0.6316 |
|  | weighted F1 | 0.5319 |
| daily_score_parser | exact-match accuracy | 1.0000 |
|  | rejection correctness | 1.0000 |
| agent_behaviour | routing accuracy | 1.0000 |
|  | routing macro F1 | 1.0000 |
|  | title accuracy | 1.0000 |

## Full scorecards

### topic_classification

ChatContextExtractor.classifyTopics (11-topic keyword classifier) scored against 117 hand-labelled chat messages.

| metric | value | note |
| --- | ---: | --- |
| Subset accuracy (exact match) | 78.63% | 92/117 examples |
| Micro precision | 87.32% |  |
| Micro recall | 93.23% |  |
| Micro F1 | 90.18% |  |
| Macro precision | 87.72% |  |
| Macro recall | 93.43% |  |
| Macro F1 | 89.90% |  |
| Weighted F1 | 102.57% |  |
| Examples scored | 117 |  |
| Accuracy (single-label argmax) | 97.37% | 37/38 examples |
| Empty-gold precision (no false positives) | 80.00% | 28/35 negative messages stayed empty |
| Single-topic messages | 47 |  |
| Multi-topic messages | 35 |  |
| Negative messages | 35 |  |
| Labels in the space | 11 |  |
| Topics in the keyword dictionary | 11 |  |

> The confusion matrix covers only the 38 single-topic messages: a multi-topic example has no single gold class to sit in, so it is scored in the micro/macro F1 block above but omitted from the matrix. Accuracy above is therefore over single-topic cases only.

> Micro F1 pools every tp/fp/fn, so the frequent topics dominate it. Macro F1 weights all eleven topics equally, which is the stricter number when a rare topic such as loneliness matters.

**Per-label**

```
label              prec      rec       F1     tp     fp     fn  support
sleep             0.857    0.800    0.828     12      2      3       15
work              0.778    1.000    0.875     14      4      0       14
study             0.909    1.000    0.952     10      1      0       10
anxiety           1.000    1.000    1.000     12      0      0       12
family            0.818    1.000    0.900      9      2      0        9
social media      1.000    0.923    0.960     12      0      1       13
focus             1.000    0.818    0.900      9      0      2       11
health            0.875    0.778    0.824      7      1      2        9
loneliness        0.800    1.000    0.889      8      2      0        8
productivity      0.727    1.000    0.842      8      3      0        8
phone usage       0.885    0.958    0.920     23      3      1       24
```

**Confusion matrix (counts)**

```
                 sleep     work    study  anxiety   familysocial media    focus   healthlonelinessproductivityphone usage  (rows = gold, cols = predicted)
sleep                1        0        0        0        0        0        0        0        0        0        0
work                 0        3        0        0        0        0        0        0        0        0        0
study                0        0        3        0        0        0        0        0        0        0        0
anxiety              0        0        0        2        0        0        0        0        0        0        0
family               0        0        0        0        3        0        0        0        0        0        0
social media         0        0        0        0        0        4        0        0        0        0        0
focus                0        0        0        0        0        0        4        0        0        0        0
health               0        1        0        0        0        0        0        3        0        0        0
loneliness           0        0        0        0        0        0        0        0        4        0        0
productivity         0        0        0        0        0        0        0        0        0        5        0
phone usage          0        0        0        0        0        0        0        0        0        0        5
```

**Confusion matrix (row-normalised)**

```
                 sleep     work    study  anxiety   familysocial media    focus   healthlonelinessproductivityphone usage  (rows = gold, cols = predicted)
sleep             1.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00
work              0.00     1.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00
study             0.00     0.00     1.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00
anxiety           0.00     0.00     0.00     1.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00
family            0.00     0.00     0.00     0.00     1.00     0.00     0.00     0.00     0.00     0.00     0.00
social media      0.00     0.00     0.00     0.00     0.00     1.00     0.00     0.00     0.00     0.00     0.00
focus             0.00     0.00     0.00     0.00     0.00     0.00     1.00     0.00     0.00     0.00     0.00
health            0.00     0.25     0.00     0.00     0.00     0.00     0.00     0.75     0.00     0.00     0.00
loneliness        0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     1.00     0.00     0.00
productivity      0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     1.00     0.00
phone usage       0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     0.00     1.00
```


### sentiment_parser

AISentimentService.parseSentiment scored against 27 raw model replies (19 of which carry usable sentiment).

| metric | value | note |
| --- | ---: | --- |
| Parse-decision accuracy | 77.78% | 21/27 replies handled correctly |
| Replies that should parse | 19 |  |
| Replies that should be rejected | 8 |  |
| Subset accuracy (exact match) | 77.78% | 21/27 examples |
| Micro precision | 93.33% |  |
| Micro recall | 73.68% |  |
| Micro F1 | 82.35% |  |
| Macro precision | 93.33% |  |
| Macro recall | 73.68% |  |
| Macro F1 | 82.35% |  |
| Weighted F1 | 289.76% |  |
| Examples scored | 27 |  |
| Normalisation correctness | 100.00% | 15/15 successful parses summed to 100 (+/- 0.01) |
| Successful parses | 15 |  |

> Per-label F1 here measures label recovery on replies that both should and do parse: a reply the parser wrongly rejects contributes false negatives for all five labels, so parse-decision accuracy is the more direct measure of parser health.

**Per-label (parsed label sets)**

```
label              prec      rec       F1     tp     fp     fn  support
Positive          0.933    0.737    0.824     14      1      5       19
Neutral           0.933    0.737    0.824     14      1      5       19
Negative          0.933    0.737    0.824     14      1      5       19
Anxious           0.933    0.737    0.824     14      1      5       19
Focused           0.933    0.737    0.824     14      1      5       19
```

**Per reply format**

```
format                      correct   total
bulleted-list                     0       1
empty                             2       2
error-json                        1       1
fenced-json                       2       2
fenced-lines                      1       1
json                              3       3
json-array                        1       1
json-percent-values               0       1
json-string-values                1       1
lines                             4       4
lines-extra-label                 1       1
lines-normalise                   1       1
markdown-table                    0       1
negative-values                   0       1
no-separator                      0       1
non-numeric-values                1       1
numbered-list                     0       1
prose-wrapped-json                1       1
refusal                           1       1
too-few-labels                    1       1
```


### rule_sentiment

AISentimentService.computeBaseSentiment scored against 38 usage scenarios. Gold is the emotion a digital-wellbeing analyst would name; the prediction is the highest of the five returned percentages.

| metric | value | note |
| --- | ---: | --- |
| Subset accuracy (exact match) | 63.16% | 24/38 examples |
| Micro precision | 63.16% |  |
| Micro recall | 63.16% |  |
| Micro F1 | 63.16% |  |
| Macro precision | 42.22% |  |
| Macro recall | 56.00% |  |
| Macro F1 | 46.09% |  |
| Weighted F1 | 53.19% |  |
| Examples scored | 38 |  |
| Accuracy (single-label argmax) | 63.16% | 24/38 examples |
| Scenarios | 38 |  |
| Mean (1 - top share) | 0.6425 |  |

> computeBaseSentiment returns a five-label distribution, not a class. The app displays all five values, so this suite is a diagnostic on which label the highest percentage lands on, not a claim that the scorer is meant to output a single class.

> The rule set starts every day from a Neutral prior of 40 points while Positive starts at 28 and Focused at 10, so Neutral wins the argmax unless the good-habit bonuses (streak, habits, tasks) or the over-goal penalty are large. That prior is the main driver of the confusion matrix below.

> Positive and Focused receive identical bonuses in every branch of the rule set, so the scorer cannot separate them; they are expected to absorb each other in the confusion matrix.

**Per-label**

```
label              prec      rec       F1     tp     fp     fn  support
Positive          0.667    1.000    0.800      8      4      0        8
Neutral           0.444    1.000    0.615      8     10      0        8
Negative          0.000    0.000    0.000      0      0      8        8
Anxious           1.000    0.800    0.889      8      0      2       10
Focused           0.000    0.000    0.000      0      0      4        4
```

**Confusion matrix (counts)**

```
              Positive  Neutral Negative  Anxious  Focused  (rows = gold, cols = predicted)
Positive             8        0        0        0        0
Neutral              0        8        0        0        0
Negative             0        8        0        0        0
Anxious              0        2        0        8        0
Focused              4        0        0        0        0
```

**Confusion matrix (row-normalised)**

```
              Positive  Neutral Negative  Anxious  Focused  (rows = gold, cols = predicted)
Positive          1.00     0.00     0.00     0.00     0.00
Neutral           0.00     1.00     0.00     0.00     0.00
Negative          0.00     1.00     0.00     0.00     0.00
Anxious           0.00     0.20     0.00     0.80     0.00
Focused           1.00     0.00     0.00     0.00     0.00
```

**How often each label was the argmax**

```
argmax label   times chosen
Anxious                   8
Neutral                  18
Positive                 12
```


### daily_score_parser

DailySentimentScoringService.parseScoreResponse scored against 21 raw model replies, including the decorated forms a bare double.tryParse would have rejected.

| metric | value | note |
| --- | ---: | --- |
| Exact-match accuracy | 100.00% | 21/21 replies parsed to the expected value |
| Rejection correctness | 100.00% | 6/6 unusable or out-of-range replies were rejected |
| Cases | 21 |  |
| Usable replies | 15 |  |
| Replies that must be rejected | 6 |  |

**Accept/reject confusion matrix**

```
                     parser accepts   parser rejects
 should parse                 15                0
 should reject                 0                6
```


### agent_behaviour

Deterministic AIChatbotService behaviour: prompt routing (30 sentiment vectors) and session-title normalisation (16 messages).

| metric | value | note |
| --- | ---: | --- |
| Subset accuracy (exact match) | 100.00% | 30/30 examples |
| Micro precision | 100.00% |  |
| Micro recall | 100.00% |  |
| Micro F1 | 100.00% |  |
| Macro precision | 100.00% |  |
| Macro recall | 100.00% |  |
| Macro F1 | 100.00% |  |
| Weighted F1 | 100.00% |  |
| Examples scored | 30 |  |
| Accuracy (single-label argmax) | 100.00% | 30/30 examples |
| Title normalisation accuracy | 100.00% | 16/16 titles produced as expected |
| Routing cases | 30 |  |
| Title cases | 16 |  |

> Prompt routing is a five-way classification scored over the bucket the returned starter set belongs to. Ties resolve to whichever key the sentiment map yields first, which is why two identical vectors with different key order can legitimately route to different buckets; those cases are labelled to the behaviour the production reduce produces.

**Prompt routing per bucket**

```
label              prec      rec       F1     tp     fp     fn  support
Anxious           1.000    1.000    1.000      8      0      0        8
Negative          1.000    1.000    1.000      4      0      0        4
Focused           1.000    1.000    1.000      5      0      0        5
Positive          1.000    1.000    1.000      7      0      0        7
Neutral           1.000    1.000    1.000      6      0      0        6
```

**Prompt routing confusion matrix (counts)**

```
               Anxious Negative  Focused Positive  Neutral  (rows = gold, cols = predicted)
Anxious              8        0        0        0        0
Negative             0        4        0        0        0
Focused              0        0        5        0        0
Positive             0        0        0        7        0
Neutral              0        0        0        0        6
```

**Prompt routing confusion matrix (row-normalised)**

```
               Anxious Negative  Focused Positive  Neutral  (rows = gold, cols = predicted)
Anxious           1.00     0.00     0.00     0.00     0.00
Negative          0.00     1.00     0.00     0.00     0.00
Focused           0.00     0.00     1.00     0.00     0.00
Positive          0.00     0.00     0.00     1.00     0.00
Neutral           0.00     0.00     0.00     0.00     1.00
```


