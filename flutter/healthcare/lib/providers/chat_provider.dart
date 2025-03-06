import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  void addUserMessage(String message) {
    _messages.add(ChatMessage(message: message, type: MessageType.user));
    notifyListeners();
  }

  Future<void> generateResponse(String userMessage) async {
    addUserMessage(userMessage);

    _isLoading = true;
    notifyListeners();

    try {
      final response = await _chatService.generateResponse(userMessage);

      _messages
          .add(ChatMessage(message: response, type: MessageType.assistant));
    } catch (e) {
      _messages.add(ChatMessage(
          message:
              "I'm sorry, I'm having trouble connecting to the server. Please try again later.",
          type: MessageType.assistant));
    }

    _isLoading = false;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    notifyListeners();
  }

  // Initial greeting message
  void addWelcomeMessage() {
    if (_messages.isEmpty) {
      _messages.add(ChatMessage(
          message:
              "Hello! I'm your health assistant. How can I help you today? You can ask me about your health data, medication reminders, or general health questions.",
          type: MessageType.assistant));
      notifyListeners();
    }
  }
}
