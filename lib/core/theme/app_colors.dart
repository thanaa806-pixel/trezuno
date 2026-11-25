import 'package:flutter/material.dart';

/// App colors following the world-class Trezuno premium palette.
class AppColors {
  /// Primary: Deep professional slate blue #2C5270
  static const Color primary = Color(0xFF2C5270);

  /// Primary Variant / Gradient start
  static const Color primaryVariant = Color(0xFF3B6E96);

  /// Secondary: Elegant muted blue #6E91AE
  static const Color secondary = Color(0xFF6E91AE);

  /// Accent: Warm sophisticated gold #E9B86E
  static const Color accent = Color(0xFFE9B86E);

  /// Background Light: Pristine clean off-white #F8FAFC
  static const Color backgroundLight = Color(0xFFF8FAFC);

  /// Surface Light: Pure white #FFFFFF
  static const Color surfaceLight = Color(0xFFFFFFFF);

  /// Background Dark: Deep immersive navy #0D131A
  static const Color backgroundDark = Color(0xFF0D131A);

  /// Surface Dark: Rich surface card #151F2B
  static const Color surfaceDark = Color(0xFF151F2B);

  /// Primary Text Light: #121D29
  static const Color primaryText = Color(0xFF121D29);

  /// Secondary Text Light: #718096
  static const Color secondaryText = Color(0xFF718096);

  /// Success: #10B981 (Emerald)
  static const Color success = Color(0xFF10B981);

  /// Warning: #F59E0B (Amber)
  static const Color warning = Color(0xFFF59E0B);

  /// Danger: #EF4444 (Rose)
  static const Color danger = Color(0xFFEF4444);

  /// Border color for light theme
  static const Color borderLight = Color(0xFFE2E8F0);

  /// Border color for dark theme
  static const Color borderDark = Color(0xFF223042);

  /// Divider color
  static const Color divider = Color(0xFFCBD5E1);

  /// Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF2C5270), Color(0xFF3B6E96)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFE9B86E), Color(0xFFF59E0B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
