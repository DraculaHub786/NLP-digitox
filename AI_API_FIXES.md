# 🔧 AI API Fixes - Rate Limit & Error Solutions

## ✅ What Was Fixed

### 1. **Wrong Model Name** (CRITICAL FIX)
**Problem:** Both service files used `'gemini-2.0-flash'` which doesn't exist in the free tier.

**Fixed to:** `'gemini-1.5-flash'` (the correct free tier model)

**Files Updated:**
- `lib/core/services/ai_sentiment_service.dart` (Line 45)
- `lib/core/services/ai_chatbot_service.dart` (Line 73)

### 2. **Better Error Handling**
Added detailed error messages that tell you exactly what went wrong:
- ✅ Rate limit errors (429) → Shows how to fix
- ✅ Invalid API key errors (401) → Links to get new key
- ✅ Model errors → Shows correct model name
- ✅ Empty responses → Shows API feedback

---

## 🚨 Common Error: "Rate Limit Reached"

### Why This Happens
The free tier has these limits:
- **60 requests per minute**
- **1,500 requests per day**

Your app might hit these limits if:
1. You're testing the chatbot rapidly (multiple messages quickly)
2. The app is calling the API too frequently
3. Another app/person is using the same API key
4. The key's daily quota is exhausted

### ✅ Solutions (Try in Order)

#### Solution 1: Wait 1 Minute
The rate limit is **per minute**. Simply:
1. Close the app completely
2. Wait 60 seconds
3. Open the app again
4. Try using the AI features

#### Solution 2: Generate a New API Key
Your current key might be exhausted or shared:

1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. Click **"Create API key"**
3. Copy the new key (starts with `AIza...`)
4. Replace the old key in **both** files:

**File 1:** `lib/core/services/ai_sentiment_service.dart`
```dart
// Line 28 - Replace the API key:
static const String _apiKey = 'YOUR_NEW_KEY_HERE';
```

**File 2:** `lib/core/services/ai_chatbot_service.dart`
```dart
// Line 55 - Replace the API key:
static const String _apiKey = 'YOUR_NEW_KEY_HERE';
```

5. Run: `flutter run`

#### Solution 3: Reduce API Call Frequency
The app already has caching (sentiment updates every 6 hours), but you can:

1. **Don't spam the chatbot** - Wait 5-10 seconds between messages
2. **Clear cached data** if sentiment keeps re-calling API:
   ```bash
   # Clear app data on Android
   # Settings → Apps → NLP digitox → Storage → Clear Data
   ```

#### Solution 4: Check Your Quota Usage
1. Visit [Google AI Studio](https://aistudio.google.com/)
2. Go to your API keys section
3. Check usage statistics
4. See if you've hit the 1,500/day limit
5. If yes, wait until tomorrow (resets at midnight UTC)

---

## 🐛 Other Common Errors

### Error: "Invalid API Key"
**Symptoms:** Chatbot says "Invalid API key" or shows 401 error

**Causes:**
- API key is incorrect (typo, extra spaces, wrong quotes)
- API key was deleted/disabled in Google AI Studio
- Using the placeholder `'YOUR_GEMINI_API_KEY_HERE'`

**Fix:**
1. Generate a new API key (see Solution 2 above)
2. Make sure no extra spaces: `'AIza...'` ✅ (not `' AIza...'` ❌)
3. Use single quotes: `'AIza...'` ✅ (not `"AIza..."` ❌)

### Error: "Model Not Found"
**Symptoms:** Error mentions model name or 404

**Fix:** ✅ Already fixed! We changed to `gemini-1.5-flash`

If still seeing this:
```dart
// Verify this line in both service files:
model: 'gemini-1.5-flash',  // Must be exactly this
```

### Error: "Empty Response from API"
**Symptoms:** AI returns nothing or default values

**Causes:**
- Your prompt might violate content policies
- API returned blocked response
- Network issues

**Fix:**
1. Check debug console for "Prompt feedback" messages
2. Try a different question/prompt
3. Check your internet connection
4. Wait a minute and try again

### Error: Sentiment Shows All 0% or Defaults (40%, 30%, 10%, 10%, 10%)
**Symptoms:** Sentiment analysis doesn't show real values

**This means:**
- API key not configured → Add your key
- API error occurred → Check debug logs
- Not enough usage data → Use the app more

**Not an error if:**
- You just installed the app (no data yet)
- You haven't used apps/completed tasks today

---

## 🔍 How to Debug

### Check Debug Logs
Run the app from terminal to see detailed logs:

```powershell
flutter run
```

Look for these log messages:
- ✅ `✅ AISentimentService: Initialized successfully` → Good!
- ❌ `❌ AISentimentService: Error initializing` → API key issue
- ⚠️ `⚠️ API QUOTA/RATE LIMIT ERROR` → Hit rate limits
- ⚠️ `⚠️ INVALID API KEY ERROR` → Bad API key
- 🤖 `🤖 AISentimentService: Calling Gemini API` → API call started
- 📥 `📥 AISentimentService: Received response` → API call succeeded

### Test Each Feature Separately

**Test 1: Sentiment Analysis**
1. Open the app → Go to Dashboard
2. Look for "AI Analysis" section
3. Wait 5-10 seconds for it to load
4. Check debug logs for errors

**Test 2: Chatbot**
1. Tap "Chat with AI" to expand
2. Try a simple message: "Hello"
3. Wait for response (2-5 seconds)
4. Check debug logs for errors

---

## 🎯 Recommended Settings

To avoid hitting rate limits, the app is already configured with:

### Sentiment Analysis Caching
```dart
// Updates only once every 6 hours
if (now.difference(lastDate).inHours < 6) {
  // Return cached analysis
}
```
✅ This saves ~240 API calls per day!

### Chat History Limit
```dart
// Keeps only last 100 messages
static const int _maxHistoryMessages = 100;
```
✅ Prevents excessive context in API calls

### Conservative Token Limits
```dart
maxOutputTokens: 1024,  // Sentiment
maxOutputTokens: 512,   // Chatbot
```
✅ Reduces API costs and speeds up responses

---

## 💡 Pro Tips

### 1. Use Multiple API Keys (If Needed)
If you're a heavy user, create 2-3 API keys and rotate them:
```dart
// Rotate between keys
static const List<String> _apiKeys = [
  'AIza...key1',
  'AIza...key2',
  'AIza...key3',
];
static String get _apiKey => _apiKeys[DateTime.now().day % _apiKeys.length];
```

### 2. Test in Debug Mode
Before releasing updates, test AI features in debug mode:
```bash
flutter run --debug
```
Watch console logs to catch errors early.

### 3. Environment Variables (Advanced)
For better security, use environment variables:

**.env file:**
```
GEMINI_API_KEY=AIza...your_key
```

**lib/core/services/config.dart:**
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Config {
  static String get geminiApiKey => dotenv.env['GEMINI_API_KEY'] ?? '';
}
```

**pubspec.yaml:**
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

Then use: `static String _apiKey = Config.geminiApiKey;`

### 4. Monitor Your Usage
Create a simple counter to track API calls:
```dart
static int _apiCallsToday = 0;

Future<void> _trackApiCall() async {
  _apiCallsToday++;
  debugPrint('📊 API Calls Today: $_apiCallsToday / 1500');
  
  if (_apiCallsToday > 1400) {
    debugPrint('⚠️ WARNING: Approaching daily limit!');
  }
}
```

---

## 📞 Still Having Issues?

### Quick Checklist
- [ ] Model name is `'gemini-1.5-flash'` in both files
- [ ] API key starts with `AIza` and has no spaces
- [ ] API key is in both service files (sentiment + chatbot)
- [ ] You've waited 60 seconds after hitting rate limit
- [ ] Internet connection is working
- [ ] You haven't exceeded 1,500 requests today
- [ ] You've run `flutter clean` and `flutter pub get`

### Try Clean Rebuild
```powershell
flutter clean
flutter pub get
flutter run
```

### Last Resort: Fresh API Key
1. Go to [Google AI Studio](https://aistudio.google.com/app/apikey)
2. **Delete old API key** (if you suspect it's exhausted)
3. Create a completely new API key
4. Update both service files
5. Restart the app

---

## 📚 Additional Resources

- **Google AI Studio:** https://aistudio.google.com/
- **API Key Management:** https://aistudio.google.com/app/apikey
- **Gemini API Docs:** https://ai.google.dev/docs
- **Rate Limits Info:** https://ai.google.dev/pricing
- **Model List:** https://ai.google.dev/models/gemini

---

## ✅ Verification Steps

After applying fixes:

1. **Check Compilation**
   ```bash
   flutter analyze
   ```
   Should show: ✅ No issues found!

2. **Test Sentiment**
   - Open Dashboard
   - See real percentages (not all defaults)
   - Check debug logs for "✅ Sentiment analysis completed"

3. **Test Chatbot**
   - Send message: "Hello"
   - Get AI response within 5 seconds
   - No rate limit errors in logs

4. **Verify Model**
   ```bash
   # Search for model name in both files
   grep -n "model:" lib/core/services/ai_*
   ```
   Should show: `gemini-1.5-flash` (not `gemini-2.0-flash`)

---

**Status after fixes:**
- ✅ Model name corrected to `gemini-1.5-flash`
- ✅ Enhanced error messages with solutions
- ✅ Better debugging information
- ✅ Rate limit detection and guidance
- ✅ Empty response handling

**Your AI integration should now work properly!** 🎉

If you still see "rate limit reached" after these fixes:
1. Wait 60 seconds ⏱️
2. Generate a new API key 🔑
3. Check your daily quota usage 📊
