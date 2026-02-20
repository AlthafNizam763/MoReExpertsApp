import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class AdminChatDetailPage extends StatefulWidget {
  final String userId;
  final String userName;

  const AdminChatDetailPage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<AdminChatDetailPage> createState() => _AdminChatDetailPageState();
}

class _AdminChatDetailPageState extends State<AdminChatDetailPage> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgController = TextEditingController();

  void _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;

    _msgController.clear();

    try {
      final timestamp = DateTime.now();

      final messageData = {
        'text': text,
        'sender': 'MoRe Support',
        'role': 'support',
        'conversationId': widget.userId,
        'timestamp': timestamp,
        'clientTimestamp': timestamp.toUtc().toIso8601String(),
        'createdAt': timestamp,
        'isRead': false,
      };

      // 1. Add message
      await _chatService
          .getMessagesStream(widget.userId)
          .first; // Just to make sure we don't break logic
      await _chatService.sendMessageAsAdmin(
          text, widget.userId, widget.userName);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: Text('Chat with ${widget.userName}',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: _chatService.getMessagesStream(widget.userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.blue));
                }
                final messages = snapshot.data ?? [];

                return ListView.builder(
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[index];
                    final isAdmin =
                        msg.role == 'admin' || msg.role == 'support';

                    return Align(
                      alignment: isAdmin
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? Colors.blueAccent.withOpacity(0.2)
                              : const Color(0xFF1E1E1E),
                          border: Border.all(
                            color: isAdmin
                                ? Colors.blueAccent.withOpacity(0.3)
                                : Colors.white.withOpacity(0.05),
                          ),
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight:
                                isAdmin ? const Radius.circular(0) : null,
                            bottomLeft:
                                !isAdmin ? const Radius.circular(0) : null,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: isAdmin
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(msg.text,
                                style: const TextStyle(color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(
                              timeago.format(msg.timestamp),
                              style: TextStyle(
                                  fontSize: 10, color: Colors.grey.shade500),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12.0),
            color: const Color(0xFF1E1E1E),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: TextStyle(color: Colors.grey.shade600),
                      filled: true,
                      fillColor: const Color(0xFF111111),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
