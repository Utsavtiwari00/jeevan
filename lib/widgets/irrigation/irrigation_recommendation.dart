import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/metrics/metric_row.dart';

/// Irrigation recommendation display block.
class IrrigationRecommendation extends StatelessWidget {
  final String currentMoisture;
  final String preferredRange;
  final String rainOutlook;
  final String waterAvailability;
  final String estimatedDuration;
  final VoidCallback onIrrigate;

  const IrrigationRecommendation({
    super.key,
    required this.currentMoisture,
    required this.preferredRange,
    required this.rainOutlook,
    required this.waterAvailability,
    required this.estimatedDuration,
    required this.onIrrigate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Irrigation Recommended',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.charcoalSoil,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Current moisture is below the preferred range. No rain is expected in the near term.',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          MetricRow(
            label: 'Current Moisture',
            value: currentMoisture,
            icon: Icons.water_drop_outlined,
            valueColor: AppColors.warningAmber,
          ),
          MetricRow(
            label: 'Preferred Range',
            value: preferredRange,
            icon: Icons.tune,
          ),
          MetricRow(
            label: 'Rain Outlook',
            value: rainOutlook,
            icon: Icons.cloud_outlined,
          ),
          MetricRow(
            label: 'Water Availability',
            value: waterAvailability,
            icon: Icons.waves,
          ),
          MetricRow(
            label: 'Est. Duration',
            value: estimatedDuration,
            icon: Icons.timer_outlined,
            showDivider: false,
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Irrigate Zone',
            icon: Icons.water_drop,
            onPressed: onIrrigate,
          ),
        ],
      ),
    );
  }
}
