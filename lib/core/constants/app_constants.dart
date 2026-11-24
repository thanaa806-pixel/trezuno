import 'package:flutter/material.dart';

/// Application constants for Trezuno.

/// App identity
class AppConstants {
  static const String appName = 'Trezuno';
  static const String tagline = 'Never Lose Track of Your Warranties.';
  static const String bundleIdentifier = 'com.trezuno.app';
  static const String playStoreIdentifier = 'com.trezuno.app';

  /// Version
  static const String version = '1.0.0';
  static const int buildNumber = 1;

  /// Database
  static const int maxRecentProducts = 10;

  /// Notifications
  static const List<int> defaultReminderDays = [30, 14, 7, 1];

  /// Warranty status
  static const Color activeWarrantyColor = Color(0xFF42A886);
  static const Color expiringSoonColor = Color(0xFFE8A64D);
  static const Color expiredColor = Color(0xFFD96B6B);

  // Backward compatibility aliases
  static const Color ActiveWarrantyColor = activeWarrantyColor;
  static const Color ExpiringSoonColor = expiringSoonColor;
  static const Color ExpiredColor = expiredColor;

  /// UI constants
  static const double cornerRadius = 12.0;
  static const double smallCornerRadius = 8.0;
  static const double paddingHorizontal = 20.0;
  static const double paddingVertical = 16.0;
  static const double defaultSpacing = 16.0;
  static const double betweenSpacing = 8.0;
  static const double cardElevation = 2.0;
  static const double shadowOpacity = 0.05;

  /// Date format constants
  static const String purchaseDateFormat = 'MMM d, yyyy';
  static String warrantyExpirationFormat = 'MMM d, yyyy';
  static String remainingDaysFormat = 'Remaining: %d days';

  /// Category options
  static const List<String> productCategories = [
    'Smartphones',
    'Laptops',
    'Tablets',
    'TVs',
    'Home Appliances',
    'Gaming Devices',
    'Accessories',
    'Other',
  ];
}

/// Supported locales
class AppLocales {
  static const Locale english = Locale('en', 'US');
  static const Locale arabic = Locale('ar', 'SA');

  static List<Locale> get supportedLocales => [english, arabic];
}
