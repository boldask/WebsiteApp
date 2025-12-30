import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Utility functions for common operations.
class Helpers {
  /// Show a snackbar message.
  static void showSnackBar(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.primary,
        duration: duration,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a confirmation dialog.
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDangerous = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: isDangerous
                ? ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                  )
                : null,
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Format a date for display.
  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    return DateFormat(format).format(date);
  }

  /// Format a date as relative time (e.g., "2 hours ago").
  static String formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      // Future date
      final futureDiff = date.difference(now);
      if (futureDiff.inDays == 0) {
        if (futureDiff.inHours == 0) {
          return 'in ${futureDiff.inMinutes} min';
        }
        return 'in ${futureDiff.inHours} hr';
      } else if (futureDiff.inDays == 1) {
        return 'Tomorrow';
      } else if (futureDiff.inDays < 7) {
        return 'in ${futureDiff.inDays} days';
      }
      return DateFormat.MMMd().format(date);
    }

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Just now';
        }
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    }
    return DateFormat.MMMd().format(date);
  }

  /// Format a number with abbreviation (e.g., 1.2K, 3.4M).
  static String formatNumber(int number) {
    if (number < 1000) return number.toString();
    if (number < 1000000) return '${(number / 1000).toStringAsFixed(1)}K';
    if (number < 1000000000) return '${(number / 1000000).toStringAsFixed(1)}M';
    return '${(number / 1000000000).toStringAsFixed(1)}B';
  }

  /// Truncate text with ellipsis.
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }

  /// Capitalize first letter of string.
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Get initials from a name.
  static String getInitials(String name, {int maxInitials = 2}) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    return parts
        .take(maxInitials)
        .map((p) => p.isNotEmpty ? p[0].toUpperCase() : '')
        .join();
  }

  /// Check if running on web.
  static bool get isWeb {
    return identical(0, 0.0);
  }
}
