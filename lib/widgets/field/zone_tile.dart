import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// A list tile for zone display.
class ZoneTile extends StatelessWidget {
  final String zoneName;
  final String moisturePercent;
  final String moistureCategory; // e.g. "Low", "High", "Optimal"
  final String status;
  final String cropType;
  final VoidCallback? onTap;

  const ZoneTile({
    super.key,
    required this.zoneName,
    required this.moisturePercent,
    required this.moistureCategory,
    required this.status,
    required this.cropType,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    if (moistureCategory.toLowerCase().contains('low')) {
      indicatorColor = AppColors.warningAmber;
    } else if (moistureCategory.toLowerCase().contains('high')) {
      indicatorColor = AppColors.waterBlue;
    } else {
      indicatorColor = AppColors.accentGreen;
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: indicatorColor, width: 3),
              ),
              alignment: Alignment.center,
              child: Text(
                moisturePercent,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalSoil,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    zoneName,
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.charcoalSoil,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    cropType,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    status,
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
