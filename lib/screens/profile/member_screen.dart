import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/cards/poll_card.dart';
import '../../widgets/cards/circle_card.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../models/user_model.dart';
import '../../models/poll_model.dart';
import '../../models/circle_model.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';

/// Screen for viewing another user's profile.
class MemberScreen extends StatefulWidget {
  final String userId;

  const MemberScreen({
    super.key,
    required this.userId,
  });

  @override
  State<MemberScreen> createState() => _MemberScreenState();
}

class _MemberScreenState extends State<MemberScreen>
    with SingleTickerProviderStateMixin {
  final DatabaseService _databaseService = DatabaseService();
  late TabController _tabController;

  UserModel? _member;
  List<PollModel> _memberPolls = [];
  List<CircleModel> _memberCircles = [];
  bool _isLoading = true;
  bool _isFollowing = false;
  bool _isFollowLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMemberData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Load member profile
      final memberDoc = await _databaseService.getUser(widget.userId);
      if (memberDoc != null) {
        _member = memberDoc;

        // Check if current user is following this member
        final currentUser = context.read<UserProvider>().currentUser;
        if (currentUser != null) {
          _isFollowing = currentUser.isFollowing(widget.userId);
        }

        // Load member's polls and circles
        await _loadMemberContent();
      } else {
        _error = 'User not found';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadMemberContent() async {
    try {
      // Load member's public polls
      final polls = await _databaseService.getPollsByCreator(widget.userId);
      final circles = await _databaseService.getCirclesByCreator(widget.userId);

      if (mounted) {
        setState(() {
          _memberPolls = polls;
          _memberCircles = circles;
        });
      }
    } catch (e) {
      // Silently fail for content loading
    }
  }

  Future<void> _toggleFollow() async {
    if (_member == null) return;

    setState(() {
      _isFollowLoading = true;
    });

    try {
      final userProvider = context.read<UserProvider>();

      if (_isFollowing) {
        await userProvider.unfollowUser(widget.userId);
      } else {
        await userProvider.followUser(widget.userId);
      }

      if (mounted) {
        setState(() {
          _isFollowing = !_isFollowing;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update follow status: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFollowLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentUserId = context.read<AuthProvider>().userId;
    final isOwnProfile = widget.userId == currentUserId;

    return AppScaffold(
      title: _member?.displayName ?? 'Profile',
      showBackButton: true,
      showBottomNav: false,
      showProfileInAppBar: false,
      body: _isLoading
          ? const LoadingIndicator(message: 'Loading profile...')
          : _error != null
              ? EmptyState(
                  icon: Icons.error_outline,
                  title: 'Unable to load profile',
                  message: _error,
                  actionLabel: 'Try Again',
                  onAction: _loadMemberData,
                )
              : _member == null
                  ? const EmptyState(
                      icon: Icons.person_off_outlined,
                      title: 'User not found',
                      message: 'This user may have been deleted.',
                    )
                  : NestedScrollView(
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverToBoxAdapter(
                            child: Column(
                              children: [
                                _buildProfileHeader(context, isOwnProfile),
                                _buildStatsRow(context),
                                const SizedBox(height: 16),
                              ],
                            ),
                          ),
                          SliverPersistentHeader(
                            pinned: true,
                            delegate: _StickyTabBarDelegate(
                              TabBar(
                                controller: _tabController,
                                tabs: const [
                                  Tab(text: 'Polls'),
                                  Tab(text: 'Circles'),
                                ],
                              ),
                              theme.colorScheme.surface,
                            ),
                          ),
                        ];
                      },
                      body: TabBarView(
                        controller: _tabController,
                        children: [
                          _buildPollsList(context),
                          _buildCirclesList(context),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, bool isOwnProfile) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(context, _member!.photoUrl, 50),

          const SizedBox(height: 16),

          // Name
          Text(
            _member!.displayName,
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),

          // Location
          if (_member!.location != null && _member!.location!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _member!.location!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          // Follow/Edit Button
          if (!isOwnProfile)
            SizedBox(
              width: 160,
              child: _isFollowing
                  ? SecondaryButton(
                      text: 'Following',
                      icon: Icons.check,
                      isLoading: _isFollowLoading,
                      isExpanded: true,
                      onPressed: _toggleFollow,
                    )
                  : PrimaryButton(
                      text: 'Follow',
                      icon: Icons.person_add_outlined,
                      isLoading: _isFollowLoading,
                      isExpanded: true,
                      onPressed: _toggleFollow,
                    ),
            )
          else
            SizedBox(
              width: 160,
              child: SecondaryButton(
                text: 'Edit Profile',
                icon: Icons.edit_outlined,
                isExpanded: true,
                onPressed: () => context.push(Routes.editProfile),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(BuildContext context, String? photoUrl, double radius) {
    final theme = Theme.of(context);

    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: radius,
        color: theme.colorScheme.primary,
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem(
            context,
            _member!.pollCount.toString(),
            'Polls',
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            _member!.circleCount.toString(),
            'Circles',
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            _member!.followerCount.toString(),
            'Followers',
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            _member!.followingCount.toString(),
            'Following',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String count, String label) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }

  Widget _buildPollsList(BuildContext context) {
    if (_memberPolls.isEmpty) {
      return const EmptyState(
        icon: Icons.poll_outlined,
        title: 'No polls yet',
        message: 'This user hasn\'t created any polls.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: _memberPolls.length,
      itemBuilder: (context, index) {
        return PollCard(poll: _memberPolls[index]);
      },
    );
  }

  Widget _buildCirclesList(BuildContext context) {
    if (_memberCircles.isEmpty) {
      return const EmptyState(
        icon: Icons.group_outlined,
        title: 'No circles yet',
        message: 'This user hasn\'t created any circles.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      itemCount: _memberCircles.length,
      itemBuilder: (context, index) {
        return CircleCard(circle: _memberCircles[index]);
      },
    );
  }
}

/// Sticky tab bar delegate for the sliver header.
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final Color backgroundColor;

  _StickyTabBarDelegate(this.tabBar, this.backgroundColor);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: backgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return tabBar != oldDelegate.tabBar ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
