import 'package:flutter/material.dart';
import '../../config/constants.dart';

/// Reusable tag selector widget using choice chips.
class TagSelector extends StatelessWidget {
  final List<String> availableTags;
  final List<String> selectedTags;
  final ValueChanged<List<String>> onChanged;
  final int? maxSelections;
  final bool wrap;

  const TagSelector({
    super.key,
    required this.availableTags,
    required this.selectedTags,
    required this.onChanged,
    this.maxSelections,
    this.wrap = true,
  });

  /// Create a tag selector for Personal Growth tags.
  factory TagSelector.personalGrowth({
    required List<String> selectedTags,
    required ValueChanged<List<String>> onChanged,
    int? maxSelections,
  }) {
    return TagSelector(
      availableTags: TagCategories.personalGrowth,
      selectedTags: selectedTags,
      onChanged: onChanged,
      maxSelections: maxSelections,
    );
  }

  /// Create a tag selector for Social & Political tags.
  factory TagSelector.socialPolitical({
    required List<String> selectedTags,
    required ValueChanged<List<String>> onChanged,
    int? maxSelections,
  }) {
    return TagSelector(
      availableTags: TagCategories.socialPolitical,
      selectedTags: selectedTags,
      onChanged: onChanged,
      maxSelections: maxSelections,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chips = availableTags.map((tag) {
      final isSelected = selectedTags.contains(tag);
      return FilterChip(
        label: Text(tag),
        selected: isSelected,
        onSelected: (selected) => _onTagSelected(tag, selected),
      );
    }).toList();

    if (wrap) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: chips.map((chip) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: chip,
          );
        }).toList(),
      ),
    );
  }

  void _onTagSelected(String tag, bool selected) {
    final newSelection = List<String>.from(selectedTags);

    if (selected) {
      if (maxSelections != null && newSelection.length >= maxSelections!) {
        return;
      }
      newSelection.add(tag);
    } else {
      newSelection.remove(tag);
    }

    onChanged(newSelection);
  }
}

/// Category selector for Personal Growth vs Social & Political.
class CategorySelector extends StatelessWidget {
  final bool? selectedCategory; // true = Personal, false = Social, null = both
  final ValueChanged<bool?> onChanged;

  const CategorySelector({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ChoiceChip(
          label: const Text('All'),
          selected: selectedCategory == null,
          onSelected: (_) => onChanged(null),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Personal Growth'),
          selected: selectedCategory == true,
          onSelected: (_) => onChanged(true),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Social & Political'),
          selected: selectedCategory == false,
          onSelected: (_) => onChanged(false),
        ),
      ],
    );
  }
}
