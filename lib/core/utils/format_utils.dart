import 'package:intl/intl.dart';

/// Utility functions for formatting values.
class FormatUtils {
  /// Format a number with comma separators.
  static String formatNumber(int number) {
    final formatter = NumberFormat('#,##0');
    return formatter.format(number);
  }

  /// Format remaining days nicely.
  static String formatRemainingDays(int days) {
    if (days <= 0) {
      return 'Expired';
    } else if (days < 7) {
      return 'Expires in $days days';
    } else if (days < 30) {
      final weeks = (days / 7).floor();
      return 'Expires in $weeks weeks';
    } else {
      final months = (days / 30).floor();
      return 'Expires in $months months';
    }
  }

  /// Format warranty duration from months.
  static String formatWarrantyDuration(int months) {
    if (months <= 0) return 'Lifetime';
    if (months == 1) return '1 month';
    return '$months months';
  }

  /// Format warranty duration from years.
  static String formatWarrantyDurationYears(int years) {
    if (years == 1) return '1 year';
    return '$years years';
  }

  /// Format a currency amount.
  static String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      symbol: r'$',
      locale: 'en_US',
    );
    return formatter.format(amount);
  }
}
