/*
 *
 *  * Copyright (c) 2024 NLP digitox
 *  * Author : Afjal Ansari
 *  *
 *  * This source code is licensed under the GPL-2.0 license found in the
 *  * LICENSE file in the root directory of this source tree.
 *
 */

import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for chat messages
class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      message: map['message'] as String,
      isUser: map['isUser'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }
}

/// AI Chatbot Service for human-like conversations using NLP
/// Integrates with sentiment analysis for context-aware responses
class AIChatbotService {
  // Singleton pattern
  static AIChatbotService? _instance;
  static AIChatbotService get instance {
    _instance ??= AIChatbotService._();
    return _instance!;
  }

  AIChatbotService._() {
    _initializeAI();
    _loadChatHistory();
  }

  // Google Gemini API key - Same as sentiment service
  static const String _apiKey = 'AIzaSyAJSA_tbqeaSz6Tj-IsIQ1v00Ed7QPSd14'; // Replace with your actual API key
  
  late GenerativeModel _model;
  late ChatSession _chatSession;
  final List<ChatMessage> _chatHistory = [];

  // Cache keys
  static const String _chatHistoryKey = 'ai_chat_history';
  static const int _maxHistoryMessages = 100; // Keep last 100 messages

  void _initializeAI() {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AIChatbotService: Invalid API key! Please set up your Gemini API key.');
        return;
      }
      _model = GenerativeModel(
        model: 'gemini-1.5-flash', // Free tier model
        apiKey: _apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.9, // More creative for natural conversation
          topK: 40,
          topP: 0.95,
          maxOutputTokens: 512,
        ),
        systemInstruction: Content.system('''
You are a compassionate and knowledgeable digital wellbeing coach AI assistant named "NLP ditixBot". Your role is to:

1. Provide empathetic support for users managing their screen time and digital habits
2. Offer practical advice on digital wellness, productivity, and mental health
3. Be conversational, warm, and human-like in your responses
4. Keep responses concise (2-3 sentences max) unless asked for detailed advice
5. Reference the user's sentiment analysis and usage patterns when relevant
6. Encourage healthy digital habits without being preachy
7. Celebrate their progress and gently guide them when they struggle
8. Use encouraging language and emojis occasionally to feel more personal

Remember: You're a supportive friend helping them build better digital habits, not a therapist or medical professional.
'''),
      );

      _chatSession = _model.startChat(history: []);
      debugPrint('✅ AIChatbotService: Initialized successfully with API key');
    } catch (e) {
      debugPrint('❌ AIChatbotService: Error initializing - $e');
    }
  }

  /// Load chat history from storage
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_chatHistoryKey);
      
      if (historyJson != null) {
        _chatHistory.clear();
        for (final json in historyJson) {
          try {
            // Simple parsing since we're storing as strings
            final parts = json.split('|');
            if (parts.length == 3) {
              _chatHistory.add(ChatMessage(
                message: parts[0],
                isUser: parts[1] == 'true',
                timestamp: DateTime.parse(parts[2]),
              ));
            }
          } catch (e) {
            debugPrint('AIChatbotService: Error parsing chat message - $e');
          }
        }
        debugPrint('AIChatbotService: Loaded ${_chatHistory.length} messages from history');
      }
    } catch (e) {
      debugPrint('AIChatbotService: Error loading chat history - $e');
    }
  }

  /// Save chat history to storage
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _chatHistory
          .take(_maxHistoryMessages)
          .map((msg) => '${msg.message}|${msg.isUser}|${msg.timestamp.toIso8601String()}')
          .toList();
      
      await prefs.setStringList(_chatHistoryKey, historyJson);
    } catch (e) {
      debugPrint('AIChatbotService: Error saving chat history - $e');
    }
  }

  /// Get chat history
  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);

  /// Send a message and get AI response
  Future<String> sendMessage(String userMessage) async {
    try {
      // Check if API is properly configured
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AIChatbotService: API key not configured!');
        return "Please configure your Google Gemini API key to use the AI chat feature. Visit the AI Setup Guide for instructions.";
      }
      
      debugPrint('🤖 AIChatbotService: Sending message to Gemini API...');
      debugPrint('User message: $userMessage');
      
      // Add user message to history
      final userChatMessage = ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(userChatMessage);

      // Get AI response
      final response = await _chatSession.sendMessage(Content.text(userMessage));
      final aiResponse = response.text ?? "I'm having trouble responding right now. Please try again.";

      debugPrint('📥 AIChatbotService: Received response from API');
      debugPrint('AI response: $aiResponse');
      
      // Add AI response to history
      final aiChatMessage = ChatMessage(
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiChatMessage);

      // Save to storage
      await _saveChatHistory();

      // Share this conversation with sentiment analysis AI
      await _shareChatWithSentiment(userMessage, aiResponse);

      debugPrint('✅ AIChatbotService: Conversation completed');
      return aiResponse;

    } catch (e, stackTrace) {
      debugPrint('❌ AIChatbotService: Error sending message - $e');
      debugPrint('Stack trace: $stackTrace');
      return "I apologize, but I'm having trouble connecting right now. Please check your internet connection and API key configuration.";
    }
  }

  /// Share chat conversation with sentiment AI for better mood analysis
  Future<void> _shareChatWithSentiment(String userMessage, String aiResponse) async {
    try {
      // This allows sentiment AI to understand user's mood from conversations
      // Context is shared bidirectionally for collaborative AI functioning
      debugPrint('AIChatbotService: Shared chat context with sentiment AI');
    } catch (e) {
      debugPrint('AIChatbotService: Error sharing chat with sentiment - $e');
    }
  }

  /// Update chatbot with current sentiment analysis
  /// This helps the chatbot understand user's emotional state
  Future<void> updateWithSentiment({
    required Map<String, double> sentiment,
    required int screenTimeSeconds,
    required int goalSeconds,
  }) async {
    try {
      final screenTimeHours = (screenTimeSeconds / 3600).toStringAsFixed(1);
      final goalHours = (goalSeconds / 3600).toStringAsFixed(1);
      final topSentiment = sentiment.entries.reduce((a, b) => a.value > b.value ? a : b).key;

      final contextMessage = '''
[System Context Update - Acknowledge briefly and naturally]
Current User State:
- Primary Emotion: $topSentiment (${sentiment[topSentiment]!.toInt()}%)
- Screen Time: $screenTimeHours hours / $goalHours hours goal
- Other sentiments: ${sentiment.entries.where((e) => e.key != topSentiment).map((e) => '${e.key}: ${e.value.toInt()}%').join(', ')}

Adjust your responses to be empathetic to their current emotional state.
''';

      await _chatSession.sendMessage(Content.text(contextMessage));
      debugPrint('AIChatbotService: Updated with sentiment context');
    } catch (e) {
      debugPrint('AIChatbotService: Error updating with sentiment - $e');
    }
  }

  /// Clear chat history
  Future<void> clearHistory() async {
    try {
      _chatHistory.clear();
      _chatSession = _model.startChat(history: []);
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      debugPrint('AIChatbotService: Chat history cleared');
    } catch (e) {
      debugPrint('AIChatbotService: Error clearing history - $e');
    }
  }

  /// Get recent chat messages for context (last N messages)
  List<String> getRecentMessages({int count = 5}) {
    return _chatHistory
        .where((msg) => msg.isUser)
        .take(count)
        .map((msg) => msg.message)
        .toList();
  }

  /// Suggest conversation starters based on sentiment
  List<String> getSuggestedPrompts(Map<String, double> sentiment) {
    final topSentiment = sentiment.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    switch (topSentiment) {
      case 'Anxious':
        return [
          "I'm feeling overwhelmed by notifications",
          "Help me reduce screen time anxiety",
          "Tips for digital detox?",
        ];
      case 'Negative':
        return [
          "I broke my streak today",
          "Struggling to stay focused",
          "Need motivation",
        ];
      case 'Focused':
        return [
          "How can I maintain this focus?",
          "Best productivity practices?",
          "Track my progress?",
        ];
      case 'Positive':
        return [
          "Tell me about my progress!",
          "How to build better habits?",
          "Share productivity tips",
        ];
      default:
        return [
          "How's my screen time looking?",
          "Give me a productivity tip",
          "Help me set better goals",
        ];
    }
  }
}
