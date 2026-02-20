import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/admin/presentation/pages/admin_chat_detail_page.dart';
import 'package:more_experts/features/admin/presentation/widgets/glass_widgets.dart';

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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('User Chats',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
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
                    style: TextStyle(color: Colors.white.withOpacity(0.5))));
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
              final userProfilePic = conv['userProfilePic']; // May be null

              return GlassCard(
                margin: const EdgeInsets.only(bottom: 12),
                borderRadius: 16,
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GlassAvatar(
                    imagePath: userProfilePic,
                    name: userName,
                    radius: 24,
                  ),
                  title: Text(userName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white)),
                  subtitle: Text(
                    lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.white.withOpacity(0.6)),
                  ),
                  trailing: unreadCount > 0
                      ? Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            color: Colors.redAccent,
                            shape: BoxShape.circle,
                          ),
                          child: Text('$unreadCount',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold)),
                        )
                      : Icon(Icons.arrow_forward_ios,
                          size: 16, color: Colors.white.withOpacity(0.3)),
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
