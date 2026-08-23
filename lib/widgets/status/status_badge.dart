import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

enum StatusBadgeSeverity {
  critical,
  warning,
  info,
  success,
  neutral,
}

/// A compact badge that shows status with BOTH color AND text label.
class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeSeverity severity;
  final VoidCallback? onTap;

  const StatusBadge({
    super.key,
    required this.label,
    required this.severity,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (severity) {
      case StatusBadgeSeverity.critical:
        backgroundColor = AppColors.criticalRedLight;
        textColor = AppColors.criticalRed;
        break;
      case StatusBadgeSeverity.warning:
        backgroundColor = AppColors.warningAmberLight;
        textColor = AppColors.warningAmber;
        break;
      case StatusBadgeSeverity.info:
        backgroundColor = AppColors.waterBlueLight;
        textColor = AppColors.waterBlue;
        break;
      case StatusBadgeSeverity.success:
        backgroundColor = AppColors.accentGreenLight;
        textColor = AppColors.accentGreen;
        break;
      case StatusBadgeSeverity.neutral:
        backgroundColor = AppColors.paperBackground;
        textColor = AppColors.textSecondary;
        break;
    }

    Widget badge = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: severity == StatusBadgeSeverity.neutral
            ? Border.all(color: AppColors.divider)
            : null,
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: Container(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          alignment: Alignment.center,
          child: badge,
        ),
      );
    }

    return badge;
  }
}
