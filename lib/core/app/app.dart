import 'package:flutter/material.dart';
import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// The root widget of the Trezuno application.
/// Manages the overall app configuration including theming, localization,
/// and navigation setup.
class Trezuno extends StatelessWidget {
  const Trezuno({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trezuno',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }

  /// Builds the light theme with the Trezuno premium color palette.
  ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Color(0xFF315C81),
        onPrimary: Colors.white,
        secondary: Color(0xFF6E91AE),
        onSecondary: Color(0xFF182635),
        error: Color(0xFFD96B6B),
        onError: Colors.white,
      ),
      textTheme: _buildLightTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight + 8,
      ),
    );
  }

  /// Builds the light text theme using Cairo for Arabic and Inter for English.
  TextTheme _buildLightTextTheme() {
    return AppTypography.lightTextTheme;
  }

  /// Builds the dark theme with the Trezuno premium color palette.
  ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF1B2734),
        primary: Color(0xFF315C81),
        onPrimary: Color(0xFFE9B86E),
        secondary: Color(0xFF8291A0),
        onSecondary: Color(0xFF182635),
        error: Color(0xFFD96B6B),
        onError: Color(0xFFFFFFFF),
      ),
      textTheme: _buildDarkTextTheme(),
      scaffoldBackgroundColor: const Color(0xFF111923),
      cardTheme: const CardThemeData(
        elevation: 2,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
        toolbarHeight: kToolbarHeight + 8,
        backgroundColor: Color(0xFF1B2734),
        foregroundColor: Colors.white,
      ),
    );
  }

  /// Builds the dark text theme using Cairo for Arabic and Inter for English.
  TextTheme _buildDarkTextTheme() {
    return AppTypography.darkTextTheme;
  }
}
