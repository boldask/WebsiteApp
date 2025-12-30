import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/polls_provider.dart';
import '../../widgets/cards/poll_card.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/empty_state.dart';
import '../../config/constants.dart';

/// Polls tab with sorting and filtering options.
class PollsTab extends StatefulWidget {
  const PollsTab({super.key});

  @override
  State<PollsTab> createState() => _PollsTabState();
}

class _PollsTabState extends State<PollsTab>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPolls();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadPolls() {
    final provider = context.read<PollsProvider>();
    if (provider.polls.isEmpty) {
      provider.loadPolls();
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final provider = context.read<PollsProvider>();
      if (!provider.isLoading && provider.hasMore) {
        provider.loadPolls();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Consumer<PollsProvider>(
      builder: (context, pollsProvider, _) {
        return Column(
          children: [
            // Sort and Filter Bar
            _buildFilterBar(context, pollsProvider),

            // Category Filter
            _buildCategoryFilter(context, pollsProvider),

            // Polls List
            Expanded(
              child: _buildPollsList(context, pollsProvider),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterBar(BuildContext context, PollsProvider provider) {
    final sortOptions = SortOption.values.map((e) => e.label).toList();
    final selectedIndex = SortOption.values.indexOf(provider.sortOption);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: SortButtonBar(
        options: sortOptions,
        selectedIndex: selectedIndex,
        onChanged: (index) {
          provider.setSortOption(SortOption.values[index]);
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, PollsProvider provider) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          _buildCategoryChip(
            context,
            'All',
            provider.categoryFilter == null,
            () => provider.setCategoryFilter(null),
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            'Personal',
            provider.categoryFilter == true,
            () => provider.setCategoryFilter(true),
          ),
          const SizedBox(width: 8),
          _buildCategoryChip(
            context,
            'Social',
            provider.categoryFilter == false,
            () => provider.setCategoryFilter(false),
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

  Widget _buildCategoryChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      selectedColor: theme.colorScheme.primary.withOpacity(0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildPollsList(BuildContext context, PollsProvider provider) {
    if (provider.isLoading && provider.polls.isEmpty) {
      return const LoadingIndicator(message: 'Loading polls...');
    }

    if (provider.error != null && provider.polls.isEmpty) {
      return EmptyState(
        icon: Icons.error_outline,
        title: 'Unable to load polls',
        message: provider.error,
        actionLabel: 'Try Again',
        onAction: () => provider.loadPolls(refresh: true),
      );
    }

    if (provider.polls.isEmpty) {
      return EmptyState(
        icon: Icons.poll_outlined,
        title: 'No polls yet',
        message: 'Be the first to create a poll and start the conversation!',
        actionLabel: 'Create Poll',
        onAction: () {
          // Navigate to create poll
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadPolls(refresh: true),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: provider.polls.length + (provider.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= provider.polls.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: LoadingIndicator(),
            );
          }

          final poll = provider.polls[index];
          return PollCard(poll: poll);
        },
      ),
    );
  }
}
