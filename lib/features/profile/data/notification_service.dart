import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:more_experts/features/profile/domain/models/notification_model.dart';

class NotificationService {
  final String collectionName = 'notifications';
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      log('Error fetching notifications: $e');
      return [];
    }
  }
}
