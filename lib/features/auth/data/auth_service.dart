import 'dart:developer';
import 'package:more_experts/core/services/mongodb_service.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AuthService {
  final MongoDBService _mongoDBService = MongoDBService();

  Future<UserModel?> login(String email, String password) async {
    try {
      log('DEBUG: Attempting MongoDB login with email: $email');

      final usersCollection = _mongoDBService.collection('users');
      final userData = await usersCollection.findOne({
        'email': email,
        'password': password,
      });

      if (userData != null) {
        log('DEBUG: MongoDB Raw User Data keys: ${userData.keys.toList()}');
        log('DEBUG: MongoDB ProfilePic value: ${userData['profilePic'] ?? userData['profile_pic']}');
        log('DEBUG: MongoDB Login successful for user: ${userData['_id']}');
        return UserModel.fromJson(userData);
      } else {
        log('DEBUG: MongoDB Login failed - Invalid credentials');
        return null;
      }
    } catch (e) {
      log('DEBUG: Unexpected error in MongoDB AuthService: $e');
      rethrow;
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      log('DEBUG: Attempting to update user: ${user.id}');

      final usersCollection = _mongoDBService.collection('users');

      // Values to update
      final updateData = {
        'name': user.name,
        'dob': user.dob, // Keep as is if String, or parse if needed
        'mobile': user.mobile,
        'email': user.email,
        'linkedin': user.linkedin,
        'address': user.address,
        'gender': user.gender,
        'profilePic': user.profilePic,
      };

      // Remove null values
      updateData.removeWhere((key, value) => value == null);

      var modifier = modify;
      updateData.forEach((key, value) {
        modifier = modifier.set(key, value);
      });

      final id = ObjectId.fromHexString(user.id);

      await usersCollection.update(
        where.eq('_id', id),
        modifier,
      );

      log('DEBUG: User updated successfully: $id');
    } catch (e) {
      log('DEBUG: Error updating user in MongoDB: $e');
      rethrow;
    }
  }

  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    try {
      final usersCollection = _mongoDBService.collection('users');
      final id = ObjectId.fromHexString(userId);

      final user = await usersCollection.findOne(where.eq('_id', id));

      if (user == null) {
        log('DEBUG: User not found for password change: $userId');
        throw Exception('User not found');
      }

      final dbPassword = user['password'] as String?;

      if (dbPassword != currentPassword) {
        log('DEBUG: Current password mismatch for user: $userId');
        throw Exception('Incorrect current password');
      }

      await usersCollection.update(
        where.eq('_id', id),
        modify.set('password', newPassword),
      );

      log('DEBUG: Password updated successfully for user: $userId');
      return true;
    } catch (e) {
      log('DEBUG: Error changing password: $e');
      rethrow;
    }
  }

  Future<void> logout() async {
    // For now, logout just involves clearing local state in AuthProvider
    log('DEBUG: Logging out from MongoDB session');
  }
}
