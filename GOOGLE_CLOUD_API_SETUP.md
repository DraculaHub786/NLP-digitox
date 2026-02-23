# Setting Up Gemini API via Google Cloud Console

Since you already have a Google Cloud project for Firebase Auth, you can use the same project for the Gemini API.

## Method 1: Using Google Cloud Console (Recommended for Your Case)

### Step 1: Enable the Generative Language API

1. Go to **Google Cloud Console**: https://console.cloud.google.com/
2. **Select your Firebase project** (the one you're using for authentication)
3. In the search bar at the top, type: **"Generative Language API"**
4. Click on **"Generative Language API"** in the results
5. Click the **"ENABLE"** button
6. Wait for it to enable (takes a few seconds)

### Step 2: Create an API Key

1. In Google Cloud Console, go to: https://console.cloud.google.com/apis/credentials
2. Make sure your Firebase project is selected at the top
3. Click **"+ CREATE CREDENTIALS"** at the top
4. Select **"API key"**
5. A popup will show your new API key - **COPY IT IMMEDIATELY**
6. (Optional) Click **"RESTRICT KEY"** to add security:
   - Under "API restrictions", select "Restrict key"
   - Check **"Generative Language API"**
   - Click **"SAVE"**

### Step 3: Verify the API Key

Use this PowerShell command to test:

```powershell
$apiKey = "YOUR_NEW_KEY_HERE"
$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=$apiKey"
$body = @{contents = @(@{parts = @(@{text = "Say OK if working"})})} | ConvertTo-Json -Depth 10
Invoke-RestMethod -Uri $url -Method POST -Body $body -ContentType "application/json"
```

If it returns a response, the key is working!

---

## Method 2: Using Google AI Studio (Simpler but Less Control)

If the above doesn't work, use Google AI Studio:

1. Go to: https://aistudio.google.com/app/apikey
2. Click **"Create API Key"**
3. Select **"Create API key in existing project"**
4. Choose your Firebase project from the dropdown
5. Copy the generated key

---

## Which Project to Use?

### ✅ Use Your Existing Firebase Project If:
- You want all services in one place
- You want to monitor API usage alongside Firebase
- You want unified billing

### ✅ Create a New Project If:
- You want to separate concerns
- You want different billing/quotas
- You're worried about hitting limits

**Recommendation**: Use your existing Firebase project for simplicity.

---

## After Getting the API Key

Replace the key in BOTH files:

1. **lib/core/services/ai_sentiment_service.dart** (line 32)
2. **lib/core/services/ai_chatbot_service.dart** (line 58)

```dart
static const String _apiKey = 'YOUR_NEW_WORKING_KEY';
```

Then run:
```bash
flutter clean
flutter pub get
flutter run
```

---

## Troubleshooting

### Error: "API_KEY_INVALID" or 404
- Key is wrong or deleted
- Generate a new one

### Error: "PERMISSION_DENIED" or 403
- Generative Language API not enabled
- Go back to Step 1 and enable it

### Error: "RESOURCE_EXHAUSTED" or 429
- You've hit the rate limit (60 requests/minute)
- Wait 1 minute and try again

### Error: "User location is not supported"
- Gemini API might not be available in your region
- Try using a VPN or wait for availability

---

## Free Tier Limits

- **60 requests per minute**
- **1,500 requests per day**
- **Free forever** (as of 2026)

Your app's usage (~30-60 requests/day) is well within limits!
