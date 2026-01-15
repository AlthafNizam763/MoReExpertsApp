import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:developer';

class FeedbackService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> saveFeedback({
    required int rating,
    required String feedbackText,
    required String name,
    required String? profilePic,
  }) async {
    try {
      await _firestore.collection('feedback').add({
        'rating': rating,
        'feedbackText': feedbackText,
        'name': name,
        'profilePic': profilePic,
        'createdAt': FieldValue.serverTimestamp(),
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
      final snapshot = await _firestore
          .collection('feedback')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      log('Error fetching feedback: $e');
      return [];
    }
  }
}
