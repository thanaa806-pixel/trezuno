import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:trezuno/core/constants/app_constants.dart';
import 'package:trezuno/core/theme/app_colors.dart';
import 'package:trezuno/core/theme/app_typography.dart';
import 'status_badge.dart';

/// A card widget displaying product information.
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

    return Animate(
      effects: const [
        FadeEffect(duration: Duration(milliseconds: 200)),
        SlideEffect(
          begin: Offset(0, 0.1),
          duration: Duration(milliseconds: 200),
        ),
      ],
      child: Card(
        margin: const EdgeInsets.only(bottom: AppConstants.defaultSpacing),
        elevation: AppConstants.cardElevation,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.cornerRadius),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.defaultSpacing),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (leading != null) ...[
                      leading!,
                      const SizedBox(width: AppConstants.betweenSpacing),
                    ] else ...[
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(
                              AppConstants.smallCornerRadius),
                        ),
                        child: const Icon(
                          Icons.inventory,
                          size: 24,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ],
                    if (showStatus && statusLabel != null && statusColor != null) ...[
                      const Spacer(),
                      StatusBadge(
                        label: statusLabel!,
                        color: statusColor!,
                        showBorder: true,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: AppConstants.betweenSpacing),
                Text(
                  title,
                  style: AppTypography.titleMedium.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
