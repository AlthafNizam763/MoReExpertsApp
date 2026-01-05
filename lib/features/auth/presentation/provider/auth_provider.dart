import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../data/auth_service.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  User? _currentUser;
  User? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Listen to auth state changes
    _authService.user.listen((User? user) {
      _currentUser = user;
      if (user != null) {
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
      notifyListeners();
    });
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.login(email, password);
      // Status will be updated via the stream listener
    } on FirebaseAuthException catch (e) {
      print('DEBUG: AuthProvider caught FirebaseAuthException: ${e.code}');
      _status = AuthStatus.unauthenticated;
      _errorMessage = _mapFirebaseError(e.code);
    } catch (e) {
      print('DEBUG: AuthProvider caught unexpected error: $e');
      _status = AuthStatus.unauthenticated;
      _errorMessage =
          "An unexpected error occurred. Please check your connection.";
    }

    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.logout();
    // Status will be updated via the stream listener
  }

  String _mapFirebaseError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found for that email.';
      case 'wrong-password':
        return 'Wrong password provided.';
      case 'invalid-email':
        return 'The email address is badly formatted.';
      case 'user-disabled':
        return 'This user has been disabled.';
      default:
        return 'Authentication failed: $code';
    }
  }
}
