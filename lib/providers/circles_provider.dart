import 'package:flutter/material.dart';
import '../models/circle_model.dart';
import '../services/database_service.dart';
import '../config/constants.dart';

/// Provider for managing circles state.
class CirclesProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<CircleModel> _circles = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  SortOption _sortOption = SortOption.newest;
  List<String> _tagFilters = [];
  bool _showUpcomingOnly = true;

  /// List of circles.
  List<CircleModel> get circles => _circles;

  /// Whether data is loading.
  bool get isLoading => _isLoading;

  /// Whether there are more circles to load.
  bool get hasMore => _hasMore;

  /// Last error message.
  String? get error => _error;

  /// Current sort option.
  SortOption get sortOption => _sortOption;

  /// Tag filters.
  List<String> get tagFilters => _tagFilters;

  /// Whether showing only upcoming circles.
  bool get showUpcomingOnly => _showUpcomingOnly;

  /// Load circles with current filters.
  Future<void> loadCircles({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _circles = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newCircles = await _databaseService.getCircles(
        tags: _tagFilters.isEmpty ? null : _tagFilters,
        upcomingOnly: _showUpcomingOnly,
      );

      if (newCircles.length < AppConstants.defaultPageSize) {
        _hasMore = false;
      }

      if (refresh) {
        _circles = newCircles;
      } else {
        _circles.addAll(newCircles);
      }

      _sortCircles();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sort circles based on current sort option.
  void _sortCircles() {
    switch (_sortOption) {
      case SortOption.popular:
        _circles.sort((a, b) => b.attendeeCount.compareTo(a.attendeeCount));
        break;
      case SortOption.newest:
        _circles.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
        break;
      case SortOption.favorites:
      case SortOption.following:
        _circles.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));
        break;
    }
  }

  /// Set sort option.
  void setSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      _sortCircles();
      notifyListeners();
    }
  }

  /// Set tag filters.
  void setTagFilters(List<String> tags) {
    _tagFilters = tags;
    loadCircles(refresh: true);
  }

  /// Toggle upcoming only filter.
  void toggleUpcomingOnly() {
    _showUpcomingOnly = !_showUpcomingOnly;
    loadCircles(refresh: true);
  }

  /// Clear all filters.
  void clearFilters() {
    _tagFilters = [];
    _showUpcomingOnly = true;
    loadCircles(refresh: true);
  }

  /// Create a new circle.
  Future<String?> createCircle(CircleModel circle) async {
    try {
      final circleId = await _databaseService.createCircle(circle);
      await loadCircles(refresh: true);
      return circleId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Join a circle.
  Future<bool> joinCircle(String circleId, String userId) async {
    try {
      await _databaseService.joinCircle(circleId, userId);

      // Update local circle data
      final index = _circles.indexWhere((c) => c.id == circleId);
      if (index != -1) {
        final circle = _circles[index];
        _circles[index] = circle.copyWith(
          attendeeIds: [...circle.attendeeIds, userId],
        );
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Leave a circle.
  Future<bool> leaveCircle(String circleId, String userId) async {
    try {
      await _databaseService.leaveCircle(circleId, userId);

      // Update local circle data
      final index = _circles.indexWhere((c) => c.id == circleId);
      if (index != -1) {
        final circle = _circles[index];
        final newAttendees = List<String>.from(circle.attendeeIds)
          ..remove(userId);
        _circles[index] = circle.copyWith(attendeeIds: newAttendees);
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Delete a circle.
  Future<bool> deleteCircle(String circleId, String creatorUid) async {
    try {
      await _databaseService.deleteCircle(circleId, creatorUid);
      _circles.removeWhere((c) => c.id == circleId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get circle by ID.
  CircleModel? getCircleById(String id) {
    try {
      return _circles.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }
}
