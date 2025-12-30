import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/poll_model.dart';
import '../../providers/polls_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_widget.dart';
import '../../widgets/buttons/primary_button.dart';

/// Screen for viewing poll details and results with percentage bars.
class ViewPollScreen extends StatefulWidget {
  final String pollId;

  const ViewPollScreen({
    super.key,
    required this.pollId,
  });

  @override
  State<ViewPollScreen> createState() => _ViewPollScreenState();
}

class _ViewPollScreenState extends State<ViewPollScreen> {
  final DatabaseService _databaseService = DatabaseService();

  PollModel? _poll;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPoll();
  }

  Future<void> _loadPoll() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final poll = await _databaseService.getPoll(widget.pollId);
      if (poll == null) {
        throw Exception('Poll not found');
      }
      setState(() {
        _poll = poll;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deletePoll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Poll'),
        content: const Text(
          'Are you sure you want to delete this poll? This action cannot be undone.',
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

      final pollsProvider = context.read<PollsProvider>();
      final success = await pollsProvider.deletePoll(widget.pollId, userId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Poll deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      } else if (mounted) {
        throw Exception(pollsProvider.error ?? 'Failed to delete poll');
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

  void _sharePoll() {
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
    final isCreator = userId != null && _poll?.creatorUid == userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Poll Results'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _poll != null ? _sharePoll : null,
            tooltip: 'Share',
          ),
          if (isCreator)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deletePoll();
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
                        'Delete Poll',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(theme, userId),
    );
  }

  Widget _buildBody(ThemeData theme, String? userId) {
    if (_isLoading) {
      return const LoadingIndicator(message: 'Loading poll...');
    }

    if (_error != null) {
      return BoldaskErrorWidget(
        message: _error!,
        onRetry: _loadPoll,
      );
    }

    if (_poll == null) {
      return const BoldaskErrorWidget(
        message: 'Poll not found',
      );
    }

    final hasVoted = userId != null && _poll!.hasUserVoted(userId);

    return RefreshIndicator(
      onRefresh: _loadPoll,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Poll creator info
          _buildCreatorInfo(theme),

          const SizedBox(height: 16),

          // Category badge
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _poll!.isPersonal
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                _poll!.categoryLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _poll!.isPersonal
                      ? theme.colorScheme.primary
                      : theme.colorScheme.secondary,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Question
          Text(
            _poll!.question,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 24),

          // Results with percentage bars
          Text(
            'Results',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(_poll!.answers.length, (index) {
            return _ResultBar(
              answer: _poll!.answers[index],
              percentage: _poll!.getVotePercentage(index),
              voteCount: index < _poll!.voteCounts.length
                  ? _poll!.voteCounts[index]
                  : 0,
              isHighest: _getHighestVoteIndex() == index,
            );
          }),

          const SizedBox(height: 24),

          // Total votes
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.how_to_vote_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_poll!.totalVotes} total votes',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Tags
          if (_poll!.tags.isNotEmpty) ...[
            Text(
              'Tags',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _poll!.tags.map((tag) {
                return Chip(
                  label: Text(tag),
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],

          // Vote button if user hasn't voted
          if (!hasVoted && userId != null)
            PrimaryButton(
              text: 'Vote on this Poll',
              onPressed: () => context.push('/polls/${widget.pollId}/vote'),
              icon: Icons.how_to_vote,
            ),

          if (hasVoted)
            Container(
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
                    Icons.check_circle,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'You have voted on this poll',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
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

  int _getHighestVoteIndex() {
    if (_poll == null || _poll!.voteCounts.isEmpty) return -1;
    int maxIndex = 0;
    int maxVotes = 0;
    for (int i = 0; i < _poll!.voteCounts.length; i++) {
      if (_poll!.voteCounts[i] > maxVotes) {
        maxVotes = _poll!.voteCounts[i];
        maxIndex = i;
      }
    }
    return maxVotes > 0 ? maxIndex : -1;
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
                _poll!.creatorName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatDate(_poll!.createdAt),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAvatar() {
    if (_poll!.creatorPhotoUrl != null && _poll!.creatorPhotoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: CachedNetworkImageProvider(_poll!.creatorPhotoUrl!),
      );
    }
    return CircleAvatar(
      radius: 20,
      child: Text(
        _poll!.creatorName.isNotEmpty
            ? _poll!.creatorName[0].toUpperCase()
            : '?',
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
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

/// Widget for displaying a result bar with percentage.
class _ResultBar extends StatelessWidget {
  final String answer;
  final double percentage;
  final int voteCount;
  final bool isHighest;

  const _ResultBar({
    required this.answer,
    required this.percentage,
    required this.voteCount,
    required this.isHighest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  answer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isHighest ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isHighest
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Stack(
            children: [
              // Background bar
              Container(
                height: 24,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Progress bar
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeInOut,
                height: 24,
                width: MediaQuery.of(context).size.width *
                    0.85 *
                    (percentage / 100),
                decoration: BoxDecoration(
                  color: isHighest
                      ? theme.colorScheme.primary
                      : theme.colorScheme.primary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // Vote count overlay
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '$voteCount votes',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: percentage > 20
                            ? Colors.white
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
