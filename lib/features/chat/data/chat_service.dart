import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:more_experts/features/chat/domain/models/message_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream of messages
  Stream<List<MessageModel>> getMessagesStream(String currentUserId) {
    try {
      return _firestore
          .collection('conversations')
          .doc(currentUserId)
          .collection('messages')
          .orderBy('timestamp', descending: false)
          .snapshots()
          .map((snapshot) {
        final messages = snapshot.docs
            .map((doc) {
              try {
                return MessageModel.fromFirestore(doc, currentUserId);
              } catch (e) {
                log('DEBUG: Error parsing message doc ${doc.id}: $e');
                return null;
              }
            })
            .whereType<MessageModel>()
            .toList();

        // Client-side sort to fix ordering issues between Timestamp/String formats
        // This also handles pending writes (where server timestamp is null) by using
        // the clientTimestamp fallback (which is 'now'), ensuring they appear at the bottom.
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return messages;
      });
    } catch (e) {
      log('DEBUG: Error getting messages stream: $e');
      return const Stream.empty();
    }
  }

  // Send message via Firestore
  Future<void> sendMessage(
      String content, String senderId, String userName) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      final clientTimestamp = DateTime.now()
          .toUtc()
          .toIso8601String(); // Use standard string format for compatibility

      final messageData = {
        'text': content,
        'sender': senderId,
        'role': 'user',
        'conversationId': senderId,
        'timestamp': timestamp,
        'clientTimestamp':
            clientTimestamp, // Valid local time for immediate display
        'createdAt': timestamp,
        'isRead': false,
      };

      // 1. Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(senderId)
          .collection('messages')
          .add(messageData);

      // 2. Update parent document for Admin visibility
      await _firestore.collection('conversations').doc(senderId).set({
        'lastMessage': content,
        'lastMessageTime': timestamp,
        'lastMessageClientTimestamp':
            clientTimestamp, // Stable time for conversation list
        'updatedAt': timestamp,
        'userId': senderId,
        'userName': userName,
        'unreadCount': FieldValue.increment(1),
        'status': 'active',
        // 'userProfilePic': ... // Add if available
      }, SetOptions(merge: true));

      log('DEBUG: Message sent to Firestore conversations/$senderId/messages');
    } catch (e) {
      log('DEBUG: Error sending message to Firestore: $e');
      rethrow;
    }
  }

  void dispose() {
    // Nothing to dispose for Firestore usually
  }
}
