import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';
import 'dart:io';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Watch All Users
  Stream<List<UserModel>> getUsersStream() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
    });
  }

  // Create User Strategy:
  // We use a secondary Firebase App to create the user without signing out the Admin.
  Future<void> addUser(UserModel user, String password) async {
    try {
      log('DEBUG: Admin adding new user: ${user.email}');

      // 1. Create a temporary Firebase app to avoid auth state changes for the current Admin
      FirebaseApp tempApp;
      try {
        tempApp = Firebase.app('tempApp');
      } catch (e) {
        tempApp = await Firebase.initializeApp(
          name: 'tempApp',
          options: Firebase.app().options,
        );
      }

      final tempAuth = FirebaseAuth.instanceFor(app: tempApp);

      // 2. Create Auth User
      UserCredential cred = await tempAuth.createUserWithEmailAndPassword(
        email: user.email,
        password: password,
      );

      final uid = cred.user!.uid;

      // 3. Save to Firestore
      final newUser = UserModel(
        id: uid,
        name: user.name,
        email: user.email,
        password: password, // Store in Firestore as per original schema
        package: user.package,
        status: user.status,
        documents: user.documents,
        createdAt: user.createdAt,
        address: user.address,
        dob: user.dob,
        gender: user.gender,
        mobile: user.mobile,
      );

      await _firestore.collection('users').doc(uid).set(newUser.toJson());

      // 4. Cleanup
      await tempApp.delete();
      log('DEBUG: User created successfully: $uid');
    } catch (e) {
      log('DEBUG: Admin error adding user: $e');
      rethrow;
    }
  }

  // Edit User details
  Future<void> updateUser(UserModel user) async {
    try {
      log('DEBUG: Admin updating user: ${user.id}');
      await _firestore.collection('users').doc(user.id).update(user.toJson());
    } catch (e) {
      log('DEBUG: Admin error updating user: $e');
      rethrow;
    }
  }

  // Delete User
  Future<void> deleteUser(String userId) async {
    try {
      log('DEBUG: Admin deleting user: $userId');
      await _firestore.collection('users').doc(userId).delete();
    } catch (e) {
      log('DEBUG: Admin error deleting user: $e');
      rethrow;
    }
  }

  // Upload Document for User
  Future<String> uploadUserDocument(
      String userId, String filePath, String fileName) async {
    try {
      final file = File(filePath);
      final ref = _storage
          .ref()
          .child('users')
          .child(userId)
          .child('documents')
          .child(fileName);
      final uploadTask = await ref.putFile(file);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      log('DEBUG: Admin error uploading document: $e');
      rethrow;
    }
  }
}
