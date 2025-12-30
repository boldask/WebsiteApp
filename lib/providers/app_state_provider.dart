import 'package:flutter/material.dart';

/// Provider for managing app-wide UI state.
class AppStateProvider extends ChangeNotifier {
  int _currentTabIndex = 0;
  bool _showFullList = true;
  int _pollSortIndex = 0;
  int _circleSortIndex = 0;
  bool _isDarkMode = false;

  /// Current bottom navigation tab index.
  int get currentTabIndex => _currentTabIndex;

  /// Whether dark mode is enabled.
  bool get isDarkMode => _isDarkMode;

  /// Whether to show full list (vs search results).
  bool get showFullList => _showFullList;

  /// Current poll sort index.
  int get pollSortIndex => _pollSortIndex;

  /// Current circle sort index.
  int get circleSortIndex => _circleSortIndex;

  /// Set current tab index.
  void setTabIndex(int index) {
    if (_currentTabIndex != index) {
      _currentTabIndex = index;
      notifyListeners();
    }
  }

  /// Toggle full list / search results.
  void setShowFullList(bool value) {
    if (_showFullList != value) {
      _showFullList = value;
      notifyListeners();
    }
  }

  /// Set poll sort index.
  void setPollSortIndex(int index) {
    if (_pollSortIndex != index) {
      _pollSortIndex = index;
      notifyListeners();
    }
  }

  /// Set circle sort index.
  void setCircleSortIndex(int index) {
    if (_circleSortIndex != index) {
      _circleSortIndex = index;
      notifyListeners();
    }
  }

  /// Toggle dark mode.
  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
  }

  /// Set dark mode.
  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      notifyListeners();
    }
  }

  /// Reset to default state.
  void reset() {
    _currentTabIndex = 0;
    _showFullList = true;
    _pollSortIndex = 0;
    _circleSortIndex = 0;
    _isDarkMode = false;
    notifyListeners();
  }
}
