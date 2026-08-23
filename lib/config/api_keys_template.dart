// Copyright (c) 2026 NLP digitox
//
// DEPRECATED — this template is no longer used.
//
// API keys are now supplied via the .env file at build time:
//   1. Copy .env.example to .env
//   2. Fill in your real keys in .env
//   3. Run/build with: flutter run --dart-define-from-file=.env
//
// See lib/config/api_keys.dart for how the values are read.

class ApiKeys {
  // Get your free Groq API key at: https://console.groq.com/keys
  static const String groqApiKey = 'YOUR_GROQ_API_KEY';

  // Get your free Gemini API key at: https://aistudio.google.com/apikey
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';
}
