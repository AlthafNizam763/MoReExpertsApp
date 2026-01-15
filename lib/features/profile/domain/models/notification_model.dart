import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String description;
  final String type; // 'update', 'offer', etc.
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json, {String? id}) {
    return NotificationModel(
      id: id ?? (json['id'] ?? ''),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? 'general',
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? (json['createdAt'] as Timestamp).toDate()
              : DateTime.parse(json['createdAt'].toString()))
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
    );
  }

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel.fromJson(data, id: doc.id);
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Just now';
    }
  }
}
