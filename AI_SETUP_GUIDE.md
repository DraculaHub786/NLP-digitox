# AI Features Setup Guide

## Overview

NLP-Digitox now includes advanced AI-powered features using Google Gemini API (free tier):

1. **Sentiment Analysis**: Real-time emotional state analysis based on your digital wellbeing patterns
2. **Smart Recommendations**: Personalized suggestions powered by AI
3. **AI Chatbot**: Human-like conversational assistant for digital wellbeing support

## Features

### 🧠 AI Sentiment Analysis
- **5 Emotion Categories**: Positive, Neutral, Negative, Anxious, Focused
- **Real-time Analysis**: Updates every 6 hours based on your usage patterns
- **Context-Aware**: Considers screen time, habits, tasks, and streaks
- Analyzes:
  - Screen time vs. goals
  - Productivity habits completion
  - Task management patterns
  - Digital behavior trends

### 💡 AI Recommendations
- **Personalized Suggestions**: 3-4 actionable recommendations based on your current state
- **Context Integration**: Uses both sentiment and chat history for better recommendations
- **Dynamic Updates**: Refreshes as your usage patterns change
- Examples:
  - "Take a 5-minute screen break"
  - "Try focus mode during work hours"
  - "Set app timers for social media"

### 💬 AI Chatbot (NLP ditixBot)
- **Natural Conversations**: Human-like responses using advanced NLP
- **Empathetic Support**: Understands your emotional state from sentiment analysis
- **Chat History**: Persistent conversation history (last 100 messages)
- **Suggested Prompts**: Context-aware conversation starters
- **Collaborative AI**: Chat context shared with sentiment analysis for better understanding

## Setup Instructions

### Step 1: Get Your Free Google Gemini API Key

1. Visit [Google AI Studio](https://makersuite.google.com/app/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"**
4. Copy your API key

**Note**: Google Gemini offers a generous free tier with 60 requests per minute!

### Step 2: Add Your API Key to the App

1. Open `lib/core/services/ai_sentiment_service.dart`
2. Find line 23:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
3. Replace `'YOUR_GEMINI_API_KEY_HERE'` with your actual API key:
   ```dart
   static const String _apiKey = 'AIzaSyA...your-actual-key';
   ```

4. Open `lib/core/services/ai_chatbot_service.dart`
5. Find line 55:
   ```dart
   static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
   ```
6. Replace with the same API key

### Step 3: Rebuild the App

```bash
flutter clean
flutter pub get
flutter run
```

## How to Use

### Viewing AI Analysis

1. Open the app and navigate to the **Dashboard** tab
2. Scroll down to the **"AI Analysis"** section
3. View your sentiment breakdown and personalized recommendations

### Using the AI Chatbot

1. In the AI Analysis section, tap on **"Chat with AI Coach"**
2. The chat interface will expand
3. Options:
   - Type your own message
   - Tap on suggested prompts for quick starts
   - Ask about your digital wellbeing, habits, or productivity

### Example Conversations

**User**: "I'm feeling overwhelmed by notifications"
**AI**: "I understand that can be stressful. Try enabling Do Not Disturb mode during focus hours. Would you like me to help you set that up?"

**User**: "How's my screen time looking?"
**AI**: "You're at 3.2 hours today, which is 64% of your 5-hour goal. Great job staying on track! 🎉"

**User**: "Help me reduce screen time anxiety"
**AI**: "Let's break this down. First, remember that small steps matter more than perfection..."

## AI Integration Flow

```
┌─────────────────┐
│  User Activity  │
└────────┬────────┘
         │
         v
┌─────────────────────┐
│  Usage Data         │
│  - Screen Time      │
│  - Habits/Tasks     │
│  - Productivity     │
└────────┬────────────┘
         │
         v
┌──────────────────────┐       ┌──────────────────────┐
│  Sentiment Analysis  │◄─────►│  Chatbot NLP         │
│  (Gemini AI)         │       │  (Gemini AI)         │
└──────────┬───────────┘       └──────────┬───────────┘
           │                              │
           │   Shared Context             │
           └──────────────┬───────────────┘
                          │
                          v
           ┌──────────────────────────┐
           │  User Interface          │
           │  - Sentiment Display     │
           │  - Recommendations       │
           │  - Chat Interface        │
           └──────────────────────────┘
```

## Privacy & Security

- **API Key Storage**: API keys are stored in source code (for personal use)
  - For production apps, use environment variables or secure storage
- **Data Privacy**: Your usage data is only sent to Google Gemini for analysis
- **No Data Storage**: Google does not store your prompts when using their free tier API
- **Local History**: Chat history is stored locally on your device
- **Offline Support**: App works offline, AI features require internet connection

## Best Practices for API Keys

⚠️ **Security Warning**: Never commit API keys to public repositories!

**For Development**:
1. Keep your API key in the source files (as shown in setup)
2. Don't share your code publicly

**For Production**:
1. Use environment variables:
   ```dart
   static const String _apiKey = String.fromEnvironment('GEMINI_API_KEY');
   ```
2. Add to `.gitignore`:
   ```
   **/*.env
   **/api_keys.dart
   ```
3. Pass key during build:
   ```bash
   flutter build apk --dart-define=GEMINI_API_KEY=your_key_here
   ```

## Troubleshooting

### "AI Analysis Unavailable" Error
- **Cause**: Invalid or missing API key
- **Solution**: 
  1. Verify your API key is correctly added to both service files
  2. Check if the API key is active in Google AI Studio
  3. Ensure you have internet connection

### Chat Not Responding
- **Cause**: Rate limit exceeded or network issues
- **Solution**:
  1. Wait a few minutes (free tier: 60 requests/minute)
  2. Check internet connection
  3. Restart the app

### Sentiment Analysis Shows Default Values
- **Cause**: First run or API error
- **Solution**:
  1. Wait 6 hours for automatic refresh
  2. Force refresh by restarting the app
  3. Check API key configuration

### "Error sending message" in Chat
- **Cause**: Network timeout or API error
- **Solution**:
  1. Check internet connection
  2. Try shorter messages
  3. Clear chat history and retry

## API Usage Limits (Free Tier)

Google Gemini 1.5 Flash (Free):
- **Rate Limit**: 60 requests per minute
- **Daily Limit**: 1,500 requests per day
- **Model**: gemini-1.5-flash
- **Perfect For**: Personal use

### Typical Usage:
- Sentiment Analysis: 1 request every 6 hours = ~4/day
- Recommendations: 1 request per sentiment update = ~4/day
- Chat: ~20-50 messages/day
- **Total**: ~30-60 requests/day (well within limit!)

## Advanced Configuration

### Adjusting Update Frequency

Edit `lib/core/services/ai_sentiment_service.dart`:

```dart
// Change from 6 hours to your preference
if (now.difference(lastDate).inHours < 6) {  // ← Change this number
```

### Customizing AI Personality

Edit system instruction in `lib/core/services/ai_chatbot_service.dart`:

```dart
systemInstruction: Content.system('''
You are a [customize here]...
'''),
```

### Modifying Temperature (Creativity)

```dart
generationConfig: GenerationConfig(
  temperature: 0.9,  // ← 0.0 = factual, 1.0 = creative
  // ...
),
```

## Support

For issues or questions:
1. Check this guide first
2. Verify API key setup
3. Check Google AI Studio status
4. Report bugs via GitHub issues

## Credits

- **AI Model**: Google Gemini 1.5 Flash
- **Implementation**: Afjal Ansari
- **Base App**: NLP-Digitox (based on NLP ditix by Pawan Nagar)

---

**Enjoy your AI-powered digital wellbeing experience! 🎉**
