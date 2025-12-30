import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/circles_provider.dart';
import '../../widgets/forms/tag_selector.dart';
import '../../widgets/buttons/primary_button.dart';
import '../../config/constants.dart';

/// Screen for filtering circles by tags.
class FilterCircleScreen extends StatefulWidget {
  const FilterCircleScreen({super.key});

  @override
  State<FilterCircleScreen> createState() => _FilterCircleScreenState();
}

class _FilterCircleScreenState extends State<FilterCircleScreen> {
  List<String> _selectedTags = [];
  bool _showUpcomingOnly = true;
  CircleFormat? _selectedFormat;

  @override
  void initState() {
    super.initState();
    // Initialize with current filter values from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final circlesProvider = context.read<CirclesProvider>();
      setState(() {
        _selectedTags = List.from(circlesProvider.tagFilters);
        _showUpcomingOnly = circlesProvider.showUpcomingOnly;
      });
    });
  }

  void _onTagsChanged(List<String> tags) {
    setState(() {
      _selectedTags = tags;
    });
  }

  void _onFormatChanged(CircleFormat? format) {
    setState(() {
      _selectedFormat = format;
    });
  }

  void _onUpcomingOnlyChanged(bool value) {
    setState(() {
      _showUpcomingOnly = value;
    });
  }

  void _applyFilters() {
    final circlesProvider = context.read<CirclesProvider>();
    circlesProvider.setTagFilters(_selectedTags);
    if (_showUpcomingOnly != circlesProvider.showUpcomingOnly) {
      circlesProvider.toggleUpcomingOnly();
    }
    context.pop();
  }

  void _clearFilters() {
    setState(() {
      _selectedTags = [];
      _showUpcomingOnly = true;
      _selectedFormat = null;
    });
  }

  bool get _hasActiveFilters =>
      _selectedTags.isNotEmpty || !_showUpcomingOnly || _selectedFormat != null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circlesProvider = context.watch<CirclesProvider>();
    final hasCurrentFilters = circlesProvider.tagFilters.isNotEmpty ||
        !circlesProvider.showUpcomingOnly;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Circles'),
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
                // Time Filter Section
                Text(
                  'Time',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Show circles based on their scheduled date',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                _TimeFilterOption(
                  title: 'Upcoming Only',
                  subtitle: 'Show only future circles',
                  icon: Icons.upcoming,
                  isSelected: _showUpcomingOnly,
                  onTap: () => _onUpcomingOnlyChanged(true),
                ),
                const SizedBox(height: 8),
                _TimeFilterOption(
                  title: 'All Circles',
                  subtitle: 'Include past and upcoming circles',
                  icon: Icons.all_inclusive,
                  isSelected: !_showUpcomingOnly,
                  onTap: () => _onUpcomingOnlyChanged(false),
                ),

                const SizedBox(height: 24),

                // Format Filter Section
                Text(
                  'Format',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Filter by how the circle is held',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FormatChip(
                      format: null,
                      label: 'All Formats',
                      isSelected: _selectedFormat == null,
                      onSelected: () => _onFormatChanged(null),
                    ),
                    ...CircleFormat.values.map((format) {
                      return _FormatChip(
                        format: format,
                        label: format.label,
                        isSelected: _selectedFormat == format,
                        onSelected: () => _onFormatChanged(format),
                      );
                    }),
                  ],
                ),

                const SizedBox(height: 24),

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
                  'Select topics you\'re interested in',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 16),

                // Personal Growth Tags
                Text(
                  'Personal Growth',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                TagSelector.personalGrowth(
                  selectedTags: _selectedTags,
                  onChanged: _onTagsChanged,
                ),

                const SizedBox(height: 16),

                // Social & Political Tags
                Text(
                  'Social & Political',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 8),
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
                        if (!_showUpcomingOnly)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.history,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Including past circles',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        if (_selectedFormat != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Row(
                              children: [
                                Icon(
                                  _getFormatIcon(_selectedFormat!),
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedFormat!.label,
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
                text: _hasActiveFilters ? 'Apply Filters' : 'Show All Circles',
                onPressed: _applyFilters,
                icon: Icons.check,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getFormatIcon(CircleFormat format) {
    switch (format) {
      case CircleFormat.online:
        return Icons.videocam_outlined;
      case CircleFormat.inPerson:
        return Icons.place_outlined;
      case CircleFormat.both:
        return Icons.public;
    }
  }
}

/// Widget for time filter option.
class _TimeFilterOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _TimeFilterOption({
    required this.title,
    required this.subtitle,
    required this.icon,
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
              icon,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.6),
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
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget for format filter chip.
class _FormatChip extends StatelessWidget {
  final CircleFormat? format;
  final String label;
  final bool isSelected;
  final VoidCallback onSelected;

  const _FormatChip({
    required this.format,
    required this.label,
    required this.isSelected,
    required this.onSelected,
  });

  IconData? get _icon {
    if (format == null) return Icons.all_inclusive;
    switch (format!) {
      case CircleFormat.online:
        return Icons.videocam_outlined;
      case CircleFormat.inPerson:
        return Icons.place_outlined;
      case CircleFormat.both:
        return Icons.public;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_icon != null) ...[
            Icon(_icon, size: 16),
            const SizedBox(width: 4),
          ],
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onSelected(),
    );
  }
}
