import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// A section header with title and optional trailing action.
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.charcoalSoil,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            InkWell(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs,
                  horizontal: AppSpacing.sm,
                ),
                child: Text(
                  actionLabel!,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
