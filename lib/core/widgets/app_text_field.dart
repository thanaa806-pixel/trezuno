import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/constants/app_constants.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// A reusable text field widget for Trezuno.
class AppTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final String? initialValue;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final bool obscureText;
  final bool enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? maxLength;
  final VoidCallback? onTap;
  final Color? fillColor;
  final BorderRadius? borderRadius;

  const AppTextField({
    required this.label,
    this.hintText,
    this.initialValue,
    this.controller,
    this.keyboardType,
    this.onChanged,
    this.validator,
    this.obscureText = false,
    this.enabled = true,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.maxLength,
    this.onTap,
    this.fillColor,
    this.borderRadius,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final effectiveFillColor = fillColor ?? Colors.transparent;
    final effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(AppConstants.cornerRadius);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppConstants.betweenSpacing),
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        Animate(
          effects: const [
            FadeEffect(duration: Duration(milliseconds: 200)),
            SlideEffect(
              begin: Offset(0, 0.1),
              duration: Duration(milliseconds: 200),
            ),
          ],
          child: TextFormField(
            controller: controller,
            initialValue: initialValue,
            keyboardType: keyboardType,
            obscureText: obscureText,
            enabled: enabled,
            style: AppTypography.bodyMedium,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: AppTypography.bodyMedium.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.5),
              ),
              filled: true,
              fillColor: effectiveFillColor,
              border: OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: BorderSide(
                  color: isDark
                      ? AppColors.borderDark
                      : AppColors.borderLight,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: effectiveBorderRadius,
                borderSide: const BorderSide(color: AppColors.danger),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultSpacing,
                vertical: AppConstants.defaultSpacing,
              ),
            ),
            maxLines: maxLines,
            maxLength: maxLength,
            onChanged: onChanged,
            onTap: onTap,
            validator: validator,
          ),
        ),
      ],
    );
  }
}
