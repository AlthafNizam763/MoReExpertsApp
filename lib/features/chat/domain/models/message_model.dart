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
    return MessageModel(
      id: id ?? (json['id'] ?? ''),
      text: json['text'] ?? json['content'] ?? '',
      sender: json['sender'] ?? json['senderId'] ?? '',
      role: json['role'] ?? 'user',
      conversationId: json['conversationId'] ?? '',
      timestamp: _parseTimestamp(json['timestamp'] ?? json['createdAt']),
      isRead: json['isRead'] ?? false,
      isMe: (json['sender'] ?? json['senderId']) == currentUserId,
    );
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        return DateTime.now();
      }
    }
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
