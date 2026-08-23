import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'skeleton_loader.dart';

/// A card-shaped skeleton with configurable inner layout.
class SkeletonCard extends StatelessWidget {
  final double? height;
  final int lineCount;
  final bool hasCircle;

  const SkeletonCard({
    super.key,
    this.height,
    this.lineCount = 2,
    this.hasCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasCircle) ...[
            const SkeletonCircle(size: 48),
            const SizedBox(width: AppSpacing.md),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: List.generate(lineCount, (index) {
                final isLast = index == lineCount - 1;
                return Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.sm),
                  child: SkeletonLine(
                    width: isLast ? 100 : double.infinity,
                    height: index == 0 ? 18 : 14,
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
