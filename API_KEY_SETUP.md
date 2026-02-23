# API Key Setup Instructions

## 🔑 Setting Up Your Groq API Key

### Step 1: Get Your API Key
1. Visit [Groq Console](https://console.groq.com/keys)
2. Sign up or log in
3. Create a new API key
4. Copy the key (starts with `gsk_`)

### Step 2: Add Key to Your Project

**Option A: Direct Code Update (Quick Start)**
1. Open `lib/core/services/ai_chatbot_service.dart`
2. Find line with `_apiKey = 'YOUR_GROQ_API_KEY_HERE'`
3. Replace with your actual key: `_apiKey = 'gsk_your_actual_key_here'`
4. Open `lib/core/services/ai_sentiment_service.dart`
5. Find line with `_apiKey = 'YOUR_GROQ_API_KEY_HERE'`
6. Replace with your actual key: `_apiKey = 'gsk_your_actual_key_here'`

**⚠️ Important:** 
- Never commit your API key to GitHub
- Add your modified files to `.gitignore` if sharing code
- Use environment variables for production

### Step 3: Verify Setup
Run the test script to verify your API key works:
```bash
dart test_groq_chat.dart
```

You should see a successful response with the answer to "Who is the PM of India?"

## 📊 API Limits (Free Tier)
- **Rate Limit**: 30 requests per minute
- **Daily Limit**: 14,400 requests per day
- **Model**: llama-3.1-8b-instant
- **Cost**: 100% FREE

## 🔒 Security Best Practices
1. Never commit API keys to version control
2. Use environment variables in production
3. Rotate keys periodically
4. Monitor usage at https://console.groq.com/

## 🆘 Troubleshooting
- **Invalid API Key**: Double-check you copied the entire key
- **Rate Limit**: Wait 1 minute between heavy usage
- **Not Working**: Ensure key is properly pasted without extra spaces
