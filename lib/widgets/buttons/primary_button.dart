import 'package:flutter/material.dart';

/// Primary action button with loading state.
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(text),
                  ],
                )
              : Text(text),
    );

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Secondary/outlined button with loading state.
class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isExpanded;
  final IconData? icon;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isExpanded = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : icon != null
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 20),
                    const SizedBox(width: 8),
                    Text(text),
                  ],
                )
              : Text(text),
    );

    return isExpanded
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}

/// Sort/filter toggle button bar.
class SortButtonBar extends StatelessWidget {
  final List<String> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const SortButtonBar({
    super.key,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: options.asMap().entries.map((entry) {
          final index = entry.key;
          final label = entry.value;
          final isSelected = index == selectedIndex;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton(
              onPressed: () => onChanged(index),
              style: TextButton.styleFrom(
                backgroundColor: isSelected
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : null,
                foregroundColor: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurface.withOpacity(0.7),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : Colors.transparent,
                  ),
                ),
              ),
              child: Text(label),
            ),
          );
        }).toList(),
      ),
    );
  }
}
