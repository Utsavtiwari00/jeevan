import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';

/// Global offline indicator banner.
class OfflineBanner extends StatelessWidget {
  final bool isOffline;
  final DateTime? lastSynced;

  const OfflineBanner({
    super.key,
    required this.isOffline,
    this.lastSynced,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: isOffline
          ? Container(
              key: const ValueKey('offline'),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: AppSpacing.xs,
                horizontal: AppSpacing.md,
              ),
              color: AppColors.warningAmberLight,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_off,
                    size: 16,
                    color: AppColors.warningAmber,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Offline — showing latest synced data',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.warningAmber,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            )
          : const SizedBox.shrink(key: ValueKey('online')),
    );
  }
}
