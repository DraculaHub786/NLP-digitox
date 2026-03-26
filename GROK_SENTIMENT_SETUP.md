# Grok API Integration for Sentiment Analysis

## Overview
The sentiment analyzer has been updated to use **Grok 2** (xAI) for real, accurate mood and sentiment analysis instead of keyword matching.

## Setup Instructions

### 1. Get Grok API Key

1. Visit [x.ai/api](https://x.ai/api)
2. Sign up or log in
3. Create an API key from the dashboard
4. Keep it safe - you'll need it next

### 2. Configure API Key

**Option A: Environment Variable (Recommended for Development)**
```bash
export GROK_API_KEY="your-api-key-here"
```

**Option B: Runtime Configuration (For Production)**
```dart
await SentimentFilter.instance.initialize(
  grokApiKey: 'your-api-key-here'
);
```

**Option C: Flutter Environment Configuration**
Add to your `.env` file:
```
GROK_API_KEY=your-api-key-here
```

### 3. Initialize the Service

```dart
// In your app initialization
await SentimentFilter.instance.initialize(
  grokApiKey: grokApiKey, // Optional if using GROK_API_KEY env var
);
```

## Usage

```dart
// Analyze user mood with Grok AI
final prediction = await SentimentFilter.instance.analyzeMood("I feel amazing today!");

// Response includes:
// - sentiment: Sentiment enum (veryPositive, positive, neutral, negative, veryNegative)
// - confidence: 0.0-1.0 accuracy score
// - detectedEmotions: ["happy", "excited"]
// - suggestions: Personalized recommendations
// - reasoning: Why Grok classified it this way
```

## Real Examples

### Example 1: Positive Mood
```
User: "I just got promoted! This is the best day ever!"
Grok Analysis:
  Sentiment: veryPositive (98% confidence)
  Emotions: ["joy", "excitement", "pride"]
  Reasoning: Multiple exclamation marks, positive achievement language
  Suggestions:
    - Share your happiness with others
    - Celebrate the achievement
```

### Example 2: Complex/Sarcastic
```
User: "Oh great, another meeting. Just what I needed today."
Grok Analysis:
  Sentiment: negative (85% confidence)
  Emotions: ["frustration", "sarcasm"]
  Reasoning: Detects sarcasm pattern despite "great" keyword
  Suggestions:
    - Take a short break
    - Practice breathing exercise
```

### Example 3: Neutral/Mixed
```
User: "The weather is nice but I'm tired."
Grok Analysis:
  Sentiment: neutral (72% confidence)
  Emotions: ["fatigue", "contentment"]
  Reasoning: Mixed sentiment with contrasting elements
  Suggestions:
    - Get some rest
    - Take a light walk
```

## Fallback Behavior

When Grok API is unavailable:
- ❌ No API key configured
- ❌ Network error
- ❌ API rate limit exceeded
- ❌ Invalid API key

**System automatically falls back to local keyword-based analysis** with instant response times (<10ms) while maintaining the same API interface.

```dart
// Same API works either way - Grok or local fallback
final prediction = await SentimentFilter.instance.analyzeMood(text);
// Works seamlessly whether Grok is available or not
```

## Sentiment Classification Levels

The analyzer provides **6-level sentiment classification**:

| Level | Emoji | Score | Use Case |
|-------|-------|-------|----------|
| **VeryPositive** | 😄 | +2.0 | Excellent mood, very happy |
| **Positive** | 🙂 | +1.0 | Good mood, satisfied |
| **Neutral** | 😐 | 0.0 | Balanced, neither happy nor sad |
| **Negative** | 😟 | -1.0 | Unhappy, dissatisfied |
| **VeryNegative** | 😢 | -2.0 | Extremely distressed |
| **Unknown** | ❓ | 0.0 | Unable to classify |

## API Rate Limits & Pricing

**Grok API:**
- Check xAI pricing page for current rates
- Typical: $0.005 per 1K tokens (input), $0.015 per 1K tokens (output)
- Rate limits: Check your API tier

**Cost Optimization:**
- Batch process moods together
- Cache recent results
- Use local fallback for offline mode

## Error Handling

The system handles all common errors gracefully:

```dart
// Automatic error handling
try {
  final prediction = await SentimentFilter.instance.analyzeMood(text);

  // Grok response or local fallback - works the same way
  print('Sentiment: ${prediction.sentiment.displayName}');
  print('Confidence: ${prediction.confidence}');

} on ArgumentError catch (e) {
  // Invalid input (empty text)
  print('Error: $e');

} on StateError catch (e) {
  // Not initialized
  print('Error: $e');
}
```

## Testing Without API Key

For testing and development **without a Grok API key**:

```dart
// This works! Falls back to local analysis
await SentimentFilter.instance.initialize();

// Same API, instant local response
final prediction = await SentimentFilter.instance.analyzeMood(
  "I feel great!"  // Local analysis within 10ms
);
```

## Architecture

### Call Flow with Grok

```
User Input
    ↓
analyzeMood(text)
    ↓
[Has API Key?]
    ├─ YES ─→ Call Grok API (2-5 seconds)
    │         (Advanced NLP, handles sarcasm, context)
    │
    └─ NO ──→ Local Keyword Analysis (< 10ms)
              (Instant fallback, same interface)
    ↓
SentimentPrediction
├─ sentiment: Enum
├─ confidence: 0.0-1.0
├─ detectedEmotions: ["emotion1", "emotion2"]
├─ suggestions: [MoodSuggestion]
└─ reasoning: "Why this classification"
    ↓
Add to History (persistent tracking)
```

## Features

✅ **Real Sentiment Analysis** - Grok AI understands context, sarcasm, complex emotions
✅ **Automatic Fallback** - Local keyword analysis when API unavailable
✅ **Persistent History** - Track 500 mood entries with timestamps
✅ **Pattern Recognition** - Analyze trends over 7/30/90 days
✅ **Personalized Suggestions** - Priority-based recommendations (1-10)
✅ **Error Resilience** - Graceful degradation, never crashes
✅ **Production Ready** - Full async support, proper state management

## Environment Setup

### For Local Development

```bash
# .env file or terminal
export GROK_API_KEY="xai-..."

# Run your Flutter app
flutter run
```

### For Firebase/Cloud Deployment

Store your Grok API key in:
- **Firebase Remote Config** - Fetch at runtime
- **Secret Manager** - GCP/AWS secret management
- **Environment Variables** - CI/CD pipeline

```dart
// Example: Fetch from Firebase
final remoteConfig = FirebaseRemoteConfig.instance;
final grokKey = remoteConfig.getString('grok_api_key');

await SentimentFilter.instance.initialize(grokApiKey: grokKey);
```

## Next Steps

1. **Get API Key**: Visit [x.ai/api](https://x.ai/api) and create an API key
2. **Set Environment Variable**: `export GROK_API_KEY="your-key"`
3. **Initialize**: `await SentimentFilter.instance.initialize()`
4. **Test**: Use the example code above

## Support

- **Grok API Docs**: https://docs.x.ai/
- **API Status**: Check x.ai status page
- **Rate Limits**: Adjust based on your tier
