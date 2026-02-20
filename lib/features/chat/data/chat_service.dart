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

  // Stream of all conversations for Admin
  Stream<List<Map<String, dynamic>>> getAllConversationsStream() {
    try {
      return _firestore
          .collection('conversations')
          .orderBy('lastMessageTime', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });
    } catch (e) {
      log('DEBUG: Error getting all conversations stream: $e');
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

  // Mark all admin messages as read for a user
  Future<void> markMessagesAsRead(String userId) async {
    try {
      final unreadMessages = await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .where('role', isEqualTo: 'admin')
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (var doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // Also reset unreadCount in the conversation document
      await _firestore.collection('conversations').doc(userId).update({
        'unreadCount': 0,
      });

      log('DEBUG: Marked ${unreadMessages.docs.length} messages as read for $userId');
    } catch (e) {
      log('DEBUG: Error marking messages as read: $e');
    }
  }

  // Send message as Admin
  Future<void> sendMessageAsAdmin(
      String content, String userId, String userName) async {
    try {
      final timestamp = FieldValue.serverTimestamp();
      final clientTimestamp = DateTime.now().toUtc().toIso8601String();

      final messageData = {
        'text': content,
        'sender': 'MoRe Support',
        'role': 'support',
        'conversationId': userId,
        'timestamp': timestamp,
        'clientTimestamp': clientTimestamp,
        'createdAt': timestamp,
        'isRead': false,
      };

      // 1. Add message to subcollection
      await _firestore
          .collection('conversations')
          .doc(userId)
          .collection('messages')
          .add(messageData);

      // 2. Update parent document for user visibility
      await _firestore.collection('conversations').doc(userId).set({
        'lastMessage': content,
        'lastMessageTime': timestamp,
        'lastMessageClientTimestamp': clientTimestamp,
        'updatedAt': timestamp,
        'userId': userId,
        'userName': userName,
        'status': 'active',
        // Note: we don't increment unreadCount for admin's own view,
        // but we might want to flag it as unread for the user.
      }, SetOptions(merge: true));

      log('DEBUG: Admin message sent to Firestore conversations/$userId/messages');
    } catch (e) {
      log('DEBUG: Error sending admin message to Firestore: $e');
      rethrow;
    }
  }

  void dispose() {
    // Nothing to dispose for Firestore usually
  }
}
