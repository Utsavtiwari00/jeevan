import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';

/// Renders the real-time crop health section backed by Firebase RTDB (`trackbot/scan/`).
class CropHealthScanSection extends ConsumerWidget {
  final Zone zone;
  final bool showViewAnalysisLink;

  const CropHealthScanSection({
    super.key,
    required this.zone,
    this.showViewAnalysisLink = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanAsync = ref.watch(cropScanStreamProvider);
    final controllerState = ref.watch(cropScanControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Crop Health'),
        const SizedBox(height: AppSpacing.sm),
        scanAsync.when(
          loading: () => const CropHealthSkeleton(),
          error: (err, _) => _buildErrorCard(
            context,
            ref,
            errorMessage: err.toString(),
          ),
          data: (scan) {
            // If the controller is currently loading or status is requested/processing
            if (controllerState.isLoading || scan.isProcessing) {
              return _buildProcessingCard(scan);
            }

            if (scan.isError || controllerState.hasError) {
              final errorMsg = scan.rawError ??
                  controllerState.error?.toString() ??
                  'Scan failed. Ensure Trackbot is online.';
              return _buildErrorCard(context, ref, errorMessage: errorMsg);
            }

            if (scan.isCompleted) {
              return _buildCompletedCard(context, ref, scan);
            }

            // Fallback for IDLE or no previous scan
            return _buildIdleCard(context, ref);
          },
        ),
      ],
    );
  }

  /// State: Processing (requested or analyzing)
  Widget _buildProcessingCard(CropScanResult scan) {
    final isRequested = scan.status == CropScanStatus.requested;

    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crop Health Scan',
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              StatusBadge(
                label: isRequested ? 'REQUESTED' : 'ANALYZING',
                severity: StatusBadgeSeverity.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.paperBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Analyzing crop...',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalSoil,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  isRequested
                      ? 'Scan request dispatched to Raspberry Pi Trackbot...'
                      : 'Trackbot capturing camera frame & running TFLite inference...',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const PrimaryButton(
            label: 'Analyzing Crop...',
            icon: Icons.hourglass_top_rounded,
            isLoading: true,
            onPressed: null, // Disabled to prevent duplicate scan requests
          ),
        ],
      ),
    );
  }

  /// State: Error
  Widget _buildErrorCard(
    BuildContext context,
    WidgetRef ref, {
    required String errorMessage,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.criticalRed.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crop Health Scan',
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const StatusBadge(
                label: 'SCAN ERROR',
                severity: StatusBadgeSeverity.critical,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.criticalRedLight,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.criticalRed,
                  size: 22,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan Failed',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.criticalRed,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        errorMessage.isNotEmpty
                            ? errorMessage
                            : 'Ensure the Raspberry Pi Trackbot is connected and online.',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.charcoalSoil),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Scan Crop',
            icon: Icons.refresh_rounded,
            onPressed: () {
              ref.read(cropScanControllerProvider.notifier).resetState();
              ref.read(cropScanControllerProvider.notifier).triggerScan();
            },
          ),
        ],
      ),
    );
  }

  /// State: Idle / No previous scan available
  Widget _buildIdleCard(BuildContext context, WidgetRef ref) {
    return Container(
      width: double.infinity,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Crop Health',
                style: AppTypography.titleMedium
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const StatusBadge(
                label: 'NO SCAN',
                severity: StatusBadgeSeverity.neutral,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.paperBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.eco_outlined,
                  size: 40,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'No crop scan available',
                  style: AppTypography.titleSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalSoil,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Press "Scan Crop" to request Trackbot to capture a frame and run AI health diagnostics.',
                  style: AppTypography.caption
                      .copyWith(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: 'Scan Crop',
            icon: Icons.camera_alt_outlined,
            onPressed: () {
              ref.read(cropScanControllerProvider.notifier).triggerScan();
            },
          ),
        ],
      ),
    );
  }

  /// State: Completed scan with image and crop disease diagnostics
  Widget _buildCompletedCard(
    BuildContext context,
    WidgetRef ref,
    CropScanResult scan,
  ) {
    final hasDisease = scan.hasDisease;
    final confidencePct = scan.confidencePercentage;

    StatusBadgeSeverity badgeSeverity;
    String badgeLabel;

    if (!hasDisease) {
      badgeSeverity = StatusBadgeSeverity.success;
      badgeLabel = 'HEALTHY';
    } else if (confidencePct > 70) {
      badgeSeverity = StatusBadgeSeverity.critical;
      badgeLabel = 'DISEASE ALERT';
    } else {
      badgeSeverity = StatusBadgeSeverity.warning;
      badgeLabel = 'MONITOR';
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
          // Diagnosis Title & Status Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.formattedDisease,
                      style: AppTypography.titleLarge.copyWith(
                        color: AppColors.charcoalSoil,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Crop: ${scan.formattedCrop}',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: badgeLabel,
                severity: badgeSeverity,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Captured Image View (Cloudinary URL)
          if (scan.imageUrl != null && scan.imageUrl!.isNotEmpty) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      scan.imageUrl!,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: AppColors.skeletonBase,
                          child: const Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.accentGreen),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.skeletonBase,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.broken_image_outlined,
                              color: AppColors.textTertiary,
                              size: 36,
                            ),
                            const SizedBox(height: 4),
                            Text('Image unavailable',
                                style: AppTypography.caption),
                          ],
                        ),
                      ),
                    ),
                    // Subtle overlay badge on image
                    Positioned(
                      bottom: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.camera_alt,
                                color: Colors.white70, size: 12),
                            const SizedBox(width: 4),
                            Text(
                              'Trackbot Frame',
                              style: AppTypography.caption.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // Scan Metrics / Details Box
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.paperBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Confidence',
                      style: AppTypography.bodySmall
                          .copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      scan.formattedConfidence,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: hasDisease
                            ? AppColors.criticalRed
                            : AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
                if (scan.formattedInferenceTime != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Inference Time',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        scan.formattedInferenceTime!,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.charcoalSoil,
                        ),
                      ),
                    ],
                  ),
                ],
                if (scan.formattedTimestamp != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Last Scanned',
                        style: AppTypography.bodySmall
                            .copyWith(color: AppColors.textSecondary),
                      ),
                      Text(
                        scan.formattedTimestamp!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Primary Scan Action Button (labeled "Scan Crop")
          PrimaryButton(
            label: 'Scan Crop',
            icon: Icons.camera_alt_outlined,
            onPressed: () {
              ref.read(cropScanControllerProvider.notifier).triggerScan();
            },
          ),

          if (showViewAnalysisLink) ...[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  context.push('/field/zone/${zone.id}/crop-analysis');
                },
                icon: const Icon(Icons.analytics_outlined,
                    size: 16, color: AppColors.accentGreen),
                label: Text(
                  'View full analysis details',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.accentGreen,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
