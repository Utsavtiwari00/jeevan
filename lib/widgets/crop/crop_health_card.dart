import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/widgets/status/status_badge.dart';

/// A summary card for crop health display.
class CropHealthCard extends StatelessWidget {
  final String diagnosis;
  final String confidence;
  final StatusBadgeSeverity severity;
  final List<String> indicators;
  final VoidCallback onViewAnalysis;

  const CropHealthCard({
    super.key,
    required this.diagnosis,
    required this.confidence,
    required this.severity,
    required this.indicators,
    required this.onViewAnalysis,
  });

  @override
  Widget build(BuildContext context) {
    String severityLabel;
    switch (severity) {
      case StatusBadgeSeverity.critical:
        severityLabel = 'Critical';
        break;
      case StatusBadgeSeverity.warning:
        severityLabel = 'Warning';
        break;
      case StatusBadgeSeverity.info:
        severityLabel = 'Info';
        break;
      case StatusBadgeSeverity.success:
        severityLabel = 'Healthy';
        break;
      case StatusBadgeSeverity.neutral:
        severityLabel = 'Neutral';
        break;
    }

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  diagnosis,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.charcoalSoil,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              StatusBadge(
                label: severityLabel,
                severity: severity,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Confidence: $confidence',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Key Indicators:',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.charcoalSoil,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          ...indicators.take(3).map((indicator) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Icon(Icons.circle, size: 6, color: AppColors.textTertiary),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        indicator,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),
          InkWell(
            onTap: onViewAnalysis,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View analysis',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.chevron_right, size: 20, color: AppColors.accentGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
