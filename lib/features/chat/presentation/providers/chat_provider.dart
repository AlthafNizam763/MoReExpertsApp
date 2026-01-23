import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  Stream<List<MessageModel>> getMessagesStream(String currentUserId) {
    return _chatService.getMessagesStream(currentUserId);
  }

  Future<void> sendMessage(
      String content, String currentUserId, String userName) async {
    if (content.trim().isEmpty) return;

    try {
      await _chatService.sendMessage(content.trim(), currentUserId, userName);
    } catch (e) {
      log('Error sending message: $e');
      rethrow;
    }
  }

  Future<void> markAsRead(String userId) async {
    await _chatService.markMessagesAsRead(userId);
    notifyListeners();
  }

  Stream<bool> hasUnreadMessagesStream(String userId) {
    return _chatService.getMessagesStream(userId).map((messages) {
      return messages.any((m) => !m.isMe && !m.isRead);
    });
  }

  @override
  void dispose() {
    _chatService.dispose();
    super.dispose();
  }
}
