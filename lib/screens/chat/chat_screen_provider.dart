import 'package:burn_tech/models/chat_model.dart';
import 'package:burn_tech/screens/chat/chat_screen_service.dart';
import 'package:flutter/material.dart';

class ChatProvider extends ChangeNotifier {
  final ChatRepository _repository = ChatRepository();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    loadMessages();
  }

  Future<void> loadMessages() async {
    _isLoading = true;
    notifyListeners();

    _messages = await _repository.fetchMessages();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    final newMessage = ChatMessage(
      id: DateTime.now().toString(),
      text: text,
      isMe: true,
      timestamp: DateTime.now(),
    );

    _messages.add(newMessage);
    notifyListeners();

    await _repository.sendMessage(newMessage);
  }
}