import 'dart:convert';
import 'package:http/http.dart' as http;

/// Test script to verify Groq API integration
/// Run with: dart test_groq_chat.dart
void main() async {
  print('🧪 Testing Groq API Chat Integration...\n');
  
  const apiKey = 'YOUR_GROQ_API_KEY_HERE'; // Get free key at https://console.groq.com/keys
  const apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  const modelName = 'llama-3.1-8b-instant';
  
  try {
    // Test message - Testing NLP understanding with real-world question
    final testMessage = 'Who is the PM of India?';
    print('📤 Sending test message: "$testMessage"\n');
    
    // Build request
    final requestBody = {
      'model': modelName,
      'messages': [
        {
          'role': 'system',
          'content': 'You are a digital wellbeing assistant. Keep responses concise (2-3 sentences).'
        },
        {
          'role': 'user',
          'content': testMessage
        }
      ],
      'temperature': 0.9,
      'max_tokens': 300,
      'top_p': 0.95,
    };
    
    print('⏳ Sending request to Groq API...');
    final startTime = DateTime.now();
    
    // Make HTTP request
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode(requestBody),
    );
    
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    
    print('✅ Response received in ${duration.inMilliseconds}ms\n');
    
    // Check response
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final aiMessage = data['choices'][0]['message']['content'] as String;
      final usage = data['usage'];
      
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('✅ SUCCESS! Groq API is working correctly\n');
      print('📥 AI Response:');
      print('   $aiMessage\n');
      print('📊 API Statistics:');
      print('   • Model: $modelName');
      print('   • Response time: ${duration.inMilliseconds}ms');
      print('   • Prompt tokens: ${usage['prompt_tokens']}');
      print('   • Completion tokens: ${usage['completion_tokens']}');
      print('   • Total tokens: ${usage['total_tokens']}');
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      print('✅ Integration test PASSED!');
      print('🚀 You can now run: flutter run\n');
      
    } else {
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      print('❌ FAILED! HTTP ${response.statusCode}\n');
      print('Error response:');
      print(response.body);
      print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      
      // Diagnose common issues
      if (response.statusCode == 401) {
        print('⚠️  Issue: Invalid API key');
        print('💡 Solution: Get a new key at https://console.groq.com/keys\n');
      } else if (response.statusCode == 429) {
        print('⚠️  Issue: Rate limit exceeded');
        print('💡 Solution: Wait 60 seconds and try again\n');
      } else if (response.statusCode == 400) {
        print('⚠️  Issue: Bad request (invalid model or parameters)');
        print('💡 Solution: Check model name and request format\n');
      }
    }
    
  } catch (e, stackTrace) {
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    print('❌ ERROR: $e\n');
    print('Stack trace:');
    print(stackTrace);
    print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    
    // Diagnose common issues
    if (e.toString().contains('SocketException') || e.toString().contains('Network')) {
      print('⚠️  Issue: Network connection problem');
      print('💡 Solution: Check your internet connection\n');
    } else if (e.toString().contains('TimeoutException')) {
      print('⚠️  Issue: Request timeout');
      print('💡 Solution: Try again, Groq servers might be slow\n');
    }
  }
}
