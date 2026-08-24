import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/application/field/field_provider.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/empty_state.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class CropAnalysisScreen extends ConsumerWidget {
  final String zoneId;

  const CropAnalysisScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAsync = ref.watch(zoneDetailProvider(zoneId));
    final scanAsync = ref.watch(cropScanStreamProvider);
    final controllerState = ref.watch(cropScanControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(
        title: 'Crop Analysis',
        showBackButton: true,
      ),
      body: zoneAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CropHealthSkeleton(),
        ),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(zoneDetailProvider(zoneId)),
        ),
        data: (zone) {
          return scanAsync.when(
            loading: () => const SingleChildScrollView(
              padding: EdgeInsets.all(AppSpacing.md),
              child: CropHealthSkeleton(),
            ),
            error: (err, stack) => ErrorState(
              message: err.toString(),
              onRetry: () => ref.refresh(cropScanStreamProvider),
            ),
            data: (scan) {
              if (controllerState.isLoading || scan.isProcessing) {
                return _buildProcessingView(scan);
              }

              if (scan.isError || controllerState.hasError) {
                return ErrorState(
                  message: scan.rawError ??
                      controllerState.error?.toString() ??
                      'Crop scan failed.',
                  onRetry: () {
                    ref.read(cropScanControllerProvider.notifier).resetState();
                    ref.read(cropScanControllerProvider.notifier).triggerScan();
                  },
                );
              }

              if (scan.isIdle) {
                return EmptyState(
                  icon: Icons.local_florist_outlined,
                  title: 'No Analysis Found',
                  message:
                      'Trackbot has not performed a crop scan yet for this field.',
                  actionLabel: 'Scan Crop',
                  onAction: () {
                    ref.read(cropScanControllerProvider.notifier).triggerScan();
                  },
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildImageSection(scan),
                    const SizedBox(height: AppSpacing.lg),
                    _buildResultPanel(scan, zone),
                    const SizedBox(height: AppSpacing.lg),
                    _buildIndicatorsList(scan),
                    const SizedBox(height: AppSpacing.lg),
                    _buildRecommendedAction(context, ref, scan),
                    const SizedBox(height: AppSpacing.xl),
                    _buildMetadata(zone, scan),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildProcessingView(CropScanResult scan) {
    final isRequested = scan.status == CropScanStatus.requested;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(
                strokeWidth: 3.5,
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Analyzing crop...',
              style: AppTypography.headlineSmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalSoil,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              isRequested
                  ? 'Scan request dispatched to Raspberry Pi Trackbot'
                  : 'Trackbot capturing frame & executing TFLite model...',
              style: AppTypography.bodyMedium
                  .copyWith(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection(CropScanResult scan) {
    if (scan.imageUrl != null && scan.imageUrl!.isNotEmpty) {
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.skeletonBase,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.md),
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
                    child: const Center(
                      child: Icon(Icons.broken_image_outlined,
                          size: 64, color: AppColors.textTertiary),
                    ),
                  ),
                ),
                if (scan.hasDisease)
                  Positioned(
                    top: 24,
                    left: 36,
                    right: 48,
                    bottom: 24,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.warningAmber,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        color: AppColors.warningAmber.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.skeletonBase,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: const Stack(
          alignment: Alignment.center,
          children: [
            Icon(Icons.local_florist, size: 64, color: AppColors.textTertiary),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(CropScanResult scan, Zone zone) {
    final hasDisease = scan.hasDisease;
    final confidencePct = scan.confidencePercentage;

    StatusBadgeSeverity badgeSeverity;
    if (!hasDisease) {
      badgeSeverity = StatusBadgeSeverity.success;
    } else if (confidencePct > 70) {
      badgeSeverity = StatusBadgeSeverity.critical;
    } else {
      badgeSeverity = StatusBadgeSeverity.warning;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.formattedDisease,
                      style: AppTypography.headlineMedium
                          .copyWith(color: AppColors.charcoalSoil),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Crop: ${scan.formattedCrop}',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                label: scan.formattedConfidence,
                severity: badgeSeverity,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Note: Analysis is inferred by Trackbot on-device TensorFlow Lite model. Verify with physical inspection.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsList(CropScanResult scan) {
    final indicators = <String>[];
    if (scan.hasDisease) {
      final diseaseLower = scan.disease?.toLowerCase() ?? '';
      if (diseaseLower.contains('blight')) {
        indicators.addAll([
          'Leaf discoloration and necrotic margins',
          'Brown circular lesions on foliage',
          'Yellow chlorotic halos surrounding lesions',
        ]);
      } else if (diseaseLower.contains('rust')) {
        indicators.addAll([
          'Orange-brown pustules on underside of leaves',
          'Powdery spore development',
          'Premature leaf senescence',
        ]);
      } else if (diseaseLower.contains('spot') ||
          diseaseLower.contains('speck')) {
        indicators.addAll([
          'Small dark sunken spots on leaf surface',
          'Chlorosis on affected areas',
        ]);
      } else {
        indicators.addAll([
          'Visual leaf texture anomalies detected',
          'Color distribution irregularity',
        ]);
      }
    }

    if (indicators.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Observed Indicators'),
        const SizedBox(height: AppSpacing.sm),
        ...indicators.map(
          (indicator) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: AppColors.warningAmber,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(indicator, style: AppTypography.bodyLarge),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedAction(
    BuildContext context,
    WidgetRef ref,
    CropScanResult scan,
  ) {
    String recommendation;
    if (!scan.hasDisease) {
      recommendation =
          'Plant is healthy. Continue routine irrigation and nutrient schedules. Schedule another routine scan in 5-7 days.';
    } else {
      recommendation =
          'Monitor affected area closely. Consider targeted treatment or pruning if symptoms spread. Schedule a follow-up scan in 2-3 days to track progression.';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recommended Action'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            recommendation,
            style: AppTypography.bodyLarge
                .copyWith(color: AppColors.charcoalSoil),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        PrimaryButton(
          label: 'Scan Crop',
          icon: Icons.camera_alt_outlined,
          onPressed: () {
            ref.read(cropScanControllerProvider.notifier).triggerScan();
          },
        ),
      ],
    );
  }

  Widget _buildMetadata(Zone zone, CropScanResult scan) {
    final metadataParts = <String>[
      'Zone: ${zone.name}',
      if (scan.formattedInferenceTime != null)
        'Inference: ${scan.formattedInferenceTime}',
      if (scan.formattedTimestamp != null) 'Time: ${scan.formattedTimestamp}',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          metadataParts.join('  •  '),
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
