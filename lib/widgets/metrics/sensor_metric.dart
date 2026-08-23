import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// A detailed metric display for individual sensor readings.
class SensorMetric extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final String? statusLabel;
  final Color? statusColor;
  final bool showDivider;

  const SensorMetric({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    this.statusLabel,
    this.statusColor,
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
            children: [
              Icon(icon, size: 24, color: AppColors.textSecondary),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (statusLabel != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        statusLabel!,
                        style: AppTypography.labelSmall.copyWith(
                          color: statusColor ?? AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.charcoalSoil,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Text(
                    unit,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
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
