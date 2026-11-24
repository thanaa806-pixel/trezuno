import 'package:intl/intl.dart';

/// Utility functions for date handling.
class DateUtils {
  /// Format a DateTime to a readable string.
  static String formatDate(DateTime date, {String format = 'MMM d, yyyy'}) {
    final formatter = DateFormat(format);
    return formatter.format(date);
  }

  /// Format a DateTime to a short month day string.
  static String formatShortDate(DateTime date) {
    return '${_getMonthName(date.month)} ${date.day}';
  }

  /// Get month name in English or Arabic based on locale.
  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return 'Unknown';
    }
  }

  /// Parse a date string in MM/dd/yyyy format.
  static DateTime? parseDateString(String? dateString) {
    if (dateString == null) return null;
    try {
      final parsed = DateFormat('MM/dd/yyyy').parse(dateString);
      return parsed;
    } catch (e) {
      return null;
    }
  }

  /// Calculate the difference in days between two dates.
  static int daysBetween(DateTime from, DateTime to) {
    final fromNormalized = DateTime(from.year, from.month, from.day);
    final toNormalized = DateTime(to.year, to.month, to.day);
    return toNormalized.difference(fromNormalized).inDays;
  }

  /// Check if a date is today.
  static bool isToday(DateTime date) {
    final today = DateTime.now();
    return date.year == today.year &&
        date.month == today.month &&
        date.day == today.day;
  }

  /// Check if a date is in the future.
  static bool isInFuture(DateTime date) {
    return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Check if a date is in the past.
  static bool isInPast(DateTime date) {
    return date.isBefore(DateTime.now().subtract(const Duration(days: 1)));
  }

  /// Get a human-readable description of how long ago a date was.
  static String timeAgo(DateTime date) {
    final days = daysBetween(date, DateTime.now());
    if (days < 0) {
      return '${-days} days left';
    } else if (days == 0) {
      return 'Today';
    } else if (days < 7) {
      return '$days days ago';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return '$weeks weeks ago';
    } else if (days < 365) {
      final months = (days / 30).floor();
      return '$months months ago';
    } else {
      final years = (days / 365).floor();
      return '$years years ago';
    }
  }

  /// Get the current DateTime at midnight.
  static DateTime getMidnight() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Get the start of the day for a given date.
  static DateTime startOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Get the end of the day for a given date.
  static DateTime endOfDay(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59);
  }
}