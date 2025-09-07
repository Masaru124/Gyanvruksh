import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:gyanvruksh/services/api.dart';
import 'dart:convert';

class ChatroomScreen extends StatefulWidget {
  const ChatroomScreen({super.key});

  @override
  State<ChatroomScreen> createState() => _ChatroomScreenState();
}

class _ChatroomScreenState extends State<ChatroomScreen> {
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  late WebSocketChannel _channel;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
    _loadPreviousMessages();
  }

  void _connectToWebSocket() {
    final user = ApiService().me();
    if (user == null) return;

    _channel = WebSocketChannel.connect(
      Uri.parse('${ApiService.baseUrl.replaceFirst('http', 'ws')}/api/chat/ws'),
    );

    _channel.stream.listen(
      (message) {
        final data = jsonDecode(message);
        setState(() {
          _messages.add(data);
        });
      },
      onDone: () {
        setState(() {
          _isConnected = false;
        });
      },
      onError: (error) {
        setState(() {
          _isConnected = false;
        });
      },
    );

    setState(() {
      _isConnected = true;
    });
  }

  Future<void> _loadPreviousMessages() async {
    try {
      final messages = await ApiService().getChatMessages();
      setState(() {
        _messages.addAll(messages.cast<Map<String, dynamic>>());
      });
    } catch (e) {
      // Handle error
    }
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final user = ApiService().me();
    if (user == null) return;

    final messageData = {
      'user_id': user['id'],
      'message': _messageController.text,
    };

    _channel.sink.add(jsonEncode(messageData));
    _messageController.clear();
  }

  @override
  void dispose() {
    _channel.sink.close();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chatroom'),
        actions: [
          Icon(
            _isConnected ? Icons.wifi : Icons.wifi_off,
            color: _isConnected ? Colors.green : Colors.red,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['full_name'] ?? 'Unknown',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2E3A59),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(message['message']),
                        const SizedBox(height: 4),
                        Text(
                          message['timestamp'] ?? '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                  color: const Color(0xFF667EEA),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
