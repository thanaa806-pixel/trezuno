import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/constants/app_constants.dart';
import 'package:trezuno/core/theme/app_colors.dart';

/// A professional, high-polish button widget for Trezuno.
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
  final Widget? icon;
  final bool isOutlined;

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
    this.icon,
    this.isOutlined = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isEnabledVal = isEnabled ?? true;

    final effectiveBorderRadius = borderRadius ?? BorderRadius.circular(14);

    if (isOutlined) {
      return Animate(
        effects: const [
          FadeEffect(duration: Duration(milliseconds: 200)),
          SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 200)),
        ],
        child: OutlinedButton(
          onPressed: isEnabledVal && !isLoading ? onPressed : null,
          style: OutlinedButton.styleFrom(
            foregroundColor: foregroundColor ?? colorScheme.primary,
            minimumSize: Size(width ?? double.infinity, height ?? 52),
            side: BorderSide(color: colorScheme.primary.withValues(alpha: 0.5), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: effectiveBorderRadius,
            ),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      );
    }

    final effectiveBackgroundColor = backgroundColor ??
        (isEnabledVal ? AppColors.primary : colorScheme.onSurface.withValues(alpha: 0.12));

    final effectiveForegroundColor = foregroundColor ?? Colors.white;

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        SlideEffect(begin: Offset(0, 0.1), duration: Duration(milliseconds: 200)),
      ],
      child: Container(
        decoration: BoxDecoration(
          boxShadow: isEnabledVal && backgroundColor == null && !isLoading
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
          borderRadius: effectiveBorderRadius,
        ),
        child: ElevatedButton(
          onPressed: isEnabledVal && !isLoading ? onPressed : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveBackgroundColor,
            foregroundColor: effectiveForegroundColor,
            elevation: 0,
            minimumSize: Size(width ?? double.infinity, height ?? 52),
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
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      icon!,
                      const SizedBox(width: 8),
                    ],
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Cairo',
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
