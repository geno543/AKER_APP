import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class OpenRouterService {
  static const String _baseUrl = 'https://openrouter.ai/api/v1';
  static const String _apiKey = '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';
  static const String _model = 'anthropic/claude-3.5-sonnet:beta';
  
  static Future<String> generateResponse(String userMessage, {String? imageUrl}) async {
    try {
      final messages = <Map<String, dynamic>>[
        {
          'role': 'system',
          'content': '''You are AKER AI, a specialized animal rescue assistant with expertise in:

- Animal Identification: Identify species, breeds, age, and health status from images
- Emergency Response: Provide immediate first aid and rescue protocols  
- Veterinary Guidance: Offer health assessments and care recommendations
- Behavioral Analysis: Understand animal behavior and stress indicators
- Rescue Coordination: Connect users with local shelters and rescue organizations

Provide direct, actionable advice prioritizing animal safety and welfare. Always recommend professional veterinary care for serious conditions. Keep responses professional and informative with minimal use of emojis.'''
        },
        {
          'role': 'user',
          'content': await _buildMessageContent(userMessage, imageUrl)
        }
      ];

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
          'HTTP-Referer': 'https://aker-rescue.app',
          'X-Title': 'AKER Animal Rescue App',
        },
        body: jsonEncode({
          'model': _model,
          'messages': messages,
          'max_tokens': 1000,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices']?[0]?['message']?['content'];
        return content ?? 'I apologize, but I\'m having trouble generating a response right now. Please try again.';
      } else {
        print('OpenRouter API Error: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(userMessage);
      }
    } catch (e) {
      print('OpenRouter Service Error: $e');
      return _getFallbackResponse(userMessage);
    }
  }

  static dynamic _buildMessageContent(String text, String? imageUrl) async {
    if (imageUrl != null) {
      String imageData;
      
      if (imageUrl.startsWith('http')) {
        // It's a URL
        imageData = imageUrl;
      } else {
        // It's a local file path, convert to base64
        try {
          final file = File(imageUrl);
          final bytes = await file.readAsBytes();
          final base64String = base64Encode(bytes);
          
          // Determine MIME type based on file extension
          String mimeType = 'image/jpeg';
          if (imageUrl.toLowerCase().endsWith('.png')) {
            mimeType = 'image/png';
          } else if (imageUrl.toLowerCase().endsWith('.gif')) {
            mimeType = 'image/gif';
          } else if (imageUrl.toLowerCase().endsWith('.webp')) {
            mimeType = 'image/webp';
          }
          
          imageData = 'data:$mimeType;base64,$base64String';
        } catch (e) {
          print('Error reading image file: $e');
          return text; // Return text only if image processing fails
        }
      }
      
      return [
        {
          'type': 'text',
          'text': text
        },
        {
          'type': 'image_url',
          'image_url': {
            'url': imageData
          }
        }
      ];
    } else {
      return text;
    }
  }

  static String _getFallbackResponse(String userMessage) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('emergency') || message.contains('urgent')) {
      return "🚨 For immediate emergencies:\n\n1. Call local emergency services: 911\n2. Contact nearest animal hospital\n3. Keep the animal calm and safe\n4. Don't move severely injured animals\n\nWould you like specific first aid instructions for the type of animal you're helping?";
    }
    
    if (message.contains('first aid') || message.contains('injured')) {
      return "🏥 Basic Animal First Aid:\n\n• Check for breathing and pulse\n• Control bleeding with clean cloth\n• Keep the animal warm and calm\n• Don't give food or water\n• Transport carefully to vet\n\nWhat type of animal and injury are you dealing with? I can provide more specific guidance.";
    }
    
    if (message.contains('shelter') || message.contains('find')) {
      return "🏠 Finding Animal Shelters:\n\n• Use the map feature to locate nearby shelters\n• Contact local animal control\n• Check with veterinary clinics\n• Search online directories\n\nI can help you find specific shelters in your area. What's your current location?";
    }
    
    if (message.contains('care') || message.contains('feed')) {
      return "🐾 Animal Care Guidelines:\n\n• Provide fresh water\n• Appropriate food for species\n• Safe, comfortable shelter\n• Regular health check-ups\n• Proper exercise and socialization\n\nWhat specific animal care question do you have? I can provide detailed guidance.";
    }
    
    return "I understand you need help with animal rescue. I can assist with:\n\n🚨 Emergency procedures\n🏥 First aid guidance\n🏠 Finding shelters\n🐾 Animal care tips\n📞 Emergency contacts\n\nCould you be more specific about what you need help with?";
  }
}