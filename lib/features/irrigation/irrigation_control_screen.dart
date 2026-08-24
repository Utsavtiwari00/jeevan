import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/application/irrigation/irrigation_provider.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/buttons/secondary_button.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/sheets/app_bottom_sheet.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/empty_state.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class IrrigationControlScreen extends ConsumerWidget {
  const IrrigationControlScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needingIrrigationAsync = ref.watch(zonesNeedingIrrigationProvider);
    final adequateAsync = ref.watch(adequateZonesProvider);
    final controllerState = ref.watch(irrigationControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(title: 'Irrigation Control'),
      body: needingIrrigationAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: RoverStatusSkeleton(), // Fallback skeleton
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(zonesNeedingIrrigationProvider);
            ref.invalidate(adequateZonesProvider);
          },
        ),
        data: (needingIrrigation) {
          final adequateZones = adequateAsync.valueOrNull ?? [];
          
          if (needingIrrigation.isEmpty && adequateZones.isEmpty) {
            return const EmptyState(
              icon: Icons.grass,
              title: 'No zones found',
              message: 'Check back later.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (needingIrrigation.isNotEmpty) ...[
                  Text(
                    '${needingIrrigation.length} zones need irrigation',
                    style: AppTypography.bodyLarge.copyWith(color: AppColors.warningAmber),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const SectionHeader(title: 'Recommended'),
                  const SizedBox(height: AppSpacing.md),
                  ...needingIrrigation.map((zone) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildZoneCard(zone, true),
                  )),
                  const SizedBox(height: AppSpacing.xl),
                  _buildAggregateEstimate(needingIrrigation),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: 'Start Recommended Irrigation',
                      isLoading: controllerState.isLoading,
                      onPressed: () => _showConfirmationSheet(context, ref, needingIrrigation),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ] else ...[
                  const EmptyState(
                    icon: Icons.water_drop,
                    title: 'All clear',
                    message: 'All zones are adequately watered',
                  ),
                  const SizedBox(height: AppSpacing.xl),
                ],
                if (adequateZones.isNotEmpty) ...[
                  const SectionHeader(title: 'Adequate'),
                  const SizedBox(height: AppSpacing.md),
                  ...adequateZones.map((zone) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _buildZoneCard(zone, false),
                  )),
                  const SizedBox(height: AppSpacing.xl),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildZoneCard(Zone zone, bool needsIrrigation) {
    // Basic mock estimations
    final duration = needsIrrigation ? (zone.id == 'zone-a' ? 14 : 16) : 0;
    final liters = needsIrrigation ? (zone.id == 'zone-a' ? 420 : 480) : 0;
    
    return Opacity(
      opacity: needsIrrigation ? 1.0 : 0.6,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.surfaceWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.divider),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(zone.name, style: AppTypography.headlineSmall),
                Text(
                  '${zone.moistureCategory.label} · ${zone.soilMoisture.toInt()}%',
                  style: AppTypography.bodyMedium.copyWith(
                    color: needsIrrigation ? AppColors.warningAmber : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              needsIrrigation ? 'Est. $duration min · ~$liters L' : 'No irrigation needed',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregateEstimate(List<Zone> zones) {
    final totalDuration = zones.length * 15; // mock calc
    final totalWater = zones.length * 450; // mock calc
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text('Total Estimated Time', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text('~$totalDuration min', style: AppTypography.headlineSmall),
            ],
          ),
          Container(width: 1, height: 40, color: AppColors.divider),
          Column(
            children: [
              Text('Total Estimated Water', style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.xs),
              Text('~$totalWater L', style: AppTypography.headlineSmall),
            ],
          ),
        ],
      ),
    );
  }

  void _showConfirmationSheet(BuildContext context, WidgetRef ref, List<Zone> zones) {
    final totalDuration = zones.length * 15;
    final totalWater = zones.length * 450;
    final zoneNames = zones.map((z) => z.name).join(' and ');
    
    AppBottomSheet.show(
      context,
      title: 'Start Irrigation?',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Irrigate $zoneNames', style: AppTypography.bodyLarge),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(Icons.timer, 'Estimated $totalDuration minutes'),
          const SizedBox(height: AppSpacing.sm),
          _buildInfoRow(Icons.water_drop, 'Estimated $totalWater L'),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Cancel',
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: PrimaryButton(
                  label: 'Start Irrigation',
                  onPressed: () {
                    Navigator.pop(context);
                    ref.read(irrigationControllerProvider.notifier)
                       .startRecommendedIrrigation(zones.map((z) => z.id).toList());
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.textSecondary),
        const SizedBox(width: AppSpacing.sm),
        Text(text, style: AppTypography.bodyMedium),
      ],
    );
  }
}
