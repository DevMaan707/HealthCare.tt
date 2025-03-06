import 'dart:convert';
import 'package:http/http.dart' as http;

class ChatService {
  final String baseUrl = 'http://10.0.2.2:5969';

  Future<String> generateResponse(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('\$baseUrl/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'No response generated';
      } else {
        throw Exception('Failed to generate response');
      }
    } catch (e) {
      // Return mock response for testing
      return _generateMockResponse(prompt);
    }
  }

  String _generateMockResponse(String prompt) {
    final promptLower = prompt.toLowerCase();

    if (promptLower.contains('hello') || promptLower.contains('hi')) {
      return 'Hello! I\'m your healthcare assistant. How can I help you today?';
    } else if (promptLower.contains('blood pressure')) {
      return 'Normal blood pressure is less than 120/80 mm Hg. Your recent readings show you\'re within a healthy range. Keep maintaining your healthy lifestyle!';
    } else if (promptLower.contains('exercise') ||
        promptLower.contains('activity')) {
      return 'Regular physical activity is key for heart health. The American Heart Association recommends at least 150 minutes of moderate-intensity exercise per week. Your step count has been good, averaging over 9,000 steps daily this week.';
    } else if (promptLower.contains('medication') ||
        promptLower.contains('medicine')) {
      return 'Based on your medical history, remember to take your medications as prescribed. Regular adherence to your treatment plan is essential for managing your conditions effectively.';
    } else if (promptLower.contains('diet') ||
        promptLower.contains('eating') ||
        promptLower.contains('food')) {
      return 'A heart-healthy diet includes plenty of fruits, vegetables, whole grains, and lean proteins. Limiting sodium, added sugars, and saturated fats is also important for managing blood pressure.';
    } else {
      return 'Thank you for your message. I\'m here to help with any health-related questions you might have. Feel free to ask about your health data, medication reminders, exercise recommendations, or general health advice.';
    }
  }
}
