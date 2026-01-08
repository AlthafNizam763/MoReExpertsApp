import 'package:flutter/material.dart';
import 'package:more_experts/features/auth/data/auth_service.dart';
import 'package:more_experts/features/profile/domain/models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status = AuthStatus.initial;
  AuthStatus get status => _status;

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    // Initial status is unauthenticated until login
    _status = AuthStatus.unauthenticated;
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        _currentUser = user;
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
        _errorMessage = "Invalid email or password.";
      }
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
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> updateUser(UserModel user) async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.updateUser(user);
      _currentUser = user; // Update local user state
      _status = AuthStatus.authenticated;
    } catch (e) {
      print('DEBUG: AuthProvider caught error updating user: $e');
      _errorMessage = "Failed to update profile. Please try again.";
      // Don't change status to unauthenticated, just show error
    }

    notifyListeners();
  }

  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    if (_currentUser == null) return;

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      await _authService.changePassword(
          _currentUser!.id, currentPassword, newPassword);
      // Keep authenticated status after success
      _status = AuthStatus.authenticated;
    } catch (e) {
      print('DEBUG: AuthProvider caught error changing password: $e');
      _errorMessage = e.toString().contains('Incorrect current password')
          ? 'Incorrect current password'
          : "Failed to change password. Please try again.";
      // Restore authenticated status but keep error message for UI to show
      _status = AuthStatus.authenticated;
      rethrow;
    }

    notifyListeners();
  }
}
