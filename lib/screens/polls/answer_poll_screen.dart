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

/// Screen for voting on a poll.
class AnswerPollScreen extends StatefulWidget {
  final String pollId;

  const AnswerPollScreen({
    super.key,
    required this.pollId,
  });

  @override
  State<AnswerPollScreen> createState() => _AnswerPollScreenState();
}

class _AnswerPollScreenState extends State<AnswerPollScreen> {
  final DatabaseService _databaseService = DatabaseService();

  PollModel? _poll;
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;
  int? _selectedAnswerIndex;

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

  Future<void> _submitVote() async {
    if (_selectedAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an answer'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final userId = context.read<AuthProvider>().userId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be logged in to vote'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if user has already voted
    if (_poll!.hasUserVoted(userId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You have already voted on this poll'),
          backgroundColor: Colors.orange,
        ),
      );
      // Navigate to view results
      context.pushReplacement('/polls/${widget.pollId}/results');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final pollsProvider = context.read<PollsProvider>();
      final success = await pollsProvider.vote(
        widget.pollId,
        userId,
        _selectedAnswerIndex!,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vote submitted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Navigate to view results
        context.pushReplacement('/polls/${widget.pollId}/results');
      } else if (mounted) {
        throw Exception(pollsProvider.error ?? 'Failed to submit vote');
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
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Vote'),
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

    final userId = context.watch<AuthProvider>().userId;
    final hasVoted = userId != null && _poll!.hasUserVoted(userId);

    // If user has already voted, show message and redirect option
    if (hasVoted) {
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
                'You have already voted',
                style: theme.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'View the results to see how others voted',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              PrimaryButton(
                text: 'View Results',
                onPressed: () =>
                    context.pushReplacement('/polls/${widget.pollId}/results'),
                icon: Icons.bar_chart,
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
              // Poll creator info
              _buildCreatorInfo(theme),

              const SizedBox(height: 16),

              // Category badge
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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

              // Answer options as radio buttons
              Text(
                'Select your answer:',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 12),
              ...List.generate(_poll!.answers.length, (index) {
                return _AnswerOption(
                  answer: _poll!.answers[index],
                  index: index,
                  isSelected: _selectedAnswerIndex == index,
                  onTap: _isSubmitting
                      ? null
                      : () {
                          setState(() {
                            _selectedAnswerIndex = index;
                          });
                        },
                );
              }),

              const SizedBox(height: 24),

              // Tags
              if (_poll!.tags.isNotEmpty) ...[
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

              // Vote count
              Row(
                children: [
                  Icon(
                    Icons.how_to_vote_outlined,
                    size: 18,
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_poll!.totalVotes} votes so far',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Submit button
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PrimaryButton(
              text: 'Submit Vote',
              isLoading: _isSubmitting,
              onPressed: _selectedAnswerIndex != null ? _submitVote : null,
              icon: Icons.check,
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

/// Widget for an answer option with radio button style.
class _AnswerOption extends StatelessWidget {
  final String answer;
  final int index;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AnswerOption({
    required this.answer,
    required this.index,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withOpacity(0.3),
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: isSelected
                ? theme.colorScheme.primary.withOpacity(0.1)
                : null,
          ),
          child: Row(
            children: [
              Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.4),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  answer,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
