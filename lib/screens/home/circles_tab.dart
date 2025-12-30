import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/circles_provider.dart';
import '../../widgets/cards/circle_card.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../config/constants.dart';

/// Circles tab with sorting and filtering options.
class CirclesTab extends StatefulWidget {
  const CirclesTab({super.key});

  @override
  State<CirclesTab> createState() => _CirclesTabState();
}

class _CirclesTabState extends State<CirclesTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCircles();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadCircles() {
    final provider = context.read<CirclesProvider>();
    if (provider.circles.isEmpty) {
      provider.loadCircles();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<CirclesProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadCircles();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<CirclesProvider>(
      builder: (context, circlesProvider, _) {
        return Column(
          children: [
            // Sort Bar
            _buildSortBar(context, circlesProvider),

            // Filter Options
            _buildFilterOptions(context, circlesProvider),

            // Circles List
            Expanded(
              child: _buildCirclesList(context, circlesProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSortBar(BuildContext context, CirclesProvider provider) {
    final sortOptions = [
      SortOption.newest.label,
      SortOption.popular.label,
    ];
    final selectedIndex = provider.sortOption == SortOption.newest ? 0 : 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SortButtonBar(
        options: sortOptions,
        selectedIndex: selectedIndex,
        onChanged: (index) {
          provider.setSortOption(
            index == 0 ? SortOption.newest : SortOption.popular,
          );
        },
      ),
    );
  }

  Widget _buildFilterOptions(BuildContext context, CirclesProvider provider) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Upcoming Only Toggle
          FilterChip(
            label: Text(
              provider.showUpcomingOnly ? 'Upcoming Only' : 'All Events',
            ),
            selected: provider.showUpcomingOnly,
            onSelected: (_) => provider.toggleUpcomingOnly(),
            selectedColor: theme.colorScheme.primary.withOpacity(0.2),
            checkmarkColor: theme.colorScheme.primary,
            avatar: Icon(
              provider.showUpcomingOnly
                  ? Icons.event_available
                  : Icons.event_note,
              size: 18,
              color: provider.showUpcomingOnly
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const Spacer(),
          if (provider.tagFilters.isNotEmpty)
            TextButton.icon(
              onPressed: provider.clearFilters,
              icon: const Icon(Icons.clear, size: 16),
              label: const Text('Clear'),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCirclesList(BuildContext context, CirclesProvider provider) {
    if (provider.isLoading && provider.circles.isEmpty) {
      return const LoadingIndicator(message: 'Loading circles...');
    }

    if (provider.error != null && provider.circles.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Unable to load circles',
        message: provider.error,
        actionLabel: 'Try Again',
        onAction: () => provider.loadCircles(refresh: true),
      );
    }

    if (provider.circles.isEmpty) {
      return EmptyState(
        icon: Icons.group_outlined,
        title: 'No circles yet',
        message:
            'Create a circle to bring people together for meaningful discussions.',
        actionLabel: 'Create Circle',
        onAction: () {
          // Navigate to create circle
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadCircles(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: provider.circles.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.circles.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(),
            );
          }

          final circle = provider.circles[index];
          return CircleCard(circle: circle);
        },
      ),
    );
  }
}
