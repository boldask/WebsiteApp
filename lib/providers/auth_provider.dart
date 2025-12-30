import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

/// Provider for managing authentication state.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _error;

  /// Current authenticated user.
  User? get user => _user;

  /// Current user ID.
  String? get userId => _user?.uid;

  /// Whether user is authenticated.
  bool get isAuthenticated => _user != null;

  /// Whether authentication is in progress.
  bool get isLoading => _isLoading;

  /// Last error message.
  String? get error => _error;

  AuthProvider() {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      _user = user;
      notifyListeners();
    });
  }

  /// Sign in with email and password.
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Create account with email and password.
  Future<bool> createAccount({
    required String email,
    required String password,
    required String displayName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.createAccountWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Send password reset email.
  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.sendPasswordResetEmail(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out.
  Future<void> signOut() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  /// Clear error.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
