# AI Features - Quick Start

## 🚀 Get Started in 3 Steps

### 1. Get API Key (2 minutes)
Visit: https://makersuite.google.com/app/apikey
- Sign in with Google
- Click "Create API Key"
- Copy the key

### 2. Add API Key to App
Edit TWO files and replace `YOUR_GEMINI_API_KEY_HERE`:

**File 1**: `lib/core/services/ai_sentiment_service.dart` (Line 23)
```dart
static const String _apiKey = 'YOUR_KEY_HERE';
```

**File 2**: `lib/core/services/ai_chatbot_service.dart` (Line 55)
```dart
static const String _apiKey = 'YOUR_KEY_HERE';
```

### 3. Rebuild & Run
```bash
flutter clean
flutter pub get
flutter run
```

## ✨ Features Overview

### 📊 Sentiment Analysis
- 5 emotions tracked: Positive, Neutral, Negative, Anxious, Focused
- Updates every 6 hours
- Based on your screen time, habits, and productivity

### 💡 AI Recommendations
- 3-4 personalized tips
- Considers your current mood and usage patterns
- Actionable suggestions

### 💬 AI Chatbot
- Tap "Chat with AI" in dashboard
- Natural conversations
- Ask anything about digital wellbeing
- Context-aware (knows your usage patterns)

## 🎯 Quick Tips

**Chat Prompts to Try:**
- "How's my screen time looking?"
- "I'm feeling overwhelmed by notifications"
- "Help me reduce screen time anxiety"
- "Give me productivity tips"
- "How do I build better habits?"

**Sentiment Colors:**
- 🟢 Green = Positive
- 🟠 Orange = Neutral
- 🔴 Red = Negative
- 🟠 Deep Orange = Anxious
- 🔵 Blue = Focused

## 🔒 Privacy

✅ Your data stays private
✅ No data stored by Google (free tier)
✅ Chat history stored locally on your device
✅ Requires internet for AI features

## 📋 Free Tier Limits

Google Gemini Free:
- ✅ 60 requests/minute
- ✅ 1,500 requests/day
- ✅ Perfect for personal use
- ✅ No credit card required

Typical daily usage: ~30-60 requests (well within limits!)

## ❓ Troubleshooting

**"AI Analysis Unavailable"**
→ Check API key is added correctly in BOTH files

**Chat not responding**
→ Check internet connection
→ Wait a minute if rate limit hit

**Default sentiment values showing**
→ Normal on first run
→ Will update after 6 hours

## 📖 Full Guide

For detailed setup, security best practices, and advanced configuration:
See `AI_SETUP_GUIDE.md`

---

**Need Help?** Check the complete setup guide or report issues on GitHub.
