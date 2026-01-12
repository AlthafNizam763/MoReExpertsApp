import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void initChat(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    // 1. Fetch History from DB (MongoDB)
    fetchHistory(currentUserId);

    // 2. Initialize Socket connection
    _chatService.initSocket(currentUserId);

    // 3. Listen for new messages
    _chatService.onMessageReceived((newMessage) {
      _messages.add(newMessage);
      // Sort if needed, but usually append is fine for time-ordered
      notifyListeners();
    }, currentUserId);
  }

  Future<void> fetchHistory(String currentUserId) async {
    try {
      final history = await _chatService.getMessages(currentUserId);
      _messages = history;
    } catch (e) {
      log('Error fetching chat history: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String content, String currentUserId) async {
    if (content.trim().isEmpty) return;

    try {
      _chatService.sendMessage(content.trim(), currentUserId);

      // Optimistic Update: Add message immediately to UI
      // Note: We need a temporary ID until server confirms, but for simple chat
      // we can just add it. If server echoes back, we might get duplicate if not handled.
      // Ideally, wait for server ack or echo.
      // For now, let's assume server broadcoasts back to us too, or we just rely on event.
      // If server does NOT echo back to sender, we must add it here:
      /*
      final tempMessage = MessageModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        content: content.trim(),
        senderId: currentUserId,
        timestamp: DateTime.now(),
        isRead: false,
        isMe: true,
      );
      _messages.add(tempMessage);
      notifyListeners();
      */
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
