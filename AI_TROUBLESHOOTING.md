# AI Features Troubleshooting Guide

## Problem: Sentiment Analysis and Tips Show Defaults (Not Real AI)

### Symptoms:
- ✗ Sentiment shows same percentages every time (40% Positive, 30% Neutral, etc.)
- ✗ Tips are generic default messages
- ✗ AI Chat doesn't respond or shows error message

### Root Cause:
The Google Gemini API is either:
1. **Not configured properly** (API key invalid)
2. **Network connectivity issues**
3. **API quota exceeded**
4. **API key doesn't have Gemini API enabled**

## Solution Steps:

### Step 1: Verify Your API Key

1. Go to [Google AI Studio](https://aistudio.google.com/apikey)
2. Sign in with your Google account
3. Click **"Create API Key"** or use existing key
4. **Copy the ENTIRE key** (should start with `AIzaSy...`)

### Step 2: Replace API Key in BOTH Files

#### File 1: ai_sentiment_service.dart
```dart
// Line 31 in: lib/core/services/ai_sentiment_service.dart
static const String _apiKey = 'AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14';
                                    ↓ REPLACE WITH YOUR KEY ↓
static const String _apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

#### File 2: ai_chatbot_service.dart
```dart
// Line 60 in: lib/core/services/ai_chatbot_service.dart
static const String _apiKey = 'AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14';
                                    ↓ REPLACE WITH YOUR KEY ↓
static const String _apiKey = 'AIzaSyXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX';
```

### Step 3: Enable Gemini API

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Search for "Generative Language API" or "Gemini API"
4. Click **"Enable"**

### Step 4: Clear App Cache & Rebuild

```bash
# Stop the app if running
flutter clean
flutter pub get
flutter run
```

### Step 5: Check Logs After Launch

Look for these messages in the console:

#### ✅ SUCCESS:
```
✅ AISentimentService: Initialized successfully with API key
🧪 AISentimentService: Testing API connection...
✅ AISentimentService: API connection successful! Response: OK
```

#### ❌ FAILURE:
```
❌ AISentimentService: API connection test failed!
Error: [DETAILED ERROR MESSAGE]
```

## Common Error Messages & Solutions:

### Error: "API_KEY_INVALID"
**Solution:** Your API key is wrong. Copy it again from AI Studio.

### Error: "PERMISSION_DENIED" 
**Solution:** Enable the Generative Language API in Google Cloud Console.

### Error: "QUOTA_EXCEEDED"
**Solution:** You've exceeded the free tier limits (60 requests/min). Wait or upgrade.

### Error: "Failed to connect"
**Solution:** Check your device/emulator has internet connection.

### Error: "Model not found"
**Solution:** The model name is wrong. Ensure it's `gemini-1.5-flash`.

## Testing the API Manually:

To test if your API key works, visit this URL in your browser:
```
https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=YOUR_API_KEY_HERE

POST body:
{
  "contents": [{
    "parts":[{
      "text": "Hello, are you working?"
    }]
  }]
}
```

If you get a JSON response with text, your API key works!

## Security Note:

⚠️ **IMPORTANT:** The API key in your code is VISIBLE. For production:
1. Never commit API keys to public repositories
2. Use environment variables or secure storage
3. Implement backend API proxy for production apps

Current key in your code: `AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14`
👆 If this is a real key and your repo is public, REVOKE IT IMMEDIATELY!

## Still Not Working?

If AI features still show defaults after following all steps:

1. Check the Flutter console for detailed error messages
2. Verify internet connection on your device/emulator
3. Try creating a completely new API key
4. Check if Google AI Studio shows your API key has any restrictions
5. Ensure you're not hitting rate limits (wait 1 minute and try again)

## Contact Support:

If none of these work, copy the error messages from the Flutter console and:
- Check the GitHub issues
- Contact developers with the exact error message

---

**Quick Test:** Open the app, go to Dashboard, tap "Chat with AI", type "hello". 
- ✅ If you get a response → AI is working!
- ❌ If you get "Please configure your API key..." → Follow steps above
