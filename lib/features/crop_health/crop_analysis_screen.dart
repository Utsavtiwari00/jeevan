import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/domain/models/crop_scan.dart';
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
    final scanAsync = ref.watch(latestCropScanProvider(zoneId));

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(
        title: 'Crop Analysis',
        showBackButton: true,
      ),
      body: scanAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: CropHealthSkeleton(),
        ),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(latestCropScanProvider(zoneId)),
        ),
        data: (scan) {
          if (scan == null) {
            return const EmptyState(
              icon: Icons.local_florist_outlined,
              title: 'No Analysis Found',
              message: 'Rover has not scanned this zone yet.',
              actionLabel: 'Scan Again',
              onAction: null,
            );
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageSection(),
                const SizedBox(height: AppSpacing.lg),
                _buildResultPanel(scan),
                const SizedBox(height: AppSpacing.lg),
                _buildIndicatorsList(scan),
                const SizedBox(height: AppSpacing.lg),
                _buildRecommendedAction(context),
                const SizedBox(height: AppSpacing.xl),
                _buildMetadata(scan),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildImageSection() {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.skeletonBase,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.divider),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(Icons.local_florist, size: 64, color: AppColors.textTertiary),
            // Subtly overlaid detection region
            Positioned(
              top: 30,
              left: 40,
              right: 60,
              bottom: 20,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.warningAmber, width: 2, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  color: AppColors.warningAmber.withValues(alpha: 0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultPanel(CropScan scan) {
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
                  scan.diagnosis, // Mock data is already hedged e.g., "Possible Early Blight"
                  style: AppTypography.headlineMedium.copyWith(color: AppColors.charcoalSoil),
                ),
              ),
              StatusBadge(
                label: '${scan.confidencePercent.toStringAsFixed(0)}% confidence',
                severity: _getSeverity(scan.severity),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Observed in ${scan.observedInPercent.toStringAsFixed(0)}% of scanned area',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Note: Analysis is an estimate based on visual patterns from the rover camera. Verify with physical inspection.',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorsList(CropScan scan) {
    if (scan.indicators.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Observed Indicators'),
        const SizedBox(height: AppSpacing.sm),
        ...scan.indicators.map((indicator) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded, size: 20, color: AppColors.warningAmber),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(indicator, style: AppTypography.bodyLarge),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildRecommendedAction(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Recommended Action'),
        const SizedBox(height: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.divider),
          ),
          child: Text(
            'Monitor affected area closely. Consider applying appropriate treatment if symptoms spread. Schedule a follow-up scan in 3-5 days to track progression.',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.charcoalSoil),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const PrimaryButton(
          label: 'Scan Again',
          icon: Icons.radar,
          onPressed: null, // Rover scan trigger kept null for now
        ),
      ],
    );
  }

  Widget _buildMetadata(CropScan scan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          'Zone: ${scan.zoneId} | ${DateFormat('MMM d, yyyy - h:mm a').format(scan.timestamp)}',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Scan ID: ${scan.id}',
          style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  StatusBadgeSeverity _getSeverity(CropSeverity severity) {
    switch (severity) {
      case CropSeverity.high:
        return StatusBadgeSeverity.critical;
      case CropSeverity.moderate:
        return StatusBadgeSeverity.warning;
      case CropSeverity.low:
        return StatusBadgeSeverity.success;
    }
  }
}
