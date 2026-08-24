import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/widgets/status/status_badge.dart';

/// A horizontal alert banner for the Home screen alerts section.
class AlertBanner extends StatelessWidget {
  final String title;
  final String subtitle;
  final StatusBadgeSeverity severity;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? icon;

  const AlertBanner({
    super.key,
    required this.title,
    required this.subtitle,
    required this.severity,
    this.actionLabel,
    this.onAction,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color indicatorColor;
    Color backgroundColor;
    String severityLabel;

    switch (severity) {
      case StatusBadgeSeverity.critical:
        indicatorColor = AppColors.criticalRed;
        backgroundColor = AppColors.criticalRedLight.withValues(alpha: 0.5);
        severityLabel = 'Critical';
        break;
      case StatusBadgeSeverity.warning:
        indicatorColor = AppColors.warningAmber;
        backgroundColor = AppColors.warningAmberLight.withValues(alpha: 0.5);
        severityLabel = 'Warning';
        break;
      case StatusBadgeSeverity.info:
        indicatorColor = AppColors.waterBlue;
        backgroundColor = AppColors.waterBlueLight.withValues(alpha: 0.5);
        severityLabel = 'Info';
        break;
      case StatusBadgeSeverity.success:
        indicatorColor = AppColors.accentGreen;
        backgroundColor = AppColors.accentGreenLight.withValues(alpha: 0.5);
        severityLabel = 'Success';
        break;
      case StatusBadgeSeverity.neutral:
        indicatorColor = AppColors.divider;
        backgroundColor = AppColors.surfaceWhite;
        severityLabel = 'Notice';
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: indicatorColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20, color: indicatorColor),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.charcoalSoil,
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
                      subtitle,
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (actionLabel != null && onAction != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      InkWell(
                        onTap: onAction,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                actionLabel!,
                                style: AppTypography.bodyMedium.copyWith(
                                  color: indicatorColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Icon(Icons.chevron_right, size: 16, color: indicatorColor),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
