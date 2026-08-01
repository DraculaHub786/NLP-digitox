// Copyright (c) 2024 NLP digitox

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:nlp_digitox/core/services/ai_sentiment_service.dart';
import 'package:nlp_digitox/core/services/chat_context_extractor.dart';
import 'package:nlp_digitox/core/services/persona_service.dart';
import 'package:nlp_digitox/core/services/sentiment_persistence_service.dart';
import 'package:nlp_digitox/models/persona_model.dart';
import 'package:nlp_digitox/config/api_keys.dart';

/// Model for chat messages with editing and deletion support
class ChatMessage {
  final String id; // Unique identifier for editing/deletion
  final String message;
  final bool isUser;
  final DateTime timestamp;
  final bool isEdited;

  ChatMessage({
    String? id,
    required this.message,
    required this.isUser,
    required this.timestamp,
    this.isEdited = false,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'message': message,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'isEdited': isEdited,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] as String?,
      message: map['message'] as String,
      isUser: map['isUser'] as bool,
      timestamp: DateTime.parse(map['timestamp'] as String),
      isEdited: map['isEdited'] as bool? ?? false,
    );
  }

  ChatMessage copyWith({
    String? id,
    String? message,
    bool? isUser,
    DateTime? timestamp,
    bool? isEdited,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      message: message ?? this.message,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

/// Model for chat sessions
class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime lastMessageAt;
  final List<ChatMessage> messages;

  ChatSession({
    String? id,
    required this.title,
    required this.createdAt,
    required this.lastMessageAt,
    required this.messages,
  }) : id = id ?? DateTime.now().millisecondsSinceEpoch.toString();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
      'lastMessageAt': lastMessageAt.toIso8601String(),
      'messages': messages.map((m) => m.toMap()).toList(),
    };
  }

  factory ChatSession.fromMap(Map<String, dynamic> map) {
    return ChatSession(
      id: map['id'] as String?,
      title: map['title'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastMessageAt: DateTime.parse(map['lastMessageAt'] as String),
      messages: (map['messages'] as List)
          .map((m) => ChatMessage.fromMap(m as Map<String, dynamic>))
          .toList(),
    );
  }

  ChatSession copyWith({
    String? id,
    String? title,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    List<ChatMessage>? messages,
  }) {
    return ChatSession(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      messages: messages ?? this.messages,
    );
  }
}

/// AI Chatbot Service for conversational support using Groq API
/// Integrates with sentiment analysis for context-aware responses
class AIChatbotService {
  static AIChatbotService? _instance;
  static AIChatbotService get instance {
    _instance ??= AIChatbotService._();
    return _instance!;
  }

  AIChatbotService._() {
    _initialize();
  }

  bool _initialized = false;
  
  /// Initialize service in correct order
  Future<void> _initialize() async {
    if (_initialized) return;
    
    await _initializeAI();
    await _loadChatHistory();
    await _startNewSessionOnAppOpen();
    
    _initialized = true;
    debugPrint('✅ AIChatbotService fully initialized');
  }

  static final String _apiKey = ApiKeys.groqApiKey;
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  static const String _modelName = 'llama-3.1-8b-instant';
  
  final List<Map<String, String>> _conversationHistory = [];
  final List<ChatMessage> _chatHistory = [];
  final List<ChatSession> _chatSessions = [];
  String? _currentSessionId;

  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _chatSessionsKey = 'ai_chat_sessions';
  static const String _currentSessionKey = 'ai_current_session';
  static const int _maxHistoryMessages = 100;
  static const int _autoDeletionDays = 30;
  
  DateTime? _lastRequestTime;
  static const Duration _minRequestInterval = Duration(seconds: 2);
  int _consecutiveErrors = 0;
  int _requestsToday = 0;
  DateTime? _lastResetDate;
  static const int _maxRequestsPerDay = 14000;
  
  int _messagesSinceLastSentiment = 0;
  static const int _sentimentContextInterval = 3;
  
  int _messagesInCurrentSession = 0;
  static const int _maxMessagesPerSession = 15;

  /// Ensure initialization is complete before operations
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await _initialize();
    }
  }

  Future<void> _initializeAI() async {
    try {
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AIChatbotService: Invalid API key! Please set up your Groq API key.');
        return;
      }

      // Load persona for system prompt personalisation
      final personaProfile = await PersonaService.instance.getPersona();
      final personaSection = personaProfile != null ? '''
=== USER PROFILE ===
Persona type: ${personaProfile.persona.displayName}
Occupation context: ${personaProfile.answers['occupation'] ?? 'not provided'}
Primary wellness goal: ${personaProfile.answers['primary_goal'] ?? 'not provided'}
Biggest digital distraction: ${personaProfile.answers['biggest_distraction'] ?? 'not provided'}
Typical phone usage time: ${personaProfile.answers['usage_time'] ?? 'not provided'}
Preferred motivation style: ${personaProfile.answers['motivation'] ?? 'not provided'}
=== END PROFILE ===

Tailor all responses, tone, examples, and advice to this specific user.
For example:
- If persona is 'The Optimizer': use work-focus examples, productivity-oriented
- If persona is 'The Caretaker': emphasise family time and modelling healthy habits for others
- If persona is 'The Explorer': suggest depth over breadth, curiosity-guided growth
- If persona is 'The Rebel': frame advice as choices, never commands
- If persona is 'The Avoider': be gentle, encouraging, never shaming
''' : '(No user profile yet — give general digital wellness advice)';
      
      _conversationHistory.add({
        'role': 'system',
        'content': '''
You are a compassionate digital wellbeing assistant named "ditixBot". Your role is to:

1. Provide empathetic support for users managing their screen time and digital habits
2. Offer practical advice on digital wellness, productivity, and mental health
3. Be conversational, warm, and human-like in your responses
4. Keep responses concise (2-3 sentences max) unless asked for detailed advice
5. Use the sentiment analysis context provided to personalize your responses
6. Encourage healthy digital habits without being preachy
7. Celebrate their progress and gently guide them when they struggle
8. Use encouraging language and emojis occasionally to feel more personal

Important: When context about the user's emotional state is provided, acknowledge it naturally and adjust your tone accordingly.

$personaSection

Remember: You're a supportive friend helping them build better digital habits, not a therapist or medical professional.
'''
      });
      
      debugPrint('✅ AIChatbotService: Initialized successfully with Groq API (30 RPM, 14,400 RPD) — persona: ${personaProfile?.persona.displayName ?? "none"}');
    } catch (e) {
      debugPrint('❌ AIChatbotService: Error initializing - $e');
    }
  }

  /// Load chat history and sessions from storage
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load chat sessions
      final sessionsJson = prefs.getString(_chatSessionsKey);
      if (sessionsJson != null) {
        final sessionsList = json.decode(sessionsJson) as List;
        _chatSessions.clear();
        for (final sessionMap in sessionsList) {
          _chatSessions.add(ChatSession.fromMap(sessionMap as Map<String, dynamic>));
        }
        debugPrint('AIChatbotService: Loaded ${_chatSessions.length} chat sessions');
      }
      
      _currentSessionId = prefs.getString(_currentSessionKey);
      
      final historyJson = prefs.getStringList(_chatHistoryKey);
      if (historyJson != null && historyJson.isNotEmpty) {
        _chatHistory.clear();
        for (final json in historyJson) {
          try {
            final parts = json.split('|');
            if (parts.length >= 3) {
              _chatHistory.add(ChatMessage(
                id: parts.length > 3 ? parts[3] : null,
                message: parts[0],
                isUser: parts[1] == 'true',
                timestamp: DateTime.parse(parts[2]),
                isEdited: parts.length > 4 ? parts[4] == 'true' : false,
              ));
            }
          } catch (e) {
            debugPrint('AIChatbotService: Error parsing chat message - $e');
          }
        }
        debugPrint('AIChatbotService: Loaded ${_chatHistory.length} messages from history');
      }
      
      // ✅ FIX: Remove empty sessions on load
      _chatSessions.removeWhere((session) => session.messages.isEmpty);
      debugPrint('🧹 Cleaned up empty sessions. Total sessions: ${_chatSessions.length}');
      
      await _autoDeleteOldChats();
      
    } catch (e) {
      debugPrint('AIChatbotService: Error loading chat history - $e');
    }
  }

  /// Start a new session when app opens
  Future<void> _startNewSessionOnAppOpen() async {
    try {
      // ✅ FIX: Clean up - remove any empty sessions from memory
      _chatSessions.removeWhere((s) => s.messages.isEmpty);
      
      // If we have a current session with messages, save it
      if (_currentSessionId != null && _chatHistory.isNotEmpty) {
        await _saveCurrentSessionToHistory();
        debugPrint('📝 Saved previous session with ${_chatHistory.length} messages');
      }
      
      // Always clear current chat to start fresh
      _chatHistory.clear();
      _conversationHistory.clear();
      await _initializeAI();
      
      // ✅ FIX: Create session ID but DON'T add empty session to list
      // Session will be added to _chatSessions when first message is sent via _saveCurrentSessionToHistory()
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      debugPrint('✅ Ready for new chat session: $_currentSessionId | Total saved sessions: ${_chatSessions.where((s) => s.messages.isNotEmpty).length}');
    } catch (e) {
      debugPrint('❌ Error starting new session on app open: $e');
    }
  }

  /// Save chat history and sessions to storage
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final historyJson = _chatHistory
          .take(_maxHistoryMessages)
          .map((msg) => '${msg.message}|${msg.isUser}|${msg.timestamp.toIso8601String()}|${msg.id}|${msg.isEdited}')
          .toList();
      await prefs.setStringList(_chatHistoryKey, historyJson);
      
      // ✅ FIX: Only save sessions that have at least one message
      final nonEmptySessions = _chatSessions.where((s) => s.messages.isNotEmpty).toList();
      final sessionsJson = json.encode(
        nonEmptySessions.map((s) => s.toMap()).toList(),
      );
      await prefs.setString(_chatSessionsKey, sessionsJson);
      
      // ✅ FIX: Only save current session ID if it has messages
      if (_currentSessionId != null && _chatHistory.isNotEmpty) {
        await prefs.setString(_currentSessionKey, _currentSessionId!);
      } else {
        // Clear saved session ID if current session is empty
        await prefs.remove(_currentSessionKey);
      }
      
      debugPrint('💾 Saved ${nonEmptySessions.length} non-empty sessions (skipped ${_chatSessions.length - nonEmptySessions.length} empty sessions)');
    } catch (e) {
      debugPrint('AIChatbotService: Error saving chat history - $e');
    }
  }
  
  /// Reset chat session to prevent unbounded history growth
  /// This helps stay within token limits by clearing the session's internal history
  Future<void> _resetChatSession() async {
    try {
      if (_conversationHistory.isEmpty) {
        await _initializeAI();
        _messagesInCurrentSession = 0;
        return;
      }
      // Keep system message + last 6 user/assistant exchanges (12 messages)
      final systemMsg = _conversationHistory.first; // System message
      final recentMsgs = _conversationHistory.length > 13
          ? _conversationHistory.sublist(_conversationHistory.length - 12)
          : _conversationHistory.sublist(1); // Skip system msg if recreating
      
      _conversationHistory.clear();
      _conversationHistory.add(systemMsg);
      _conversationHistory.addAll(recentMsgs);
      _messagesInCurrentSession = 0;
      
      debugPrint('✅ Chat session reset. Retained last ${recentMsgs.length} messages for context.');
    } catch (e) {
      debugPrint('❌ Error resetting chat session: $e');
      // Fallback: reinitialize
      _conversationHistory.clear();
      await _initializeAI();
      _messagesInCurrentSession = 0;
    }
  }

  /// Get chat history
  List<ChatMessage> get chatHistory {
    // Trigger initialization if not done (will complete async)
    if (!_initialized) {
      _initialize();
    }
    return List.unmodifiable(_chatHistory);
  }

  /// Send a message and get AI response with rate limiting and optimization
  Future<String> sendMessage(String userMessage) async {
    await _ensureInitialized();
    
    try {
      // Check if API is properly configured
      if (_apiKey.isEmpty || _apiKey.contains('YOUR_')) {
        debugPrint('⚠️ AIChatbotService: API key not configured!');
        return "Please configure your Groq API key to use the AI chat feature. Visit https://console.groq.com/keys for setup.";
      }
      
      // RATE LIMITING: Enforce minimum delay between requests
      // Also check daily quota
      final now = DateTime.now();
      if (_lastResetDate == null || _lastResetDate!.day != now.day) {
        _requestsToday = 0;
        _lastResetDate = now;
        debugPrint('🔄 Daily request counter reset');
      }
      
      if (_requestsToday >= _maxRequestsPerDay) { // Safety limit below 14,400 RPD
        debugPrint('⛔ Daily quota reached ($_requestsToday/$_maxRequestsPerDay). Try again tomorrow.');
        return "⛔ Daily API limit reached. Groq free tier allows 14,400 requests/day. Please try again tomorrow.";
      }
      
      if (_lastRequestTime != null) {
        final timeSinceLastRequest = now.difference(_lastRequestTime!);
        if (timeSinceLastRequest < _minRequestInterval) {
          final waitTime = _minRequestInterval - timeSinceLastRequest;
          debugPrint('⏱️ Rate limiting: Waiting ${waitTime.inSeconds}s before next request... (Request ${_requestsToday + 1}/$_maxRequestsPerDay today)');
          await Future.delayed(waitTime);
        }
      }
      
      debugPrint('🚀 Sending message to AI: $userMessage');
      debugPrint('🤖 AIChatbotService: Sending message to Groq API...');
      debugPrint('User message: $userMessage');
      
      // Ensure we have a current session (should always exist from _startNewSessionOnAppOpen)
      if (_currentSessionId == null || _chatSessions.isEmpty) {
        debugPrint('📝 No current session found, creating one...');
        final newSession = await createNewSession();
        _currentSessionId = newSession.id;
      }
      
      // Add user message to history
      final userChatMessage = ChatMessage(
        message: userMessage,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(userChatMessage);
      
      _messagesInCurrentSession++;
      if (_messagesInCurrentSession >= _maxMessagesPerSession) {
        debugPrint('🔄 Resetting chat session after $_messagesInCurrentSession messages to optimize token usage...');
        await _resetChatSession();
      }

      _messagesSinceLastSentiment++;
      final sentimentService = AISentimentService.instance;
      final lastSentiment = sentimentService.getLastSentiment();
      final sentimentContext = sentimentService.getLastSentimentContext();
      
      String enhancedMessage = userMessage;
      if (_messagesSinceLastSentiment >= _sentimentContextInterval && 
          lastSentiment != null && 
          sentimentContext != null) {
        final topEmotion = lastSentiment.entries.reduce((a, b) => a.value > b.value ? a : b);
        enhancedMessage = '''
$userMessage

[Context: User's emotional state is ${topEmotion.key} (${topEmotion.value.toInt()}%). Usage: $sentimentContext]
''';
        debugPrint('📊 Adding sentiment context: ${topEmotion.key} ${topEmotion.value.toInt()}%');
        _messagesSinceLastSentiment = 0;
      }

      _lastRequestTime = DateTime.now();
      _requestsToday++;
      debugPrint('📊 API Request #$_requestsToday today');
      final aiResponse = await _sendMessageWithRetry(enhancedMessage);
      
      _consecutiveErrors = 0;

      debugPrint('✅ AI Response received: $aiResponse');
      debugPrint('📥 AIChatbotService: Received response from API');
      debugPrint('AI response: $aiResponse');
      
      // Add AI response to history
      final aiChatMessage = ChatMessage(
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiChatMessage);

      await _saveChatHistory();
      await _saveCurrentSessionToHistory();

      await _shareChatWithSentiment(userMessage, aiResponse);

      debugPrint('✅ AIChatbotService: Conversation completed');
      return aiResponse;

    } catch (e, stackTrace) {
      debugPrint('❌ AIChatbotService: Error sending message - $e');
      debugPrint('Stack trace: $stackTrace');
      
      _consecutiveErrors++;
      
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('quota') || errorMsg.contains('limit') || errorMsg.contains('429')) {
        debugPrint('⚠️ API QUOTA/RATE LIMIT ERROR: Free tier limits reached.');
        debugPrint('💡 Tip: Rate limiting is enforced (${_minRequestInterval.inSeconds}s between requests).');
        return "⚠️ Rate limit reached. Groq free tier: 30 RPM, 14,400 RPD. Please wait ${_minRequestInterval.inSeconds} seconds between messages.";
      } else if (errorMsg.contains('api key') || errorMsg.contains('invalid') || errorMsg.contains('401') || errorMsg.contains('unauthorized')) {
        debugPrint('⚠️ INVALID API KEY ERROR');
        return "❌ Invalid API key. Please update your Groq API key. Get one at https://console.groq.com/keys";
      } else if (errorMsg.contains('model')) {
        debugPrint('⚠️ MODEL ERROR: Invalid model name');
        return "❌ Model error. Using '$_modelName'. If issues persist, check available models.";
      }
      
      return "I apologize, but I'm having trouble connecting right now ($_consecutiveErrors errors). Please check your internet connection and wait a moment before trying again.";
    }
  }
  
  Future<String> _sendMessageWithRetry(String message, {int attempt = 1}) async {
    const maxAttempts = 3;
    try {
      _conversationHistory.add({'role': 'user', 'content': message});
      
      final requestBody = {
        'model': _modelName,
        'messages': _conversationHistory,
        'temperature': 0.9,
        'max_tokens': 300,
        'top_p': 0.95,
      };
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: json.encode(requestBody),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final aiMessage = data['choices'][0]['message']['content'] as String;
        
        _conversationHistory.add({'role': 'assistant', 'content': aiMessage});
        
        return aiMessage;
      } else {
        final error = 'HTTP ${response.statusCode}: ${response.body}';
        debugPrint('❌ Groq API Error: $error');
        throw Exception(error);
      }
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      final isRateLimit = errorMsg.contains('quota') || errorMsg.contains('limit') || errorMsg.contains('429');
      
      if (isRateLimit && attempt < maxAttempts) {
        final backoffSeconds = 5 * (1 << (attempt - 1));
        debugPrint('⏳ Rate limit hit. Retrying in ${backoffSeconds}s (attempt $attempt/$maxAttempts)...');
        await Future.delayed(Duration(seconds: backoffSeconds));
        
        if (_conversationHistory.isNotEmpty && _conversationHistory.last['role'] == 'user') {
          _conversationHistory.removeLast();
        }
        
        return await _sendMessageWithRetry(message, attempt: attempt + 1);
      }
      rethrow;
    }
  }

  Future<void> _shareChatWithSentiment(String userMessage, String aiResponse) async {
    try {
      debugPrint('AIChatbotService: Shared chat context with sentiment AI');
    } catch (e) {
      debugPrint('AIChatbotService: Error sharing chat with sentiment - $e');
    }
  }

  /// Update chatbot with current sentiment analysis
  /// ⚠️ DISABLED to save API quota - sentiment context is already included in sendMessage every 3rd message
  /// This method was making EXTRA API calls that caused quota exhaustion
  Future<void> updateWithSentiment({
    required Map<String, double> sentiment,
    required int screenTimeSeconds,
    required int goalSeconds,
  }) async {
    // DISABLED: This was making hidden API calls that bypassed rate limiting
    // Sentiment context is already included in chat messages (every 3rd message)
    debugPrint('ℹ️ updateWithSentiment() called but DISABLED to save quota. Context already in messages.');
    return; // Don't make API call
    
    /* ORIGINAL CODE - DISABLED
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
    */
  }

  Future<void> clearHistory() async {
    try {
      _chatHistory.clear();
      _conversationHistory.clear();
      await _initializeAI();
      
      // ✅ FIX: Also clean up empty sessions when clearing history
      _chatSessions.removeWhere((s) => s.messages.isEmpty);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_chatHistoryKey);
      await prefs.remove(_currentSessionKey);
      
      // Save cleaned sessions
      await _saveChatHistory();
      
      debugPrint('AIChatbotService: Chat history cleared');
    } catch (e) {
      debugPrint('AIChatbotService: Error clearing history - $e');
    }
  }
  
  /// Cleanup method - removes all empty sessions from storage
  /// Call this periodically or on app close
  Future<void> cleanupEmptySessions() async {
    try {
      final initialCount = _chatSessions.length;
      _chatSessions.removeWhere((s) => s.messages.isEmpty);
      final removedCount = initialCount - _chatSessions.length;
      
      if (removedCount > 0) {
        await _saveChatHistory();
        debugPrint('🧹 Cleaned up $removedCount empty session(s)');
      }
    } catch (e) {
      debugPrint('❌ Error cleaning up empty sessions: $e');
    }
  }

  /// Get recent chat messages for context (last N messages).
  ///
  /// Fixed (Phase 1.1): messages are sorted by [ChatMessage.timestamp]
  /// descending before taking `count`. Previously `.take(count)` was applied
  /// to the chronologically-appended list, returning the OLDEST messages of
  /// the session instead of the most recent.
  List<String> getRecentMessages({int count = 5}) {
    final recent = _chatHistory.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return recent
        .where((msg) => msg.isUser)
        .take(count)
        .map((msg) => msg.message)
        .toList();
  }

  /// Get ALL user messages across every chat session within the last
  /// [days] days (defaults to the 30-day retention window).
  ///
  /// Phase 2.1: sentiment analysis should look at the full retention window,
  /// not just the current in-memory session. Returns raw user message text
  /// for further processing.
  List<String> getAllMessagesInWindow({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    final messages = <String>[];

    for (final session in _chatSessions) {
      if (session.lastMessageAt.isBefore(cutoff)) continue;
      for (final message in session.messages) {
        if (!message.isUser) continue;
        if (message.timestamp.isBefore(cutoff)) continue;
        messages.add(message.message);
      }
    }

    // Cap at a sane number so a huge 30-day history can't blow the prompt.
    if (messages.length > 200) {
      return messages.sublist(messages.length - 200);
    }
    return messages;
  }

  // ═══════════════════════════════════════════════════════
  // CHAT SESSION MANAGEMENT
  // ═══════════════════════════════════════════════════════
  
  /// Get all chat sessions
  List<ChatSession> getAllSessions() {
    // Trigger initialization if not done (will complete async)
    if (!_initialized) {
      _initialize();
    }
    // ✅ FIX: Only return sessions that have messages
    return List.unmodifiable(_chatSessions.where((s) => s.messages.isNotEmpty).toList());
  }
  
  /// Get current session
  ChatSession? getCurrentSession() {
    // Trigger initialization if not done (will complete async)
    if (!_initialized) {
      _initialize();
    }
    if (_currentSessionId == null) return null;
    try {
      return _chatSessions.firstWhere((s) => s.id == _currentSessionId);
    } catch (e) {
      return null;
    }
  }
  
  /// Create a new chat session
  Future<ChatSession> createNewSession({String? title}) async {
    await _ensureInitialized();
    
    try {
      if (_currentSessionId != null && _chatHistory.isNotEmpty) {
        await _saveCurrentSessionToHistory();
      }
      
      // ✅ FIX: Create session ID but DON'T add empty session to _chatSessions list
      // Session will be added when first message is sent via _saveCurrentSessionToHistory()
      _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final newSession = ChatSession(
        id: _currentSessionId,
        title: title ?? 'New Chat', // Temporary title, updated later
        createdAt: DateTime.now(),
        lastMessageAt: DateTime.now(),
        messages: [],
      );
      
      if (title != null) {
        _chatHistory.clear();
        _conversationHistory.clear();
        await _initializeAI();
      }
      
      // ✅ FIX: Don't add to list - will be added when messages arrive
      debugPrint('✅ Created new chat session: ${newSession.id} (will be added to list when first message is sent)');
      
      return newSession;
    } catch (e) {
      debugPrint('❌ Error creating new session: $e');
      rethrow;
    }
  }
  
  /// Switch to a different chat session
  Future<void> switchToSession(String sessionId) async {
    await _ensureInitialized();
    
    try {
      if (_currentSessionId != null && _chatHistory.isNotEmpty) {
        await _saveCurrentSessionToHistory();
      }
      
      final session = _chatSessions.firstWhere((s) => s.id == sessionId);
      _currentSessionId = sessionId;
      _chatHistory.clear();
      _chatHistory.addAll(session.messages);
      
      _conversationHistory.clear();
      await _initializeAI();
      for (final msg in session.messages) {
        _conversationHistory.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.message,
        });
      }
      
      await _saveChatHistory();
      debugPrint('✅ Switched to session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error switching session: $e');
      rethrow;
    }
  }
  
  /// Save current session to history
  Future<void> _saveCurrentSessionToHistory() async {
    try {
      // ✅ FIX: Only save if there are messages
      if (_currentSessionId == null || _chatHistory.isEmpty) return;
      
      final sessionIndex = _chatSessions.indexWhere((s) => s.id == _currentSessionId);
      if (sessionIndex != -1) {
        // ✅ FIX: Update title if it's still 'New Chat' (first message)
        final currentSession = _chatSessions[sessionIndex];
        final shouldUpdateTitle = currentSession.title == 'New Chat' || 
                                   currentSession.title.startsWith('Chat ');
        
        _chatSessions[sessionIndex] = currentSession.copyWith(
          title: shouldUpdateTitle ? _generateSessionTitle() : currentSession.title,
          messages: List.from(_chatHistory),
          lastMessageAt: DateTime.now(),
        );
      } else {
        // Session doesn't exist in list, create it with proper title
        final newSession = ChatSession(
          id: _currentSessionId,
          title: _generateSessionTitle(),
          createdAt: _chatHistory.first.timestamp,
          lastMessageAt: DateTime.now(),
          messages: List.from(_chatHistory),
        );
        _chatSessions.add(newSession);
      }
      
      await _saveChatHistory();
    } catch (e) {
      debugPrint('❌ Error saving current session: $e');
    }
  }
  
  /// Generate session title from first message
  String _generateSessionTitle() {
    if (_chatHistory.isEmpty) return 'New Chat';
    final firstUserMsg = _chatHistory.firstWhere(
      (m) => m.isUser,
      orElse: () => _chatHistory.first,
    );
    final title = firstUserMsg.message.trim();
    return title.length > 30 ? '${title.substring(0, 30)}...' : title;
  }
  
  /// Delete a chat session
  Future<void> deleteSession(String sessionId) async {
    await _ensureInitialized();
    
    try {
      _chatSessions.removeWhere((s) => s.id == sessionId);
      
      if (_currentSessionId == sessionId) {
        _currentSessionId = null;
        _chatHistory.clear();
        _conversationHistory.clear();
        await _initializeAI();
      }
      
      await _saveChatHistory();
      debugPrint('✅ Deleted session: $sessionId');
    } catch (e) {
      debugPrint('❌ Error deleting session: $e');
      rethrow;
    }
  }
  
  /// Rename a chat session
  Future<void> renameSession(String sessionId, String newTitle) async {
    await _ensureInitialized();
    
    try {
      final sessionIndex = _chatSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        _chatSessions[sessionIndex] = _chatSessions[sessionIndex].copyWith(
          title: newTitle,
        );
        await _saveChatHistory();
        debugPrint('✅ Renamed session: $sessionId to $newTitle');
      }
    } catch (e) {
      debugPrint('❌ Error renaming session: $e');
      rethrow;
    }
  }
  
  // ═══════════════════════════════════════════════════════
  // MESSAGE MANAGEMENT
  // ═══════════════════════════════════════════════════════
  
  /// Edit a message and regenerate AI response
  Future<String?> editMessage(String messageId, String newText) async {
    await _ensureInitialized();
    
    try {
      final messageIndex = _chatHistory.indexWhere((m) => m.id == messageId);
      if (messageIndex == -1) {
        debugPrint('❌ Message not found: $messageId');
        return null;
      }
      
      final originalMessage = _chatHistory[messageIndex];
      if (!originalMessage.isUser) {
        debugPrint('❌ Cannot edit AI messages');
        return null;
      }
      
      // Update the user message
      _chatHistory[messageIndex] = originalMessage.copyWith(
        message: newText,
        isEdited: true,
      );
      
      // Remove all messages after this one (including AI's old response)
      final messagesToRemove = _chatHistory.length - messageIndex - 1;
      if (messagesToRemove > 0) {
        _chatHistory.removeRange(messageIndex + 1, _chatHistory.length);
        debugPrint('🗑️ Removed $messagesToRemove messages after edited message');
      }
      
      // Rebuild conversation history up to the edited message
      _conversationHistory.clear();
      await _initializeAI();
      for (int i = 0; i <= messageIndex; i++) {
        final msg = _chatHistory[i];
        _conversationHistory.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.message,
        });
      }
      
      await _saveChatHistory();
      debugPrint('✅ Edited message and cleared subsequent messages: $messageId');
      
      // Generate new AI response for the edited message
      debugPrint('🔄 Regenerating AI response for edited message...');
      final aiResponse = await _sendMessageWithRetry(newText);
      
      // Add the new AI response
      final aiChatMessage = ChatMessage(
        message: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );
      _chatHistory.add(aiChatMessage);
      
      await _saveChatHistory();
      await _saveCurrentSessionToHistory();
      
      debugPrint('✅ Generated new AI response for edited message');
      return aiResponse;
      
    } catch (e) {
      debugPrint('❌ Error editing message: $e');
      rethrow;
    }
  }
  
  /// Delete a specific message
  Future<void> deleteMessage(String messageId) async {
    await _ensureInitialized();
    
    try {
      final messageIndex = _chatHistory.indexWhere((m) => m.id == messageId);
      if (messageIndex != -1) {
        final message = _chatHistory[messageIndex];
        _chatHistory.removeAt(messageIndex);
        
        _conversationHistory.removeWhere((m) => m['content'] == message.message);
        
        await _saveChatHistory();
        debugPrint('✅ Deleted message: $messageId');
      }
    } catch (e) {
      debugPrint('❌ Error deleting message: $e');
      rethrow;
    }
  }
  
  /// Copy message text to clipboard (returns message text)
  String? copyMessage(String messageId) {
    try {
      final message = _chatHistory.firstWhere((m) => m.id == messageId);
      debugPrint('✅ Copied message: $messageId');
      return message.message;
    } catch (e) {
      debugPrint('❌ Error copying message: $e');
      return null;
    }
  }
  
  // ═══════════════════════════════════════════════════════
  // AUTO-DELETION
  // ═══════════════════════════════════════════════════════
  
  /// Auto-delete chats older than 30 days.
  ///
  /// Also prunes ChatContextExtractor's persisted themes older than the same
  /// cutoff so extracted context dies with its source sessions (Phase 2.5).
  Future<void> _autoDeleteOldChats() async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: _autoDeletionDays));
      final initialCount = _chatSessions.length;
      
      _chatSessions.removeWhere((session) {
        final isOld = session.lastMessageAt.isBefore(cutoffDate);
        if (isOld) {
          debugPrint('🗑️ Auto-deleting old session: ${session.id} (${session.title})');
        }
        return isOld;
      });
      
      final deletedCount = initialCount - _chatSessions.length;
      if (deletedCount > 0) {
        await _saveChatHistory();
        debugPrint('✅ Auto-deleted $deletedCount old chat session(s) (older than $_autoDeletionDays days)');
      }

      // Keep extracted themes in lockstep with the same retention window.
      await ChatContextExtractor.instance.pruneBefore(cutoffDate);

      // Phase 3.2 / 5.3: persisted sentiment snapshots die with the same
      // 30-day window so trends never outlive their source data.
      await SentimentPersistenceService.instance.pruneBefore(cutoffDate);
    } catch (e) {
      debugPrint('❌ Error auto-deleting old chats: $e');
    }
  }
  
  /// Manually trigger auto-deletion check
  Future<void> cleanupOldChats() async {
    await _ensureInitialized();
    await _autoDeleteOldChats();
  }
  
  /// Get sessions count that will be deleted
  int getOldChatsCount() {
    // Trigger initialization if not done (will complete async)
    if (!_initialized) {
      _initialize();
      return 0; // Return 0 while initializing
    }
    final cutoffDate = DateTime.now().subtract(Duration(days: _autoDeletionDays));
    return _chatSessions.where((s) => s.lastMessageAt.isBefore(cutoffDate)).length;
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
