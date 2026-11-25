import 'package:flutter/material.dart';
import 'package:trezuno/core/router/app_router.dart';
import 'package:trezuno/core/theme/app_theme.dart';

/// The root widget of the Trezuno application.
/// Manages the overall app configuration including theming, localization,
/// and navigation setup.
class Trezuno extends StatelessWidget {
  const Trezuno({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Trezuno',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
