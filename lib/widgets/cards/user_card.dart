import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';

/// Reusable user card widget for displaying user previews.
class UserCard extends StatelessWidget {
  final UserModel user;
  final bool showFollowButton;
  final bool isFollowing;
  final VoidCallback? onFollowTap;
  final VoidCallback? onTap;

  const UserCard({
    super.key,
    required this.user,
    this.showFollowButton = false,
    this.isFollowing = false,
    this.onFollowTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap ?? () => context.push('/user/${user.uid}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(),
              const SizedBox(width: 12),

              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName,
                      style: theme.textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        _buildStatText(context, user.pollCount, 'polls'),
                        const SizedBox(width: 12),
                        _buildStatText(context, user.circleCount, 'circles'),
                        const SizedBox(width: 12),
                        _buildStatText(context, user.followerCount, 'followers'),
                      ],
                    ),
                  ],
                ),
              ),

              // Follow button
              if (showFollowButton)
                ElevatedButton(
                  onPressed: onFollowTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isFollowing
                        ? theme.colorScheme.surface
                        : theme.colorScheme.primary,
                    foregroundColor: isFollowing
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onPrimary,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    minimumSize: const Size(80, 36),
                  ),
                  child: Text(isFollowing ? 'Following' : 'Follow'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 28,
        backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 28,
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : '?',
        style: const TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildStatText(BuildContext context, int count, String label) {
    final theme = Theme.of(context);
    return Text(
      '$count $label',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurface.withOpacity(0.6),
      ),
    );
  }
}

/// Compact user avatar with name for inline display.
class UserAvatarName extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double avatarRadius;
  final VoidCallback? onTap;

  const UserAvatarName({
    super.key,
    this.photoUrl,
    required this.name,
    this.avatarRadius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (photoUrl != null && photoUrl!.isNotEmpty)
            CircleAvatar(
              radius: avatarRadius,
              backgroundImage: CachedNetworkImageProvider(photoUrl!),
            )
          else
            CircleAvatar(
              radius: avatarRadius,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: TextStyle(fontSize: avatarRadius * 0.8),
              ),
            ),
          const SizedBox(width: 8),
          Text(
            name,
            style: Theme.of(context).textTheme.titleSmall,
          ),
        ],
      ),
    );
  }
}
