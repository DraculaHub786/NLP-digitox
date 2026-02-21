⚠️ **SECURITY WARNING - API KEY EXPOSED** ⚠️

# Current Security Issue

Your Google Gemini API key is currently **hardcoded** in the source code:

- File: `lib/core/services/ai_sentiment_service.dart` (Line 31)
- File: `lib/core/services/ai_chatbot_service.dart` (Line 60)
- Current Key: `AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14`

## ⚠️ IMMEDIATE ACTION REQUIRED

Since this code is being pushed to GitHub:

1. **If your GitHub repo is PUBLIC:**
   - Go to https://aistudio.google.com/apikey
   - **DELETE/REVOKE** the current API key immediately
   - Create a new API key
   - Do NOT commit the new key to the repository

2. **If your GitHub repo is PRIVATE:**
   - Still not best practice, but less critical
   - Consider implementing proper security (see below)

## 🔒 Recommended Security Solutions

### Option 1: Environment Variables (Recommended)
Never commit API keys to Git. Use environment variables instead.

### Option 2: Local Configuration File
Create a file that's ignored by git:
```dart
// lib/config/api_keys.dart (add to .gitignore)
class ApiKeys {
  static const String geminiApiKey = 'YOUR_KEY_HERE';
}
```

Then in your .gitignore:
```
**/api_keys.dart
```

### Option 3: Backend Proxy (Production Recommended)
For production apps, implement a backend API that:
- Stores the API key securely on your server
- Your app calls your backend
- Your backend calls Google Gemini API
- Much more secure and allows monitoring/rate limiting

## 🚨 What Happens If Exposed?

- Anyone can use your API key
- You'll hit rate limits quickly
- You'll be charged if they exceed free tier
- Potential abuse of your Google Cloud account

## ✅ Quick Fix for This Repo

After pushing, if public:
1. Revoke the current key at https://aistudio.google.com/apikey
2. Create new key
3. Configure locally only (never commit)
4. Add instructions in README for others to set up their own keys

---
**Status:** API key currently EXPOSED in source code
**Risk Level:** HIGH if public repo, MEDIUM if private repo
**Action:** Revoke and replace with secure solution
