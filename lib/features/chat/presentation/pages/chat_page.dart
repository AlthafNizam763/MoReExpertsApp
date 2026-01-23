import 'dart:async';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:more_experts/core/widgets/app_loader.dart';
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
  final FocusNode _focusNode = FocusNode();
  StreamSubscription? _unreadSubscription;
  bool _isInitialScrollDone = false;
  bool _showEmoji = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        setState(() {
          _showEmoji = false;
        });
      }
    });
    // Mark messages as read when page opens and keep marking as read while active
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().currentUser;
      if (user != null) {
        final chatProvider = context.read<ChatProvider>();

        // Immediate mark as read
        chatProvider.markAsRead(user.id);

        // Continuous mark as read for incoming messages
        _unreadSubscription =
            chatProvider.hasUnreadMessagesStream(user.id).listen((hasUnread) {
          if (hasUnread && mounted) {
            chatProvider.markAsRead(user.id);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _unreadSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animate = true}) {
    if (_scrollController.hasClients) {
      if (animate) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
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

    return PopScope(
      canPop: !_showEmoji,
      onPopInvoked: (didPop) {
        if (didPop) return;
        if (_showEmoji) {
          setState(() {
            _showEmoji = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: bgLight,
        body: Column(
          children: [
            // Custom Curved Header
            Container(
              padding: const EdgeInsets.only(
                  top: 50, left: 20, right: 20, bottom: 25),
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
                    backgroundImage: AssetImage('assets/images/admin.png'),
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
                    return const AppLoader();
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
                    if (messages.isNotEmpty) {
                      if (!_isInitialScrollDone) {
                        _scrollToBottom(animate: false);
                        _isInitialScrollDone = true;
                      } else if (_scrollController.hasClients &&
                          _scrollController.position.pixels >=
                              _scrollController.position.maxScrollExtent -
                                  100) {
                        _scrollToBottom();
                      }
                    }
                  });

                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
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
                                    AssetImage('assets/images/admin.png'),
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
                                                color: primaryBlue
                                                    .withOpacity(0.3),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ]
                                          : [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.1),
                                                blurRadius: 10,
                                                offset: const Offset(0, 5),
                                              ),
                                            ],
                                    ),
                                    child: Text(
                                      message
                                          .text, // ensure MessageModel uses 'text' or 'content' getter
                                      style: TextStyle(
                                        color: isMe
                                            ? Colors.white
                                            : Colors.black87,
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
                                backgroundImage: (user?.profilePic != null &&
                                        user!.profilePic!.isNotEmpty)
                                    ? NetworkImage(user.profilePic!)
                                    : null,
                                child: (user?.profilePic == null ||
                                        user!.profilePic!.isEmpty)
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
              padding: EdgeInsets.only(
                  left: 20, right: 20, bottom: _showEmoji ? 10 : 30, top: 10),
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
                          const SizedBox(width: 4),
                          IconButton(
                            icon: Icon(
                              _showEmoji
                                  ? Icons.keyboard
                                  : Icons.emoji_emotions_outlined,
                              color: Colors.grey[400],
                              size: 28, // Polish: Slightly larger icon
                            ),
                            onPressed: () {
                              if (_showEmoji) {
                                _focusNode.requestFocus();
                              } else {
                                _focusNode.unfocus();
                              }
                              setState(() {
                                _showEmoji = !_showEmoji;
                              });
                            },
                          ),
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              focusNode: _focusNode,
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
            if (_showEmoji)
              SizedBox(
                height: 250,
                child: EmojiPicker(
                  textEditingController: _messageController,
                  config: Config(
                    height: 250,
                    checkPlatformCompatibility: false,
                    emojiViewConfig: EmojiViewConfig(
                      backgroundColor: bgLight,
                      columns: 7,
                      emojiSizeMax: 28 *
                          (foundation.defaultTargetPlatform ==
                                  TargetPlatform.iOS
                              ? 1.2
                              : 1.0),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
