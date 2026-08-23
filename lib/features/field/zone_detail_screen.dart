import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/sensor_reading.dart';
import 'package:jeevan/domain/models/crop_scan.dart';
import 'package:jeevan/application/field/field_provider.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/metrics/sensor_metric.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/irrigation/irrigation_recommendation.dart';
import 'package:jeevan/widgets/crop/crop_health_card.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/core/utils/formatters.dart';

class ZoneDetailScreen extends ConsumerWidget {
  final String zoneId;

  const ZoneDetailScreen({super.key, required this.zoneId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final zoneAsync = ref.watch(zoneDetailProvider(zoneId));
    final readingAsync = ref.watch(sensorReadingProvider(zoneId));
    final cropScanAsync = ref.watch(latestCropScanProvider(zoneId));

    return Scaffold(
      appBar: const JeevanAppBar(
        title: 'Zone Details',
        showBackButton: true,
      ),
      body: zoneAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: Column(
            children: [
              SensorReadingSkeleton(),
              SizedBox(height: AppSpacing.lg),
              CropHealthSkeleton(),
            ],
          ),
        ),
        error: (err, stack) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.refresh(zoneDetailProvider(zoneId)),
        ),
        data: (zone) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(zone),
                const SizedBox(height: AppSpacing.lg),
                _buildSensorReadings(readingAsync, zone),
                const SizedBox(height: AppSpacing.lg),
                if (zone.status == ZoneStatus.irrigationRecommended) ...[
                  _buildIrrigationBlock(context, ref, zone),
                  const SizedBox(height: AppSpacing.lg),
                ],
                _buildCropHealthSummary(context, cropScanAsync, zone.id),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Zone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(zone.name, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(zone.cropType, style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            StatusBadge(
              label: '${Formatters.capitalize(zone.moistureCategory.name)} — ${zone.currentMoisturePercent.toStringAsFixed(0)}%',
              severity: _getMoistureSeverity(zone.moistureCategory),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          Formatters.formatZoneStatus(zone.status),
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildSensorReadings(AsyncValue<SensorReading> readingAsync, Zone zone) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Sensor Readings'),
        const SizedBox(height: AppSpacing.sm),
        readingAsync.when(
          loading: () => const SensorReadingSkeleton(),
          error: (err, stack) => Text('Failed to load readings: $err'),
          data: (reading) {
            return Column(
              children: [
                SensorMetric(
                  icon: Icons.water_drop,
                  label: 'Soil Moisture',
                  value: reading.soilMoisture.toStringAsFixed(0),
                  unit: '%',
                  statusLabel: Formatters.capitalize(zone.moistureCategory.name),
                  statusColor: _getMoistureColor(zone.moistureCategory),
                ),
                SensorMetric(
                  icon: Icons.thermostat,
                  label: 'Soil Temperature',
                  value: reading.soilTemperature.toStringAsFixed(1),
                  unit: '°C',
                ),
                SensorMetric(
                  icon: Icons.air,
                  label: 'Air Temperature',
                  value: reading.airTemperature.toStringAsFixed(1),
                  unit: '°C',
                ),
                SensorMetric(
                  icon: Icons.water,
                  label: 'Humidity',
                  value: reading.humidity.toStringAsFixed(0),
                  unit: '%',
                ),
                SensorMetric(
                  icon: Icons.cloud,
                  label: 'Rain',
                  value: reading.rainDetected ? 'Detected' : 'None',
                  unit: '',
                ),
                SensorMetric(
                  icon: Icons.wb_sunny,
                  label: 'Light Intensity',
                  value: reading.lightIntensity.toStringAsFixed(0),
                  unit: 'lux',
                ),
                SensorMetric(
                  icon: Icons.opacity,
                  label: 'Water Level',
                  value: reading.waterLevel.toStringAsFixed(0),
                  unit: '%',
                ),
                SensorMetric(
                  icon: Icons.science,
                  label: 'pH',
                  value: reading.ph.toStringAsFixed(1),
                  unit: '',
                ),
                SensorMetric(
                  icon: Icons.electric_bolt,
                  label: 'EC',
                  value: reading.ec.toStringAsFixed(1),
                  unit: 'mS/cm',
                ),
                SensorMetric(
                  icon: Icons.speed,
                  label: 'Flow Rate',
                  value: reading.flowRate.toStringAsFixed(1),
                  unit: 'L/min',
                  showDivider: false,
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildIrrigationBlock(BuildContext context, WidgetRef ref, Zone zone) {
    return IrrigationRecommendation(
      currentMoisture: '${zone.currentMoisturePercent.toStringAsFixed(0)}%',
      preferredRange: '40-60%',
      rainOutlook: 'None expected',
      waterAvailability: '74%',
      estimatedDuration: zone.id == 'zone-a' ? '14 min' : '16 min',
      onIrrigate: () {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Irrigation'),
            content: Text('Are you sure you want to irrigate ${zone.name}?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ref.read(irrigationControllerProvider.notifier).triggerIrrigation(zone.id, 15);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Irrigation started for ${zone.name}')),
                  );
                },
                child: const Text('Confirm', style: TextStyle(color: AppColors.accentGreen)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCropHealthSummary(BuildContext context, AsyncValue<CropScan?> cropScanAsync, String zoneId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Crop Health'),
        const SizedBox(height: AppSpacing.sm),
        cropScanAsync.when(
          loading: () => const CropHealthSkeleton(),
          error: (err, stack) => const Text('Failed to load crop scan'),
          data: (scan) {
            if (scan == null) {
              return Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.skeletonBase,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('No crop scan yet — scan this zone\'s crops', style: TextStyle(color: AppColors.textSecondary)),
                ),
              );
            }
            return CropHealthCard(
              diagnosis: scan.diagnosis,
              confidence: '${scan.confidencePercent.toStringAsFixed(0)}%',
              severity: _getSeverity(scan.severity),
              indicators: scan.indicators,
              onViewAnalysis: () {
                context.push('/field/zone/$zoneId/crop-analysis');
              },
            );
          },
        ),
      ],
    );
  }

  Color _getMoistureColor(MoistureCategory category) {
    switch (category) {
      case MoistureCategory.veryLow:
        return AppColors.criticalRed;
      case MoistureCategory.low:
        return AppColors.warningAmber;
      case MoistureCategory.medium:
        return AppColors.warningAmber;
      case MoistureCategory.high:
        return AppColors.accentGreen;
    }
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

  StatusBadgeSeverity _getMoistureSeverity(MoistureCategory category) {
    switch (category) {
      case MoistureCategory.veryLow:
        return StatusBadgeSeverity.critical;
      case MoistureCategory.low:
        return StatusBadgeSeverity.warning;
      case MoistureCategory.medium:
        return StatusBadgeSeverity.neutral;
      case MoistureCategory.high:
        return StatusBadgeSeverity.success;
    }
  }
}
