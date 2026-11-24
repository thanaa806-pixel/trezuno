import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/constants/app_constants.dart';

/// A reusable button widget for Trezuno.
class AppButton extends StatelessWidget {
  final String title;
  final VoidCallback? onPressed;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool? isEnabled;
  final double? height;
  final double? width;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final bool? expand;

  const AppButton({
    required this.title,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor,
    this.foregroundColor,
    this.isEnabled,
    this.height,
    this.width,
    this.borderRadius,
    this.padding,
    this.expand,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabledVal = isEnabled ?? true;

    final effectiveBackgroundColor = backgroundColor ??
        (isEnabledVal ? colorScheme.primary : colorScheme.onSurface.withValues(alpha: 0.38));

    final effectiveForegroundColor = foregroundColor ??
        (isEnabledVal ? colorScheme.onPrimary : colorScheme.primary);

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(AppConstants.cornerRadius);

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        SlideEffect(
          begin: Offset(0, 0.2),
          duration: Duration(milliseconds: 200),
        ),
      ],
      child: ElevatedButton(
        onPressed: isEnabledVal && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: effectiveBackgroundColor,
          foregroundColor: effectiveForegroundColor,
          elevation: 0,
          minimumSize: Size(double.infinity, height ?? 52),
          shape: RoundedRectangleBorder(
            borderRadius: effectiveBorderRadius,
          ),
          padding: padding ??
              const EdgeInsets.symmetric(
                horizontal: AppConstants.paddingHorizontal,
                vertical: AppConstants.paddingVertical,
              ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}
