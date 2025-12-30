import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../../models/circle_model.dart';
import '../../providers/circles_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../config/constants.dart';

/// Screen for joining a circle.
class AnswerCircleScreen extends StatefulWidget {
  final String circleId;

  const AnswerCircleScreen({
    super.key,
    required this.circleId,
  });

  @override
  State<AnswerCircleScreen> createState() => _AnswerCircleScreenState();
}

class _AnswerCircleScreenState extends State<AnswerCircleScreen> {
  final DatabaseService _databaseService = DatabaseService();

  CircleModel? _circle;
  bool _isLoading = true;
  bool _isJoining = false;
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
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _joinCircle() async {
    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to join a circle'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user is already attending
    if (_circle!.isUserAttending(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You are already attending this circle'),
          backgroundColor: Colors.orange,
        ),
      );
      context.pushReplacement('/circles/${widget.circleId}');
      return;
    }

    // Check capacity
    if (!_circle!.hasAvailableSpots) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sorry, this circle is full'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isJoining = true;
    });

    try {
      final circlesProvider = context.read<CirclesProvider>();
      final success = await circlesProvider.joinCircle(widget.circleId, userId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Successfully joined the circle!'),
            backgroundColor: Colors.green,
          ),
        );
        context.pushReplacement('/circles/${widget.circleId}');
      } else if (mounted) {
        throw Exception(circlesProvider.error ?? 'Failed to join circle');
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
    } finally {
      if (mounted) {
        setState(() {
          _isJoining = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Circle'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
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

    final userId = context.watch<AuthProvider>().userId;
    final isAttending = userId != null && _circle!.isUserAttending(userId);
    final isPast = _circle!.isPast;

    // If user is already attending
    if (isAttending) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'You are attending this circle',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'View the circle details to see more information',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'View Circle',
                onPressed: () =>
                    context.pushReplacement('/circles/${widget.circleId}'),
                icon: Icons.visibility,
              ),
            ],
          ),
        ),
      );
    }

    // If circle is in the past
    if (isPast) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.event_busy,
                size: 64,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'This circle has ended',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'This event took place on ${DateFormat.yMMMd().format(_circle!.scheduledDate)}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'Browse Other Circles',
                onPressed: () => context.go('/'),
                icon: Icons.explore,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
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
              _buildInfoSection(
                theme,
                icon: Icons.calendar_today,
                title: 'Date & Time',
                content: _formatDateTime(_circle!.scheduledDate),
              ),

              // Location/Link based on format
              if (_circle!.format != CircleFormat.inPerson &&
                  _circle!.meetingLink != null) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  theme,
                  icon: Icons.videocam_outlined,
                  title: 'Online Meeting',
                  content: 'Link will be available after joining',
                ),
              ],

              if (_circle!.format != CircleFormat.online &&
                  _circle!.address != null) ...[
                const SizedBox(height: 16),
                _buildInfoSection(
                  theme,
                  icon: Icons.location_on_outlined,
                  title: 'Location',
                  content: _circle!.address!,
                ),
              ],

              const SizedBox(height: 24),

              // Capacity info
              _buildCapacityInfo(theme),

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
            ],
          ),
        ),

        // Join button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: _circle!.hasAvailableSpots ? 'Join Circle' : 'Circle is Full',
              isLoading: _isJoining,
              onPressed: _circle!.hasAvailableSpots ? _joinCircle : null,
              icon: Icons.group_add,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorInfo(ThemeData theme) {
    return Row(
      children: [
        _buildAvatar(),
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
      ],
    );
  }

  Widget _buildAvatar() {
    if (_circle!.creatorPhotoUrl != null &&
        _circle!.creatorPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 24,
        backgroundImage: CachedNetworkImageProvider(_circle!.creatorPhotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 24,
      child: Text(
        _circle!.creatorName.isNotEmpty
            ? _circle!.creatorName[0].toUpperCase()
            : '?',
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

  Widget _buildInfoSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: theme.colorScheme.primary,
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCapacityInfo(ThemeData theme) {
    final attendeeCount = _circle!.attendeeCount;
    final remainingSpots = _circle!.remainingSpots;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            remainingSpots != null
                ? '$attendeeCount attending - $remainingSpots spots left'
                : '$attendeeCount attending - Unlimited spots',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime date) {
    final dateStr = DateFormat.yMMMd().format(date);
    final timeStr = DateFormat.jm().format(date);
    return '$dateStr at $timeStr';
  }
}
