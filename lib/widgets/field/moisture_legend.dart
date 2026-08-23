import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// Legend for the field map.
class MoistureLegend extends StatelessWidget {
  final bool isHorizontal;

  const MoistureLegend({
    super.key,
    this.isHorizontal = true,
  });

  @override
  Widget build(BuildContext context) {
    final entries = [
      _LegendEntry(color: AppColors.criticalRed, label: 'Dry'),
      _LegendEntry(color: AppColors.warningAmber, label: 'Moderate'),
      _LegendEntry(color: AppColors.accentGreen, label: 'Healthy'),
      _LegendEntry(color: AppColors.waterBlue, label: 'Wet'),
    ];

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: entries
            .expand((entry) => [entry, const SizedBox(width: AppSpacing.md)])
            .toList()
          ..removeLast(),
      );
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: entries
            .expand((entry) => [entry, const SizedBox(height: AppSpacing.sm)])
            .toList()
          ..removeLast(),
      );
    }
  }
}

class _LegendEntry extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendEntry({
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
