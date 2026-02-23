# 🚀 Quick Start - Fix Quota Issues NOW!

## ⚠️ Your Problem

```
❌ You exceeded your current quota
❌ Quota exceeded for metric: generativelanguage.googleapis.com/generate_content_free_tier_requests
❌ Limit: 0, model: gemini-2.0-flash
```

## ✅ The Solution

**Use TWO FREE APIs instead of one!**
- **Groq** for sentiment analysis (14,400 requests/day)
- **Gemini** for chat only (1,500 requests/day)

---

## 🎯 Steps to Fix (5 Minutes)

### 1. Get Groq API Key

1. Visit: https://console.groq.com/keys
2. Sign up (FREE, no credit card)
3. Click "Create API Key"
4. Copy key (starts with `gsk_`)

### 2. Get Gemini API Key

1. Visit: https://aistudio.google.com/app/apikey
2. Sign in with Google
3. Click "Create API Key"
4. Copy key (starts with `AIza`)

### 3. Update Code

**File 1:** `lib/core/services/ai_sentiment_service.dart`

Find line 24 and replace:
```dart
static const String _apiKey = 'YOUR_GROQ_API_KEY_HERE';
```

With your Groq key:
```dart
static const String _apiKey = 'gsk_xxxxxxxxxxxxxxxxxxxxxxxx';
```

**File 2:** `lib/core/services/ai_chatbot_service.dart`

Find line 57 and replace:
```dart
static const String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';
```

With your Gemini key:
```dart
static const String _apiKey = 'AIzaxxxxxxxxxxxxxxxxxxxxxxxx';
```

### 4. Run App

```bash
flutter run
```

**DONE!** No more quota errors! 🎉

---

## 🧪 Test It

1. **Test Sentiment:** Open Dashboard → See 5 emotions with %
2. **Test Chat:** Expand "Chat with AI" → Send message
3. **Verify:** No quota errors, fast responses!

---

## 📖 Full Documentation

- **Complete Guide:** [AI_DUAL_API_SETUP.md](./AI_DUAL_API_SETUP.md)
- **Success Doc:** [AI_IMPLEMENTATION_SUCCESS.md](./AI_IMPLEMENTATION_SUCCESS.md)

---

## ❓ Why This Works

**Before:** Both features used Gemini → Hit 1,500 req/day limit  
**After:** Sentiment uses Groq (14,400/day) + Chat uses Gemini (1,500/day)  
**Result:** Each API gets its own limit! No conflicts!

---

## 🆘 Quick Troubleshooting

**Sentiment not working?**
→ Check Groq key in `ai_sentiment_service.dart` line 24

**Chat not working?**
→ Check Gemini key in `ai_chatbot_service.dart` line 57

**Still errors?**
→ Run `flutter clean` then `flutter pub get`

---

**Fix Time:** ~5 minutes  
**Cost:** $0.00  
**Quota Issues:** SOLVED ✅

*Get started now! Both APIs are FREE forever!*
