import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Stream to listen to auth state changes
  Stream<User?> get user => _auth.authStateChanges();

  Future<UserCredential> login(String email, String password) async {
    try {
      print('DEBUG: Attempting login with email: $email');
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      print('DEBUG: Login successful for user: ${credential.user?.uid}');
      return credential;
    } on FirebaseAuthException catch (e) {
      print(
          'DEBUG: FirebaseAuthException caught in AuthService: ${e.code} - ${e.message}');
      rethrow;
    } catch (e) {
      print('DEBUG: Unexpected error in AuthService: $e');
      rethrow; // Rethrow the actual error instead of a generic one
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }
}
