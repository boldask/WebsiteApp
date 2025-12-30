import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/polls_provider.dart';
import '../../providers/circles_provider.dart';
import '../../widgets/cards/poll_card.dart';
import '../../widgets/cards/circle_card.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../models/poll_model.dart';
import '../../models/circle_model.dart';

/// Favorites tab showing saved polls and circles.
class FavoritesTab extends StatefulWidget {
  const FavoritesTab({super.key});

  @override
  State<FavoritesTab> createState() => _FavoritesTabState();
}

class _FavoritesTabState extends State<FavoritesTab>
    with AutomaticKeepAliveClientMixin {
  int _selectedSegment = 0; // 0 = Polls, 1 = Circles

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Segment Control
        Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.onSurface.withOpacity(0.1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildSegmentButton(
                    context,
                    'Saved Polls',
                    Icons.poll_outlined,
                    0,
                  ),
                ),
                Expanded(
                  child: _buildSegmentButton(
                    context,
                    'Saved Circles',
                    Icons.group_outlined,
                    1,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        Expanded(
          child: _selectedSegment == 0
              ? _buildSavedPolls(context)
              : _buildSavedCircles(context),
        ),
      ],
    );
  }

  Widget _buildSegmentButton(
    BuildContext context,
    String label,
    IconData icon,
    int index,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedSegment == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedSegment = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.6),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedPolls(BuildContext context) {
    return Consumer2<UserProvider, PollsProvider>(
      builder: (context, userProvider, pollsProvider, _) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const LoadingIndicator();
        }

        // Get polls that user has participated in (voted on)
        final savedPolls = pollsProvider.polls
            .where((poll) => poll.hasUserVoted(user.uid))
            .toList();

        if (savedPolls.isEmpty) {
          return EmptyState(
            icon: Icons.bookmark_outline,
            title: 'No saved polls',
            message: 'Polls you vote on will appear here for easy access.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => pollsProvider.loadPolls(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: savedPolls.length,
            itemBuilder: (context, index) {
              return PollCard(poll: savedPolls[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildSavedCircles(BuildContext context) {
    return Consumer2<UserProvider, CirclesProvider>(
      builder: (context, userProvider, circlesProvider, _) {
        final user = userProvider.currentUser;

        if (user == null) {
          return const LoadingIndicator();
        }

        // Get circles that user has joined
        final savedCircles = circlesProvider.circles
            .where((circle) => circle.attendeeIds.contains(user.uid))
            .toList();

        if (savedCircles.isEmpty) {
          return EmptyState(
            icon: Icons.bookmark_outline,
            title: 'No saved circles',
            message:
                'Circles you join will appear here so you never miss an event.',
          );
        }

        return RefreshIndicator(
          onRefresh: () => circlesProvider.loadCircles(refresh: true),
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: savedCircles.length,
            itemBuilder: (context, index) {
              return CircleCard(circle: savedCircles[index]);
            },
          ),
        );
      },
    );
  }
}
