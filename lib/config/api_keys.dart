// Copyright (c) 2026 NLP digitox
//
// API Keys Configuration
//
// Keys are injected at COMPILE TIME from the .env file via:
//   flutter run --dart-define-from-file=.env
//   flutter build apk --dart-define-from-file=.env
//
// The .env file itself is gitignored and is never bundled into the app.
// See .env.example for the list of required variables.

class ApiKeys {
  /// Groq API key — get a free one at https://console.groq.com/keys
  static const String groqApiKey = String.fromEnvironment('GROQ_API_KEY');

  /// Gemini API key — get one at https://aistudio.google.com/apikey
  static const String geminiApiKey = String.fromEnvironment('GEMINI_API_KEY');
}
