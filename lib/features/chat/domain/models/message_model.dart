import 'package:mongo_dart/mongo_dart.dart';

class MessageModel {
  final String id;
  final String content;
  final String senderId;
  final DateTime timestamp;
  final bool isRead;
  final bool isMe; // Helper field for UI, not stored in DB

  MessageModel({
    required this.id,
    required this.content,
    required this.senderId,
    required this.timestamp,
    this.isRead = false,
    this.isMe = false,
  });

  factory MessageModel.fromJson(
      Map<String, dynamic> json, String currentUserId) {
    final id = json['_id'];
    return MessageModel(
      id: id is ObjectId ? id.toHexString() : id.toString(),
      content: json['content'] as String,
      senderId: json['senderId'] as String,
      timestamp: json['timestamp'] is DateTime
          ? json['timestamp']
          : DateTime.parse(json['timestamp'].toString()),
      isRead: json['isRead'] ?? false,
      isMe: json['senderId'] == currentUserId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': ObjectId.fromHexString(id),
      'content': content,
      'senderId': senderId,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
