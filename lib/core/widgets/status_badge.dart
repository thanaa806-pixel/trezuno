import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/constants/app_constants.dart';
import 'package:trezuno/core/theme/app_typography.dart';

/// A status badge widget showing warranty status.
class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final bool showBorder;

  const StatusBadge({
    required this.label,
    required this.color,
    this.showBorder = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        SlideEffect(
          begin: Offset(0, 0.1),
          duration: Duration(milliseconds: 200),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.betweenSpacing,
          vertical: AppConstants.betweenSpacing,
        ),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(AppConstants.smallCornerRadius),
          border: showBorder
              ? Border.all(color: color.withValues(alpha: 0.3))
              : null,
        ),
        child: Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
