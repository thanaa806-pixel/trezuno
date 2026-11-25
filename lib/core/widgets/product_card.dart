import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';
import 'status_badge.dart';

/// A world-class card widget displaying product information.
class ProductCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final bool showStatus;
  final String? statusLabel;
  final Color? statusColor;

  const ProductCard({
    required this.title,
    required this.subtitle,
    this.leading,
    this.onTap,
    this.onDelete,
    this.showStatus = false,
    this.statusLabel,
    this.statusColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 250)),
        SlideEffect(
          begin: Offset(0, 0.05),
          duration: Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
        ),
      ],
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (leading != null) ...[
                    leading!,
                    const SizedBox(width: 16),
                  ] else ...[
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 26,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: AppTypography.titleMedium.copyWith(
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: AppTypography.bodySmall.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (showStatus && statusLabel != null && statusColor != null) ...[
                    const SizedBox(width: 12),
                    StatusBadge(
                      label: statusLabel!,
                      color: statusColor!,
                      showBorder: true,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
