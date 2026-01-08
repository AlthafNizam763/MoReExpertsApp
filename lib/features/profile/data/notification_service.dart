import 'dart:developer';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:more_experts/core/services/mongodb_service.dart';
import 'package:more_experts/features/profile/domain/models/notification_model.dart';

class NotificationService {
  final MongoDBService _mongoDBService = MongoDBService();
  final String collectionName = 'notifications';

  Future<List<NotificationModel>> getNotifications() async {
    try {
      if (!_mongoDBService.isConnected) {
        await _mongoDBService.connect();
      }

      final collection = _mongoDBService.collection(collectionName);

      // Fetch notifications, sorted by createdAt descending (newest first)
      final notificationsData = await collection
          .find(where.sortBy('createdAt', descending: true))
          .toList();

      return notificationsData
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      log('Error fetching notifications: $e');
      return [];
    }
  }
}
