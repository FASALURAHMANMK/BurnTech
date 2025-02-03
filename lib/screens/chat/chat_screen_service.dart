import 'dart:async';
import 'package:burn_tech/models/chat_model.dart';

class ChatRepository {
  Future<List<ChatMessage>> fetchMessages() async {
    await Future.delayed(const Duration(seconds: 2)); // Simulating network delay
    return [
      ChatMessage(id: '1', text: "Hello! This is a community chat", isMe: false, timestamp: DateTime.now().subtract(Duration(minutes: 2))),
      ChatMessage(id: '2', text: "Ok", isMe: true, timestamp: DateTime.now().subtract(Duration(minutes: 1))),
    ];
  }

  Future<void> sendMessage(ChatMessage message) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulating send delay
  }
}