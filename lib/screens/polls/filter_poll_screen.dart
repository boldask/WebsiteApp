import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/polls_provider.dart';
import '../../widgets/forms/tag_selector.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../config/constants.dart';

/// Screen for filtering polls by category and tags.
class FilterPollScreen extends StatefulWidget {
  const FilterPollScreen({super.key});

  @override
  State<FilterPollScreen> createState() => _FilterPollScreenState();
}

class _FilterPollScreenState extends State<FilterPollScreen> {
  bool? _selectedCategory; // null = all, true = personal, false = social
  List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    // Initialize with current filter values from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final pollsProvider = context.read<PollsProvider>();
      setState(() {
        _selectedCategory = pollsProvider.categoryFilter;
        _selectedTags = List.from(pollsProvider.tagFilters);
      });
    });
  }

  void _onCategoryChanged(bool? category) {
    setState(() {
      _selectedCategory = category;
      // Clear tags when category changes since tags are category-specific
      _selectedTags = [];
    });
  }

  void _onTagsChanged(List<String> tags) {
    setState(() {
      _selectedTags = tags;
    });
  }

  void _applyFilters() {
    final pollsProvider = context.read<PollsProvider>();
    pollsProvider.setCategoryFilter(_selectedCategory);
    pollsProvider.setTagFilters(_selectedTags);
    context.pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedTags = [];
    });
  }

  bool get _hasActiveFilters =>
      _selectedCategory != null || _selectedTags.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pollsProvider = context.watch<PollsProvider>();
    final hasCurrentFilters = pollsProvider.categoryFilter != null ||
        pollsProvider.tagFilters.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Polls'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_hasActiveFilters || hasCurrentFilters)
            TextButton(
              onPressed: _clearFilters,
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Category Selection
                Text(
                  'Category',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Filter polls by category',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                _CategoryFilterOption(
                  title: 'All Categories',
                  isSelected: _selectedCategory == null,
                  onTap: () => _onCategoryChanged(null),
                ),
                const SizedBox(height: 8),
                _CategoryFilterOption(
                  title: 'Personal Growth',
                  subtitle: 'Health, education, career, relationships...',
                  isSelected: _selectedCategory == true,
                  onTap: () => _onCategoryChanged(true),
                ),
                const SizedBox(height: 8),
                _CategoryFilterOption(
                  title: 'Social & Political',
                  subtitle: 'Politics, environment, equality, rights...',
                  isSelected: _selectedCategory == false,
                  onTap: () => _onCategoryChanged(false),
                ),

                const SizedBox(height: 32),

                // Tags Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tags',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (_selectedTags.isNotEmpty)
                      TextButton(
                        onPressed: () => setState(() => _selectedTags = []),
                        child: Text('Clear (${_selectedTags.length})'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedCategory == null
                      ? 'Select a category to filter by tags'
                      : 'Select tags to filter polls',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),

                if (_selectedCategory == null)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant
                          .withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.filter_list,
                          size: 48,
                          color: theme.colorScheme.onSurface.withOpacity(0.3),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Select a category first',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else if (_selectedCategory == true)
                  TagSelector.personalGrowth(
                    selectedTags: _selectedTags,
                    onChanged: _onTagsChanged,
                  )
                else
                  TagSelector.socialPolitical(
                    selectedTags: _selectedTags,
                    onChanged: _onTagsChanged,
                  ),

                const SizedBox(height: 24),

                // Active filters summary
                if (_hasActiveFilters) ...[
                  Container(
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
                        Text(
                          'Active Filters',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (_selectedCategory != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.category_outlined,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedCategory == true
                                      ? 'Personal Growth'
                                      : 'Social & Political',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        if (_selectedTags.isNotEmpty)
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: _selectedTags.map((tag) {
                              return Chip(
                                label: Text(tag),
                                deleteIcon: const Icon(Icons.close, size: 16),
                                onDeleted: () {
                                  setState(() {
                                    _selectedTags.remove(tag);
                                  });
                                },
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              );
                            }).toList(),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ],
            ),
          ),

          // Apply button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: PrimaryButton(
                text: _hasActiveFilters ? 'Apply Filters' : 'Show All Polls',
                onPressed: _applyFilters,
                icon: Icons.check,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget for category filter option.
class _CategoryFilterOption extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryFilterOption({
    required this.title,
    this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
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
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
