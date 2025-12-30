import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/circle_model.dart';
import '../../models/user_model.dart';
import '../../providers/circles_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../config/constants.dart';

/// Screen for viewing circle details with attendee list.
class ViewCircleScreen extends StatefulWidget {
  final String circleId;

  const ViewCircleScreen({
    super.key,
    required this.circleId,
  });

  @override
  State<ViewCircleScreen> createState() => _ViewCircleScreenState();
}

class _ViewCircleScreenState extends State<ViewCircleScreen> {
  final DatabaseService _databaseService = DatabaseService();

  CircleModel? _circle;
  List<UserModel> _attendees = [];
  bool _isLoading = true;
  bool _isLoadingAttendees = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCircle();
  }

  Future<void> _loadCircle() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final circle = await _databaseService.getCircle(widget.circleId);
      if (circle == null) {
        throw Exception('Circle not found');
      }
      setState(() {
        _circle = circle;
        _isLoading = false;
      });
      _loadAttendees();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _loadAttendees() async {
    if (_circle == null || _circle!.attendeeIds.isEmpty) return;

    setState(() {
      _isLoadingAttendees = true;
    });

    try {
      final attendees = <UserModel>[];
      for (final userId in _circle!.attendeeIds.take(20)) {
        final user = await _databaseService.getUser(userId);
        if (user != null) {
          attendees.add(user);
        }
      }
      setState(() {
        _attendees = attendees;
        _isLoadingAttendees = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingAttendees = false;
      });
    }
  }

  Future<void> _leaveCircle() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Circle'),
        content: const Text(
          'Are you sure you want to leave this circle?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final circlesProvider = context.read<CirclesProvider>();
      final success =
          await circlesProvider.leaveCircle(widget.circleId, userId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have left the circle'),
            backgroundColor: Colors.green,
          ),
        );
        _loadCircle();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteCircle() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Circle'),
        content: const Text(
          'Are you sure you want to delete this circle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final userId = context.read<AuthProvider>().userId;
      if (userId == null) {
        throw Exception('You must be logged in');
      }

      final circlesProvider = context.read<CirclesProvider>();
      final success =
          await circlesProvider.deleteCircle(widget.circleId, userId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Circle deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        throw Exception(circlesProvider.error ?? 'Failed to delete circle');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _openMeetingLink() async {
    if (_circle?.meetingLink == null) return;

    final uri = Uri.tryParse(_circle!.meetingLink!);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Copy to clipboard as fallback
      await Clipboard.setData(ClipboardData(text: _circle!.meetingLink!));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Meeting link copied to clipboard'),
          ),
        );
      }
    }
  }

  void _shareCircle() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userId = context.watch<AuthProvider>().userId;
    final isCreator = userId != null && _circle?.creatorUid == userId;
    final isAttending = userId != null && _circle?.isUserAttending(userId) == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Details'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _circle != null ? _shareCircle : null,
            tooltip: 'Share',
          ),
          if (isCreator)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteCircle();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Circle',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(theme, userId, isCreator, isAttending),
    );
  }

  Widget _buildBody(
    ThemeData theme,
    String? userId,
    bool isCreator,
    bool isAttending,
  ) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading circle...');
    }

    if (_error != null) {
      return BoldaskErrorWidget(
        message: _error!,
        onRetry: _loadCircle,
      );
    }

    if (_circle == null) {
      return const BoldaskErrorWidget(
        message: 'Circle not found',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCircle,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Circle creator info
          _buildCreatorInfo(theme),

          const SizedBox(height: 16),

          // Format badge
          _buildFormatBadge(theme),

          const SizedBox(height: 16),

          // Title
          Text(
            _circle!.title,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Description
          Text(
            _circle!.description,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),

          const SizedBox(height: 24),

          // Date and Time
          _buildInfoCard(
            theme,
            icon: Icons.calendar_today,
            title: 'Date & Time',
            content: _formatDateTime(_circle!.scheduledDate),
            isPast: _circle!.isPast,
          ),

          const SizedBox(height: 12),

          // Location/Link based on format
          if (_circle!.format != CircleFormat.inPerson &&
              _circle!.meetingLink != null)
            _buildMeetingLinkCard(theme, isAttending),

          if (_circle!.format != CircleFormat.online &&
              _circle!.address != null) ...[
            const SizedBox(height: 12),
            _buildInfoCard(
              theme,
              icon: Icons.location_on_outlined,
              title: 'Location',
              content: _circle!.address!,
            ),
          ],

          const SizedBox(height: 24),

          // Attendees Section
          _buildAttendeesSection(theme),

          const SizedBox(height: 24),

          // Tags
          if (_circle!.tags.isNotEmpty) ...[
            Text(
              'Topics',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _circle!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Action buttons
          if (!_circle!.isPast) ...[
            if (!isAttending && !isCreator)
              PrimaryButton(
                text: _circle!.hasAvailableSpots
                    ? 'Join Circle'
                    : 'Circle is Full',
                onPressed: _circle!.hasAvailableSpots
                    ? () => context.push('/circles/${widget.circleId}/join')
                    : null,
                icon: Icons.group_add,
              ),
            if (isAttending && !isCreator)
              SecondaryButton(
                text: 'Leave Circle',
                onPressed: _leaveCircle,
                icon: Icons.exit_to_app,
              ),
          ],

          if (_circle!.isPast)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.event_busy,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'This circle has ended',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCreatorInfo(ThemeData theme) {
    return InkWell(
      onTap: () => context.push('/member/${_circle!.creatorUid}'),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _buildAvatar(_circle!.creatorPhotoUrl, _circle!.creatorName, 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hosted by',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  Text(
                    _circle!.creatorName,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(String? photoUrl, String name, double radius) {
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: CachedNetworkImageProvider(photoUrl),
      );
    }
    return CircleAvatar(
      radius: radius,
      child: Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(fontSize: radius * 0.8),
      ),
    );
  }

  Widget _buildFormatBadge(ThemeData theme) {
    IconData icon;
    Color color;

    switch (_circle!.format) {
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

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              _circle!.format.label,
              style: theme.textTheme.labelMedium?.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
    bool isPast = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPast
            ? theme.colorScheme.error.withOpacity(0.1)
            : theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isPast ? theme.colorScheme.error : theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                Text(
                  content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color:
                        isPast ? theme.colorScheme.error : null,
                  ),
                ),
              ],
            ),
          ),
          if (isPast)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Past',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMeetingLinkCard(ThemeData theme, bool isAttending) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.videocam_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Online Meeting',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    Text(
                      isAttending
                          ? _circle!.meetingLink!
                          : 'Join to see the meeting link',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: isAttending
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAttending) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openMeetingLink,
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Open Link'),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: _circle!.meetingLink!),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.copy, size: 18),
                  label: const Text('Copy'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttendeesSection(ThemeData theme) {
    final attendeeCount = _circle!.attendeeCount;
    final remainingSpots = _circle!.remainingSpots;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Attendees',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                remainingSpots != null
                    ? '$attendeeCount/${remainingSpots + attendeeCount}'
                    : '$attendeeCount attending',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isLoadingAttendees)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_attendees.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No attendees yet. Be the first to join!',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
          )
        else
          Column(
            children: _attendees.map((user) {
              return _AttendeeListItem(
                user: user,
                isCreator: user.uid == _circle!.creatorUid,
                onTap: () => context.push('/member/${user.uid}'),
              );
            }).toList(),
          ),
        if (_circle!.attendeeIds.length > 20)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'and ${_circle!.attendeeIds.length - 20} more...',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ),
      ],
    );
  }

  String _formatDateTime(DateTime date) {
    final dateStr = DateFormat.yMMMd().format(date);
    final timeStr = DateFormat.jm().format(date);
    return '$dateStr at $timeStr';
  }
}

/// Widget for secondary button.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(text),
                ],
              )
            : Text(text),
      ),
    );
  }
}

/// Widget for attendee list item.
class _AttendeeListItem extends StatelessWidget {
  final UserModel user;
  final bool isCreator;
  final VoidCallback onTap;

  const _AttendeeListItem({
    required this.user,
    required this.isCreator,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            _buildAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                user.displayName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (isCreator)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Host',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withOpacity(0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 18,
        backgroundImage: CachedNetworkImageProvider(user.photoUrl!),
      );
    }
    return CircleAvatar(
      radius: 18,
      child: Text(
        user.displayName.isNotEmpty
            ? user.displayName[0].toUpperCase()
            : '?',
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}
