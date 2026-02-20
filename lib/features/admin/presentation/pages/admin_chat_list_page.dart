import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_chat_detail_page.dart';

class AdminChatListPage extends StatefulWidget {
  const AdminChatListPage({super.key});

  @override
  State<AdminChatListPage> createState() => _AdminChatListPageState();
}

class _AdminChatListPageState extends State<AdminChatListPage> {
  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111111),
      appBar: AppBar(
        title: const Text('User Chats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF111111),
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getAllConversationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.blue));
          }
          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red)));
          }

          final conversations = snapshot.data ?? [];
          if (conversations.isEmpty) {
            return Center(
                child: Text('No active conversations.',
                    style: TextStyle(color: Colors.grey.shade500)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conv = conversations[index];
              final userName = conv['userName'] ?? 'Unknown User';
              final lastMessage = conv['lastMessage'] ?? '';
              final unreadCount = conv['unreadCount'] ?? 0;
              final userId = conv['userId'] ?? conv['id'];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    radius: 24,
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                      style: const TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade500),
                  ),
                  trailing: unreadCount > 0
                      ? CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.redAccent,
                          child: Text('$unreadCount',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)))
                      : Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.grey.shade600),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AdminChatDetailPage(
                          userId: userId,
                          userName: userName,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
