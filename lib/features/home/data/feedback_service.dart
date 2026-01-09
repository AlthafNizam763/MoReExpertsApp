import 'package:more_experts/core/services/mongodb_service.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'dart:developer';

class FeedbackService {
  final MongoDBService _mongoDBService = MongoDBService();

  Future<bool> saveFeedback({
    required int rating,
    required String feedbackText,
    required String name,
    required String? profilePic,
  }) async {
    try {
      final collection = _mongoDBService.collection('feedback');

      await collection.insertOne({
        '_id': ObjectId(),
        'rating': rating,
        'feedbackText': feedbackText,
        'name': name,
        'profilePic': profilePic,
        'createdAt': DateTime.now().toIso8601String(),
      });

      log('Feedback saved successfully');
      return true;
    } catch (e) {
      log('Error saving feedback: $e');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getFeedback() async {
    try {
      final collection = _mongoDBService.collection('feedback');
      final feedbackList = await collection
          .find(where.sortBy('createdAt', descending: true))
          .toList();
      return feedbackList;
    } catch (e) {
      log('Error fetching feedback: $e');
      return [];
    }
  }
}
