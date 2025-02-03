import 'package:burn_tech/models/color.dart';
import 'package:burn_tech/screens/chat/chat_screen_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);

    return Scaffold(
      appBar: AppBar(
              title: const Text(
                'Chat',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold,fontSize: 28),
              ),
              backgroundColor: desertOrange,          
            ),
      body:Container(
        height: 800,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromRGBO(250, 139, 0, 1), Color.fromRGBO(248, 51, 60, 1)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
       child:Column(
        children: [
          Expanded(
            child: chatProvider.isLoading
                ? Center(child: CircularProgressIndicator(color: Colors.white,))
                : ListView.builder(
                    reverse: true,
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages.reversed.toList()[index];
                      return Align(
                        alignment: message.isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                          padding: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: message.isMe ? Colors.blue : Colors.grey[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            message.text,
                            style: TextStyle(color: message.isMe ? Colors.white : Colors.black),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: () {
              if (_controller.text.trim().isNotEmpty) {
                      chatProvider.sendMessage(_controller.text.trim());
                      _controller.clear();
                    }
            },
          ),
        ],
      ),
    ),
    const SizedBox(height: 30),
        ],
      ),
    ),
    );
  }
}