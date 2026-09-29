import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Direct HTTP test to find working Gemini models.
/// Run with: dart test_http_direct.dart
/// The key is read from the GEMINI_TEST_API_KEY environment variable (see .env).
Future<void> main() async {
  print('🧪 Testing Gemini API directly via HTTP...\n');
  
  final apiKey = Platform.environment['GEMINI_TEST_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    print('❌ GEMINI_TEST_API_KEY environment variable is not set.');
    print('   Copy .env.example to .env and export the variable.');
    return;
  }
  
  // First, list available models
  print('📋 Listing available models...\n');
  try {
    final listUrl = 'https://generativelanguage.googleapis.com/v1beta/models?key=$apiKey';
    final listResponse = await http.get(Uri.parse(listUrl));
    
    if (listResponse.statusCode == 200) {
      final data = jsonDecode(listResponse.body);
      print('✅ Available models:');
      for (final model in data['models']) {
        final name = model['name'];
        final methods = model['supportedGenerationMethods'] as List;
        print('   - $name');
        if (methods.contains('generateContent')) {
          print('     ✓ Supports generateContent\n');
        }
      }
    } else {
      print('❌ Error listing models: ${listResponse.statusCode}');
      final error = jsonDecode(listResponse.body);
      print('Message: ${error['error']['message']}\n');
    }
  } catch (e) {
    print('❌ Exception listing models: $e\n');
  }
  
  // Try testing with the correct model
  print('\n📡 Testing with gemini-flash-latest...');
  try {
    final url = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-flash-latest:generateContent?key=$apiKey';
    
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': 'Say hello'}
            ]
          }
        ]
      }),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final text = data['candidates'][0]['content']['parts'][0]['text'];
      print('✅ SUCCESS! Response: $text\n');
      print('🎉 This model works! Use: "gemini-flash-latest"');
    } else {
      print('❌ Error ${response.statusCode}');
      final error = jsonDecode(response.body);
      print('Message: ${error['error']['message']}\n');
    }
  } catch (e) {
    print('❌ Exception: $e\n');
  }
}
