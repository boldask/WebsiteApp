import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/user_card.dart';
import '../../widgets/forms/styled_text_field.dart';

/// Following management screen with search and follow/unfollow functionality.
class FollowScreen extends StatefulWidget {
  const FollowScreen({super.key});

  @override
  State<FollowScreen> createState() => _FollowScreenState();
}

class _FollowScreenState extends State<FollowScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final DatabaseService _databaseService = DatabaseService();
  final TextEditingController _searchController = TextEditingController();

  // State
  List<UserModel> _searchResults = [];
  List<UserModel> _followers = [];
  List<UserModel> _following = [];
  bool _isSearching = false;
  bool _isLoadingFollowers = false;
  bool _isLoadingFollowing = false;
  Set<String> _processingUsers = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadFollowing();
    _loadFollowers();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.index == 1 && _followers.isEmpty && !_isLoadingFollowers) {
      _loadFollowers();
    } else if (_tabController.index == 2 && _following.isEmpty && !_isLoadingFollowing) {
      _loadFollowing();
    }
    // Clear search when switching tabs
    if (_tabController.index != 0) {
      _searchController.clear();
      setState(() {
        _searchResults = [];
      });
    }
  }

  Future<void> _loadFollowers() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingFollowers = true;
    });

    try {
      final followers = <UserModel>[];
      for (final userId in currentUser.followers) {
        final user = await _databaseService.getUser(userId);
        if (user != null) {
          followers.add(user);
        }
      }
      setState(() {
        _followers = followers;
        _isLoadingFollowers = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFollowers = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load followers: $e')),
        );
      }
    }
  }

  Future<void> _loadFollowing() async {
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    if (currentUser == null) return;

    setState(() {
      _isLoadingFollowing = true;
    });

    try {
      final following = <UserModel>[];
      for (final userId in currentUser.following) {
        final user = await _databaseService.getUser(userId);
        if (user != null) {
          following.add(user);
        }
      }
      setState(() {
        _following = following;
        _isLoadingFollowing = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingFollowing = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load following: $e')),
        );
      }
    }
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    try {
      final results = await _databaseService.searchUsers(query.trim());
      final authProvider = context.read<AuthProvider>();
      // Filter out current user
      final filteredResults = results
          .where((user) => user.uid != authProvider.user?.uid)
          .toList();
      setState(() {
        _searchResults = filteredResults;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search failed: $e')),
        );
      }
    }
  }

  Future<void> _toggleFollow(UserModel targetUser) async {
    final authProvider = context.read<AuthProvider>();
    final userProvider = context.read<UserProvider>();
    final currentUser = userProvider.currentUser;
    final currentUserId = authProvider.user?.uid;

    if (currentUser == null || currentUserId == null) return;
    if (_processingUsers.contains(targetUser.uid)) return;

    setState(() {
      _processingUsers.add(targetUser.uid);
    });

    try {
      final isCurrentlyFollowing = currentUser.isFollowing(targetUser.uid);

      if (isCurrentlyFollowing) {
        await _databaseService.unfollowUser(currentUserId, targetUser.uid);
        // Update local state
        setState(() {
          _following.removeWhere((u) => u.uid == targetUser.uid);
        });
      } else {
        await _databaseService.followUser(currentUserId, targetUser.uid);
        // Update local state
        setState(() {
          if (!_following.any((u) => u.uid == targetUser.uid)) {
            _following.add(targetUser);
          }
        });
      }

      // Refresh user data
      await userProvider.loadUser(userProvider.currentUser!.uid);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status: $e')),
        );
      }
    } finally {
      setState(() {
        _processingUsers.remove(targetUser.uid);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Following',
      showBackButton: true,
      showBottomNav: false,
      body: Column(
        children: [
          // Tab bar
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Search'),
                Tab(text: 'Followers'),
                Tab(text: 'Following'),
              ],
            ),
          ),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSearchTab(),
                _buildFollowersTab(),
                _buildFollowingTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTab() {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    return Column(
      children: [
        // Search input
        Padding(
          padding: const EdgeInsets.all(16),
          child: StyledTextField(
            controller: _searchController,
            hintText: 'Search for people...',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _searchUsers('');
                    },
                  )
                : null,
            onChanged: (value) => _searchUsers(value),
          ),
        ),

        // Search results
        Expanded(
          child: _isSearching
              ? const LoadingIndicator(message: 'Searching...')
              : _searchResults.isEmpty
                  ? _searchController.text.isEmpty
                      ? const EmptyState(
                          icon: Icons.search,
                          title: 'Find People',
                          message: 'Search by name to discover and follow other members.',
                        )
                      : const EmptyState(
                          icon: Icons.person_search_outlined,
                          title: 'No Results',
                          message: 'No users found matching your search.',
                        )
                  : ListView.builder(
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final user = _searchResults[index];
                        final isFollowing = currentUser?.isFollowing(user.uid) ?? false;
                        final isProcessing = _processingUsers.contains(user.uid);

                        return UserCard(
                          user: user,
                          showFollowButton: true,
                          isFollowing: isFollowing,
                          onFollowTap: isProcessing ? null : () => _toggleFollow(user),
                        );
                      },
                    ),
        ),
      ],
    );
  }

  Widget _buildFollowersTab() {
    final userProvider = context.watch<UserProvider>();
    final currentUser = userProvider.currentUser;

    if (_isLoadingFollowers) {
      return const LoadingIndicator(message: 'Loading followers...');
    }

    if (_followers.isEmpty) {
      return EmptyState(
        icon: Icons.people_outline,
        title: 'No Followers Yet',
        message: 'When people follow you, they\'ll appear here.',
        actionLabel: 'Find People',
        onAction: () => _tabController.animateTo(0),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowers,
      child: ListView.builder(
        itemCount: _followers.length,
        itemBuilder: (context, index) {
          final user = _followers[index];
          final isFollowing = currentUser?.isFollowing(user.uid) ?? false;
          final isProcessing = _processingUsers.contains(user.uid);

          return UserCard(
            user: user,
            showFollowButton: true,
            isFollowing: isFollowing,
            onFollowTap: isProcessing ? null : () => _toggleFollow(user),
          );
        },
      ),
    );
  }

  Widget _buildFollowingTab() {
    if (_isLoadingFollowing) {
      return const LoadingIndicator(message: 'Loading following...');
    }

    if (_following.isEmpty) {
      return EmptyState(
        icon: Icons.person_add_outlined,
        title: 'Not Following Anyone',
        message: 'Find interesting people to follow and see their content in your feed.',
        actionLabel: 'Find People',
        onAction: () => _tabController.animateTo(0),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFollowing,
      child: ListView.builder(
        itemCount: _following.length,
        itemBuilder: (context, index) {
          final user = _following[index];
          final isProcessing = _processingUsers.contains(user.uid);

          return UserCard(
            user: user,
            showFollowButton: true,
            isFollowing: true,
            onFollowTap: isProcessing ? null : () => _toggleFollow(user),
          );
        },
      ),
    );
  }
}
