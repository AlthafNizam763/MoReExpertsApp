import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:more_experts/features/auth/data/auth_service.dart';
import 'package:more_experts/core/constants/service_package.dart';
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
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    _status = AuthStatus.loading;
    notifyListeners();

    try {
      // 1. Check for Admin persistence first
      final prefs = await SharedPreferences.getInstance();
      final isAdminSession = prefs.getBool('is_admin_logged') ?? false;

      if (isAdminSession) {
        _isAdmin = true;
        _currentUser = UserModel(
          id: 'admin_id',
          name: 'Admin',
          email: 'chop@chip.com',
          password: 'chop123',
          package: ServicePackage.premium2,
          status: 'active',
          documents: UserDocuments(),
          createdAt: DateTime.now(),
          address: '',
          dob: '',
          gender: '',
          mobile: '',
        );
        _status = AuthStatus.authenticated;
        notifyListeners();
        return;
      }

      // 2. Fallback to Firebase session
      final user = await _authService.getCurrentUser();
      if (user != null) {
        if (user.status.toLowerCase() == 'suspended') {
          await _authService.logout();
          _status = AuthStatus.unauthenticated;
        } else {
          _isAdmin = false;
          _currentUser = user;
          _status = AuthStatus.authenticated;
        }
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      print('DEBUG: AuthProvider error checking session: $e');
      _status = AuthStatus.unauthenticated;
    }

    notifyListeners();
  }

  Future<void> refreshUserData() async {
    if (_currentUser == null) return;

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        if (user.status.toLowerCase() == 'suspended') {
          await logout();
        } else {
          _currentUser = user;
          notifyListeners();
        }
      }
    } catch (e) {
      print('DEBUG: AuthProvider error refreshing user data: $e');
      // Silently fail on refresh error, keeping old data
    }
  }

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    if (email.trim().toLowerCase() == 'chop@chip.com' &&
        password == 'chop123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin_logged', true);

      _isAdmin = true;
      _currentUser = UserModel(
        id: 'admin_id',
        name: 'Admin',
        email: email,
        password: password,
        package: ServicePackage.premium2,
        status: 'active',
        documents: UserDocuments(),
        createdAt: DateTime.now(),
        address: '',
        dob: '',
        gender: '',
        mobile: '',
      );
      _status = AuthStatus.authenticated;
      notifyListeners();
      return;
    }

    try {
      final user = await _authService.login(email, password);
      if (user != null) {
        if (user.status.toLowerCase() == 'suspended') {
          await _authService.logout();
          _status = AuthStatus.unauthenticated;
          _errorMessage = "Your account has been suspended by the admin.";
        } else {
          _isAdmin = false;
          _currentUser = user;
          _status = AuthStatus.authenticated;
        }
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
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('is_admin_logged');

    await _authService.logout();
    _currentUser = null;
    _status = AuthStatus.unauthenticated;
    _isAdmin = false;
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
