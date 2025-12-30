import 'package:flutter/material.dart';
import '../models/poll_model.dart';
import '../services/database_service.dart';
import '../config/constants.dart';

/// Provider for managing polls state.
class PollsProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<PollModel> _polls = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _error;
  SortOption _sortOption = SortOption.popular;
  bool? _categoryFilter; // null = all, true = personal, false = social
  List<String> _tagFilters = [];

  /// List of polls.
  List<PollModel> get polls => _polls;

  /// Whether data is loading.
  bool get isLoading => _isLoading;

  /// Whether there are more polls to load.
  bool get hasMore => _hasMore;

  /// Last error message.
  String? get error => _error;

  /// Current sort option.
  SortOption get sortOption => _sortOption;

  /// Category filter.
  bool? get categoryFilter => _categoryFilter;

  /// Tag filters.
  List<String> get tagFilters => _tagFilters;

  /// Load polls with current filters.
  Future<void> loadPolls({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _polls = [];
      _hasMore = true;
    }

    if (!_hasMore) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newPolls = await _databaseService.getPolls(
        isPersonal: _categoryFilter,
        tags: _tagFilters.isEmpty ? null : _tagFilters,
      );

      if (newPolls.length < AppConstants.defaultPageSize) {
        _hasMore = false;
      }

      if (refresh) {
        _polls = newPolls;
      } else {
        _polls.addAll(newPolls);
      }

      _sortPolls();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Sort polls based on current sort option.
  void _sortPolls() {
    switch (_sortOption) {
      case SortOption.popular:
        _polls.sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
        break;
      case SortOption.newest:
        _polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.favorites:
      case SortOption.following:
        // These require user context, handled differently
        _polls.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
  }

  /// Set sort option.
  void setSortOption(SortOption option) {
    if (_sortOption != option) {
      _sortOption = option;
      _sortPolls();
      notifyListeners();
    }
  }

  /// Set category filter.
  void setCategoryFilter(bool? isPersonal) {
    if (_categoryFilter != isPersonal) {
      _categoryFilter = isPersonal;
      loadPolls(refresh: true);
    }
  }

  /// Set tag filters.
  void setTagFilters(List<String> tags) {
    _tagFilters = tags;
    loadPolls(refresh: true);
  }

  /// Add a tag filter.
  void addTagFilter(String tag) {
    if (!_tagFilters.contains(tag)) {
      _tagFilters.add(tag);
      loadPolls(refresh: true);
    }
  }

  /// Remove a tag filter.
  void removeTagFilter(String tag) {
    if (_tagFilters.remove(tag)) {
      loadPolls(refresh: true);
    }
  }

  /// Clear all filters.
  void clearFilters() {
    _categoryFilter = null;
    _tagFilters = [];
    loadPolls(refresh: true);
  }

  /// Create a new poll.
  Future<String?> createPoll(PollModel poll) async {
    try {
      final pollId = await _databaseService.createPoll(poll);
      await loadPolls(refresh: true);
      return pollId;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Vote on a poll.
  Future<bool> vote(String pollId, String oderId, int answerIndex) async {
    try {
      await _databaseService.votePoll(pollId, oderId, answerIndex);

      // Update local poll data
      final index = _polls.indexWhere((p) => p.id == pollId);
      if (index != -1) {
        final poll = _polls[index];
        final newVoteCounts = List<int>.from(poll.voteCounts);
        while (newVoteCounts.length <= answerIndex) {
          newVoteCounts.add(0);
        }
        newVoteCounts[answerIndex]++;

        _polls[index] = poll.copyWith(
          votedUserIds: [...poll.votedUserIds, oderId],
          voteCounts: newVoteCounts,
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

  /// Delete a poll.
  Future<bool> deletePoll(String pollId, String creatorUid) async {
    try {
      await _databaseService.deletePoll(pollId, creatorUid);
      _polls.removeWhere((p) => p.id == pollId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Get poll by ID.
  PollModel? getPollById(String id) {
    try {
      return _polls.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }
}
