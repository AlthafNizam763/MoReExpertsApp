import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:more_experts/features/chat/data/chat_service.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';

class ChatProvider extends ChangeNotifier {
  final ChatService _chatService = ChatService();
  List<MessageModel> _messages = [];
  bool _isLoading = false;
  StreamSubscription<List<MessageModel>>? _messagesSubscription;

  List<MessageModel> get messages => _messages;
  bool get isLoading => _isLoading;

  void initChat(String currentUserId) {
    _isLoading = true;
    notifyListeners();

    _messagesSubscription?.cancel();
    _messagesSubscription =
        _chatService.getMessagesStream(currentUserId).listen(
      (messages) {
        _messages = messages;
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        log('Error listening to chat stream: $error');
        _isLoading = false;
        notifyListeners();
      },
    );
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

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _chatService.dispose();
    super.dispose();
  }
}
