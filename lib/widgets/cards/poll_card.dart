import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/poll_model.dart';
import '../../config/routes.dart';
import 'package:intl/intl.dart';

/// Reusable poll card widget for displaying poll previews.
class PollCard extends StatelessWidget {
  final PollModel poll;
  final bool showVoteCount;
  final VoidCallback? onTap;

  const PollCard({
    super.key,
    required this.poll,
    this.showVoteCount = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () => context.push('/polls/${poll.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator info row
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          poll.creatorName,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatDate(poll.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Category badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: poll.isPersonal
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.colorScheme.secondary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      poll.isPersonal ? 'Personal' : 'Social',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: poll.isPersonal
                            ? theme.colorScheme.primary
                            : theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Question
              Text(
                poll.question,
                style: theme.textTheme.titleMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // Answer options preview
              ...poll.answers.take(3).map((answer) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.circle_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.4),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            answer,
                            style: theme.textTheme.bodyMedium,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  )),

              if (poll.answers.length > 3)
                Text(
                  '+${poll.answers.length - 3} more options',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),

              const SizedBox(height: 12),

              // Tags and vote count
              Row(
                children: [
                  // Tags
                  if (poll.tags.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: poll.tags.take(3).map((tag) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: Chip(
                                label: Text(tag),
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                labelStyle: theme.textTheme.labelSmall,
                                padding: EdgeInsets.zero,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                  // Vote count
                  if (showVoteCount) ...[
                    const SizedBox(width: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.how_to_vote_outlined,
                          size: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${poll.totalVotes} votes',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (poll.creatorPhotoUrl != null && poll.creatorPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(poll.creatorPhotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 20,
      child: Text(
        poll.creatorName.isNotEmpty ? poll.creatorName[0].toUpperCase() : '?',
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat.MMMd().format(date);
    }
  }
}
