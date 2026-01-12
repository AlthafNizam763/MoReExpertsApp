import 'dart:developer';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:more_experts/core/services/mongodb_service.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatService {
  final MongoDBService _mongoDBService = MongoDBService();
  final String _collectionName = 'messages';
  IO.Socket? _socket;

  // Initialize Socket Connection
  void initSocket(String userId) {
    if (_socket != null && _socket!.connected) return;

    final socketUri = dotenv.env['SOCKET_URI'];
    if (socketUri == null) {
      log('ERROR: SOCKET_URI not found in .env');
      return;
    }

    _socket = IO.io(socketUri, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
      'query': {'userId': userId},
    });

    _socket!.connect();

    _socket!.onConnect((_) {
      log('DEBUG: Socket connected to $socketUri');
    });

    _socket!.onDisconnect((_) {
      log('DEBUG: Socket disconnected');
    });

    _socket!.onError((data) {
      log('DEBUG: Socket error: $data');
    });
  }

  // Listen for new messages
  void onMessageReceived(
      Function(MessageModel) callback, String currentUserId) {
    _socket?.on('receive_message', (data) {
      log('DEBUG: Socket received message: $data');
      try {
        final message = MessageModel.fromJson(data, currentUserId);
        callback(message);
      } catch (e) {
        log('DEBUG: Error parsing received socket message: $e');
      }
    });
  }

  // Send message via Socket
  void sendMessage(String content, String senderId) {
    if (_socket == null || !_socket!.connected) {
      log('WARNING: Socket not connected. Cannot send message via socket. Attempting fallback or reconnect.');
      initSocket(senderId);
      // Depending on backend, we might want to throw error or try to db-insert directly
      // For now, let's assume socket is primary
    }

    final messageData = {
      'content': content,
      'senderId': senderId,
      'timestamp': DateTime.now().toIso8601String(),
    };

    // We expect the server to handle saving to DB and broadcasting
    _socket?.emit('send_message', messageData);
    log('DEBUG: Emitted send_message: $messageData');

    // Fallback: If your server doesn't save to DB, you might need to insert manually here
    // But typically real-time chat servers handle persistence.
    // _insertToMongoDB(content, senderId);
  }

  // Fetch initial history from MongoDB
  Future<List<MessageModel>> getMessages(String currentUserId) async {
    try {
      final messagesCollection = _mongoDBService.collection(_collectionName);

      final messagesData = await messagesCollection
          .find(
            where.sortBy('timestamp'),
          )
          .toList();

      return messagesData
          .map((json) => MessageModel.fromJson(json, currentUserId))
          .toList();
    } catch (e) {
      log('DEBUG: Error fetching history from MongoDB: $e');
      rethrow;
    }
  }

  void dispose() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
  }
}
