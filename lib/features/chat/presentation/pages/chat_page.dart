import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:more_experts/core/constants/app_colors.dart';
import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/chat/presentation/providers/chat_provider.dart';
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Start polling when page opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUserId = context.read<AuthProvider>().currentUser?.id;
      if (currentUserId != null) {
        context.read<ChatProvider>().initChat(currentUserId);
      }
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    // Stop polling is handled in ChatProvider dispose or we can explicitly call it if needed
    // But since Provider might be scoped, we rely on its lifecycle or context
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _handleSend() async {
    final authProvider = context.read<AuthProvider>();
    final chatProvider = context.read<ChatProvider>();
    final content = _messageController.text;

    if (content.trim().isEmpty || authProvider.currentUser == null) return;

    _messageController.clear();
    try {
      await chatProvider.sendMessage(
        content,
        authProvider.currentUser!.id,
        authProvider.currentUser!.name,
      );
      _scrollToBottom();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Support'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<ChatProvider>(
              builder: (context, provider, child) {
                if (provider.messages.isEmpty && provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.messages.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 48, color: AppColors.mediaGray),
                        const SizedBox(height: 16),
                        const Text(
                          'No messages yet',
                          style: TextStyle(color: AppColors.mediaGray),
                        ),
                      ],
                    ),
                  );
                }

                // Scroll to bottom on new messages
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  // Only auto-scroll if we are already near bottom or it's initial load
                  if (_scrollController.hasClients &&
                      _scrollController.position.pixels >=
                          _scrollController.position.maxScrollExtent - 100) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    final isMe = message.isMe;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.black : Colors.grey[200],
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(12),
                            topRight: const Radius.circular(12),
                            bottomLeft:
                                isMe ? const Radius.circular(12) : Radius.zero,
                            bottomRight:
                                isMe ? Radius.zero : const Radius.circular(12),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : Colors.black,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormat('hh:mm a')
                                  .format(message.timestamp.toLocal()),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : Colors.black54,
                                fontSize: 10,
                              ),
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border(top: BorderSide(color: AppColors.lightGray)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.add_circle_outline, color: AppColors.black),
                  onPressed: () {
                    // File attachment logic
                  },
                ),
                IconButton(
                  icon: Icon(Icons.emoji_emotions_outlined,
                      color: AppColors.black),
                  onPressed: () {
                    // Emoji picker logic
                  },
                ),
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: AppColors.lightGray,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                    ),
                    onSubmitted: (_) => _handleSend(),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: _handleSend,
                  child: CircleAvatar(
                    backgroundColor: AppColors.black,
                    child: const Icon(Icons.send,
                        color: AppColors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
