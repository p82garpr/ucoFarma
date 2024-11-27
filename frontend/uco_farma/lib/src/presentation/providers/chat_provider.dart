import 'package:flutter/material.dart';
import '../../domain/models/message_model.dart';
import '../../domain/services/chat_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  final List<Message> _messages = [];
  bool _isLoading = false;
  String? _error;

  List<Message> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    _messages.add(Message(
      text: text,
      isUserMessage: true,
      timestamp: DateTime.now(),
    ));
    notifyListeners();

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _chatService.sendMessage(text);
      
      _messages.add(Message(
        text: response,
        isUserMessage: false,
        timestamp: DateTime.now(),
      ));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}