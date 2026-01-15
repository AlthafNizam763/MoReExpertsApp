import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Login with Email & Password
  Future<UserModel?> login(String email, String password) async {
    try {
      log('DEBUG: Attempting Firebase login with email: $email');

      // 1. Authenticate with Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 2. Fetch User Data from Firestore
      if (userCredential.user != null) {
        final uid = userCredential.user!.uid;
        log('DEBUG: Firebase Auth successful, fetching Firestore data for: $uid');

        final docSnapshot = await _firestore.collection('users').doc(uid).get();

        if (docSnapshot.exists && docSnapshot.data() != null) {
          log('DEBUG: Firestore data found');
          return UserModel.fromFirestore(docSnapshot);
        } else {
          log('DEBUG: User authenticated but no Firestore data found');
          return null;
        }
      }
      return null;
    } on FirebaseAuthException catch (e) {
      log('DEBUG: Firebase Auth Login failed: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      log('DEBUG: Unexpected error in Firebase AuthService: $e');
      rethrow;
    }
  }

  // Update User Profile
  Future<void> updateUser(UserModel user) async {
    try {
      log('DEBUG: Attempting to update user: ${user.id}');

      await _firestore.collection('users').doc(user.id).update(user.toJson());

      log('DEBUG: User updated successfully: ${user.id}');
    } catch (e) {
      log('DEBUG: Error updating user in Firestore: $e');
      rethrow;
    }
  }

  // Change Password
  Future<bool> changePassword(
      String userId, String currentPassword, String newPassword) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != userId) {
        throw Exception('No authenticated user found');
      }

      // Re-authenticate user to ensure security
      final cred = EmailAuthProvider.credential(
          email: user.email!, password: currentPassword);

      await user.reauthenticateWithCredential(cred);

      // Update password
      await user.updatePassword(newPassword);

      log('DEBUG: Password updated successfully via Firebase Auth');
      return true;
    } on FirebaseAuthException catch (e) {
      log('DEBUG: Firebase Password Change Error: ${e.code}');
      if (e.code == 'wrong-password') {
        throw Exception('Incorrect current password');
      }
      rethrow;
    } catch (e) {
      log('DEBUG: Error changing password: $e');
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    log('DEBUG: Logging out from Firebase');
    await _auth.signOut();
  }
}
