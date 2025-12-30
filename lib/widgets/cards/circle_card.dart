import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/circle_model.dart';
import '../../config/constants.dart';
import 'package:intl/intl.dart';

/// Reusable circle card widget for displaying circle previews.
class CircleCard extends StatelessWidget {
  final CircleModel circle;
  final VoidCallback? onTap;

  const CircleCard({
    super.key,
    required this.circle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap ?? () => context.push('/circles/${circle.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Creator and format row
              Row(
                children: [
                  _buildAvatar(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          circle.creatorName,
                          style: theme.textTheme.titleSmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          _formatScheduledDate(circle.scheduledDate),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Format badge
                  _buildFormatBadge(context),
                ],
              ),

              const SizedBox(height: 12),

              // Title
              Text(
                circle.title,
                style: theme.textTheme.titleMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              if (circle.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  circle.description,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              // Location/Link info
              if (circle.format != CircleFormat.online && circle.address != null)
                _buildInfoRow(
                  context,
                  Icons.location_on_outlined,
                  circle.address!,
                ),
              if (circle.format != CircleFormat.inPerson && circle.meetingLink != null)
                _buildInfoRow(
                  context,
                  Icons.link,
                  'Online meeting available',
                ),

              const SizedBox(height: 12),

              // Attendees and capacity
              Row(
                children: [
                  // Tags
                  if (circle.tags.isNotEmpty)
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: circle.tags.take(2).map((tag) {
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

                  // Attendee count
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 16,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        circle.remainingSpots != null
                            ? '${circle.attendeeCount}/${circle.remainingSpots! + circle.attendeeCount}'
                            : '${circle.attendeeCount} attending',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (circle.creatorPhotoUrl != null && circle.creatorPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(circle.creatorPhotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 20,
      child: Text(
        circle.creatorName.isNotEmpty ? circle.creatorName[0].toUpperCase() : '?',
      ),
    );
  }

  Widget _buildFormatBadge(BuildContext context) {
    final theme = Theme.of(context);
    IconData icon;
    Color color;

    switch (circle.format) {
      case CircleFormat.online:
        icon = Icons.videocam_outlined;
        color = Colors.blue;
        break;
      case CircleFormat.inPerson:
        icon = Icons.place_outlined;
        color = Colors.green;
        break;
      case CircleFormat.both:
        icon = Icons.public;
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            circle.format.label,
            style: theme.textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatScheduledDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.isNegative) {
      return 'Past event';
    } else if (difference.inDays == 0) {
      return 'Today at ${DateFormat.jm().format(date)}';
    } else if (difference.inDays == 1) {
      return 'Tomorrow at ${DateFormat.jm().format(date)}';
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date) + ' at ${DateFormat.jm().format(date)}';
    } else {
      return DateFormat.MMMd().format(date) + ' at ${DateFormat.jm().format(date)}';
    }
  }
}
