import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:more_experts/features/auth/presentation/provider/auth_provider.dart';
import 'package:more_experts/features/chat/presentation/providers/chat_provider.dart';
import 'package:intl/intl.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';

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
    // StreamBuilder handles data fetching, so no separate init needed
    // except perhaps setting up user ID if needed for other things
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
    final user = context.watch<AuthProvider>().currentUser;
    // Define brand colors based on the image provided
    final primaryBlue = const Color(0xFF1b72b5);
    final secondaryPurple = const Color(0xFF8A6BED);
    final bgLight = const Color(0xFFF5F7FB);

    return Scaffold(
      backgroundColor: bgLight,
      body: Column(
        children: [
          // Custom Curved Header
          Container(
            padding:
                const EdgeInsets.only(top: 50, left: 20, right: 20, bottom: 25),
            decoration: BoxDecoration(
              color: primaryBlue,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: primaryBlue.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.white24,
                  radius: 22,
                  backgroundImage: AssetImage('assets/images/logo2.png'),
                ),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admin Support',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4CE4B1), // Online green
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Online',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const Spacer(), // Keeps layout consistent or remove if you want left alignment.
                // Removed icons as requested
              ],
            ),
          ),

          // Message List
          Expanded(
            child: StreamBuilder<List<MessageModel>>(
              stream: user?.id != null
                  ? context.read<ChatProvider>().getMessagesStream(user!.id)
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final messages = snapshot.data ?? [];

                if (messages.isEmpty) {
                  return Center(
                    child: Text(
                      'Start a conversation',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  );
                }

                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients &&
                      _scrollController.position.pixels >=
                          _scrollController.position.maxScrollExtent - 100) {
                    _scrollToBottom();
                  }
                });

                return ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isMe = message.isMe;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: isMe
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (!isMe) ...[
                            const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey,
                              backgroundImage:
                                  AssetImage('assets/images/logo2.png'),
                            ),
                            const SizedBox(width: 10),
                          ],
                          Flexible(
                            child: Column(
                              crossAxisAlignment: isMe
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 14),
                                  decoration: BoxDecoration(
                                    gradient: isMe
                                        ? LinearGradient(
                                            colors: [
                                              primaryBlue,
                                              secondaryPurple
                                            ],
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                          )
                                        : null,
                                    color: isMe ? null : Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: const Radius.circular(20),
                                      topRight: const Radius.circular(20),
                                      bottomLeft: isMe
                                          ? const Radius.circular(20)
                                          : const Radius.circular(5),
                                      bottomRight: isMe
                                          ? const Radius.circular(5)
                                          : const Radius.circular(20),
                                    ),
                                    boxShadow: isMe
                                        ? [
                                            BoxShadow(
                                              color:
                                                  primaryBlue.withOpacity(0.3),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color:
                                                  Colors.grey.withOpacity(0.1),
                                              blurRadius: 10,
                                              offset: const Offset(0, 5),
                                            ),
                                          ],
                                  ),
                                  child: Text(
                                    message
                                        .text, // ensure MessageModel uses 'text' or 'content' getter
                                    style: TextStyle(
                                      color:
                                          isMe ? Colors.white : Colors.black87,
                                      fontSize: 15,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  DateFormat('hh:mm a')
                                      .format(message.timestamp.toLocal()),
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isMe) ...[
                            const SizedBox(width: 10),
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: user?.profilePic != null
                                  ? NetworkImage(user!.profilePic!)
                                  : null,
                              child: user?.profilePic == null
                                  ? Text(
                                      user?.name
                                              .substring(0, 1)
                                              .toUpperCase() ??
                                          'U',
                                      style: TextStyle(
                                          color: primaryBlue,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : null,
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Formatting Input Area
          Container(
            padding:
                const EdgeInsets.only(left: 20, right: 20, bottom: 30, top: 10),
            color: bgLight,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Removed camera_alt_outlined icon and its SizedBox
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Type Your Message',
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (_) {
                              final user =
                                  context.read<AuthProvider>().currentUser;
                              if (user != null) {
                                _handleSend();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _handleSend,
                  child: Container(
                    height: 55,
                    width: 55,
                    decoration: BoxDecoration(
                      color: primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryBlue.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 22),
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
