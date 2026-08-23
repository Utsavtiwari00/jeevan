import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// A horizontal row displaying a metric label and value.
class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String? unit;
  final IconData? icon;
  final Color? valueColor;
  final bool showDivider;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.icon,
    this.valueColor,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.sm),
                  ],
                  Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: valueColor ?? AppColors.charcoalSoil,
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      unit!,
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: AppColors.divider),
      ],
    );
  }
}
