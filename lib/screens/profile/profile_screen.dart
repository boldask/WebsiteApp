import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../widgets/common/app_scaffold.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../providers/user_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';

/// User profile screen showing current user's profile and stats.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 600;

    return AppScaffold(
      title: 'Profile',
      showBackButton: true,
      showBottomNav: false,
      showProfileInAppBar: false,
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => context.push(Routes.settings),
        ),
      ],
      body: Consumer<UserProvider>(
        builder: (context, userProvider, _) {
          final user = userProvider.currentUser;

          if (userProvider.isLoading && user == null) {
            return const LoadingIndicator(message: 'Loading profile...');
          }

          if (user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'Unable to load profile',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: 'Try Again',
                    isExpanded: false,
                    onPressed: () {
                      final authProvider = context.read<AuthProvider>();
                      if (authProvider.userId != null) {
                        userProvider.loadUser(authProvider.userId!);
                      }
                    },
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Profile Header
                _buildProfileHeader(context, user, isLargeScreen),

                // Stats Row
                _buildStatsRow(context, user),

                const SizedBox(height: 24),

                // Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SecondaryButton(
                    text: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    onPressed: () => context.push(Routes.editProfile),
                  ),
                ),

                const SizedBox(height: 24),

                // Activity Section
                _buildActivitySection(context, user),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(
    BuildContext context,
    dynamic user,
    bool isLargeScreen,
  ) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Avatar
          _buildAvatar(context, user.photoUrl, 60),

          const SizedBox(height: 16),

          // Name
          Text(
            user.displayName,
            style: theme.textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            user.email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),

          // Location
          if (user.location != null && user.location!.isNotEmpty) ...[
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
                  user.location!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildStatsRow(BuildContext context, dynamic user) {
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
            user.pollCount.toString(),
            'Polls',
            Icons.poll_outlined,
            () => context.push(Routes.ownPolls),
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            user.circleCount.toString(),
            'Circles',
            Icons.group_outlined,
            () => context.push(Routes.ownCircles),
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            user.followerCount.toString(),
            'Followers',
            Icons.people_outlined,
            () => context.push(Routes.follow),
          ),
          _buildDivider(context),
          _buildStatItem(
            context,
            user.followingCount.toString(),
            'Following',
            Icons.person_add_outlined,
            () => context.push(Routes.follow),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String count,
    String label,
    IconData icon,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Column(
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
        ),
      ),
    );
  }

  Widget _buildDivider(BuildContext context) {
    return Container(
      height: 40,
      width: 1,
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
    );
  }

  Widget _buildActivitySection(BuildContext context, dynamic user) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Activity',
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Activity Cards
          _buildActivityCard(
            context,
            'My Polls',
            'View polls you\'ve created',
            Icons.poll_outlined,
            BoldaskColors.primary,
            () => context.push(Routes.ownPolls),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            context,
            'Participated Polls',
            'Polls you\'ve voted on',
            Icons.how_to_vote_outlined,
            BoldaskColors.secondary,
            () => context.push(Routes.participatedPolls),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            context,
            'My Circles',
            'Circles you\'ve created',
            Icons.group_outlined,
            BoldaskColors.info,
            () => context.push(Routes.ownCircles),
          ),
          const SizedBox(height: 12),
          _buildActivityCard(
            context,
            'Joined Circles',
            'Circles you\'re attending',
            Icons.event_available_outlined,
            BoldaskColors.success,
            () => context.push(Routes.participatedCircles),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: theme.colorScheme.onSurface.withOpacity(0.4),
        ),
      ),
    );
  }
}
