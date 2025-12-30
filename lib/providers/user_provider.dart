import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/database_service.dart';

/// Provider for managing current user data.
class UserProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  StreamSubscription? _userSubscription;

  /// Current user data.
  UserModel? get currentUser => _currentUser;

  /// Whether data is loading.
  bool get isLoading => _isLoading;

  /// Last error message.
  String? get error => _error;

  /// Load user data by ID.
  Future<void> loadUser(String uid) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Cancel previous subscription
      await _userSubscription?.cancel();

      // Subscribe to user data stream
      _userSubscription = _databaseService.streamUser(uid).listen(
        (user) {
          _currentUser = user;
          _isLoading = false;
          notifyListeners();
        },
        onError: (e) {
          _error = e.toString();
          _isLoading = false;
          notifyListeners();
        },
      );
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Update user profile.
  Future<bool> updateProfile({
    String? displayName,
    String? photoUrl,
    String? location,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['displayName'] = displayName;
      if (photoUrl != null) updates['photoUrl'] = photoUrl;
      if (location != null) updates['location'] = location;

      if (updates.isNotEmpty) {
        await _databaseService.updateUser(_currentUser!.uid, updates);
      }

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

  /// Follow a user.
  Future<bool> followUser(String targetUserId) async {
    if (_currentUser == null) return false;

    try {
      await _databaseService.followUser(_currentUser!.uid, targetUserId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Unfollow a user.
  Future<bool> unfollowUser(String targetUserId) async {
    if (_currentUser == null) return false;

    try {
      await _databaseService.unfollowUser(_currentUser!.uid, targetUserId);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Clear user data (on sign out).
  void clearUser() {
    _userSubscription?.cancel();
    _currentUser = null;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }
}
