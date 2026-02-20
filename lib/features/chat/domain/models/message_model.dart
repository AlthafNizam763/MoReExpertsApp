import 'package:cloud_firestore/cloud_firestore.dart';

class MessageModel {
  final String id;
  final String text; // Was content
  final String sender; // Was senderId
  final String role; // New
  final String conversationId; // New
  final DateTime timestamp;
  final bool isRead;
  final bool isMe; // Helper

  MessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.role,
    required this.conversationId,
    required this.timestamp,
    this.isRead = false,
    this.isMe = false,
  });

  // Helper backward compatibility or simple getter if UI uses 'content'
  String get content => text;

  factory MessageModel.fromJson(Map<String, dynamic> json, String currentUserId,
      {String? id}) {
    // Try to get a valid timestamp from server timestamp first, then client timestamp
    // This fixes the issue where "pending" writes have null server timestamp
    // and default to DateTime.now(), creating a "ticking clock" effect.
    final timestamp = _parseTimestamp(
        json['timestamp'] ?? json['createdAt'], json['clientTimestamp']);

    return MessageModel(
      id: id ?? (json['id'] ?? ''),
      text: json['text'] ?? json['content'] ?? '',
      sender: json['sender'] ?? json['senderId'] ?? '',
      role: json['role'] ?? 'user',
      conversationId: json['conversationId'] ?? '',
      timestamp: timestamp,
      isRead: json['isRead'] ?? false,
      isMe: (json['role'] == 'admin' || json['role'] == 'support')
          ? false
          : ((json['sender'] ?? json['senderId']) == currentUserId),
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp,
      [dynamic clientTimestamp]) {
    // 1. Try primary server timestamp if it's a valid Timestamp object
    if (timestamp is Timestamp) return timestamp.toDate();

    // 2. If primary is null or invalid, try clientTimestamp (local fallback)
    if (clientTimestamp is Timestamp) return clientTimestamp.toDate();
    if (clientTimestamp is String) {
      try {
        return DateTime.parse(clientTimestamp);
      } catch (_) {}
    }

    // 3. Fallback for server timestamp if it was a String
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {}
    }

    // 4. Last resort: current time (better than crashing, but likely what we wanted to avoid)
    return DateTime.now();
  }

  factory MessageModel.fromFirestore(
      DocumentSnapshot doc, String currentUserId) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel.fromJson(data, currentUserId, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'sender': sender,
      'role': role,
      'conversationId': conversationId,
      'timestamp': Timestamp.fromDate(timestamp),
      'createdAt': Timestamp.fromDate(timestamp), // Redundant but requested
      'isRead': isRead,
    };
  }
}
