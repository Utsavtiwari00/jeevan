import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/application/rover/rover_provider.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/rover_mission.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/buttons/primary_button.dart';
import 'package:jeevan/widgets/buttons/secondary_button.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/metrics/metric_row.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/status/status_badge.dart';

import 'package:jeevan/features/rover/widgets/rover_live_feed.dart';

class RoverOverviewScreen extends ConsumerWidget {
  const RoverOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roverAsync = ref.watch(roverProvider);
    final missionAsync = ref.watch(roverMissionProvider);
    final controllerState = ref.watch(roverControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(title: 'Rover Overview'),
      body: roverAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: RoverStatusSkeleton(),
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(roverProvider);
            ref.invalidate(roverMissionProvider);
          },
        ),
        data: (rover) {
          final mission = missionAsync.valueOrNull;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(rover),
                const SizedBox(height: AppSpacing.lg),
                const RoverLiveFeed(),
                const SizedBox(height: AppSpacing.xl),
                _buildMetrics(rover, mission),
                const SizedBox(height: AppSpacing.xl),
                _buildControls(context, ref, rover, controllerState.isLoading),
                const SizedBox(height: AppSpacing.xl),
                _buildQuickLinks(context),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(Rover rover) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        children: [
          CustomPaint(
            size: const Size(80, 80),
            painter: GeometricRoverPainter(),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('R-01', style: AppTypography.headlineMedium),
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    StatusBadge(
                      label: rover.status.label,
                      severity: _getStatusSeverity(rover.status),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    const Icon(Icons.wifi, size: 16, color: AppColors.textSecondary),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      rover.connectionStatus.label,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  StatusBadgeSeverity _getStatusSeverity(RoverStatus status) {
    switch (status) {
      case RoverStatus.scanning:
        return StatusBadgeSeverity.success;
      case RoverStatus.returning:
      case RoverStatus.paused:
        return StatusBadgeSeverity.warning;
      case RoverStatus.offline:
        return StatusBadgeSeverity.critical;
      default:
        return StatusBadgeSeverity.neutral;
    }
  }

  Widget _buildMetrics(Rover rover, RoverMission? mission) {
    final batteryColor = rover.batteryPercent > 50
        ? AppColors.accentGreen
        : (rover.batteryPercent > 20 ? AppColors.warningAmber : AppColors.criticalRed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Status'),
        const SizedBox(height: AppSpacing.md),
        MetricRow(
          label: 'Battery',
          value: '${rover.batteryPercent.toInt()}%',
          valueColor: batteryColor,
        ),
        MetricRow(
          label: 'Connection',
          value: rover.connectionStatus.label,
        ),
        MetricRow(
          label: 'Current Zone',
          value: rover.currentZoneId ?? 'None',
        ),
        MetricRow(
          label: 'GPS',
          value: '${rover.latitude.toStringAsFixed(4)}, ${rover.longitude.toStringAsFixed(4)}',
        ),
        MetricRow(
          label: 'Current Mission',
          value: mission?.name ?? 'None',
        ),
        MetricRow(
          label: 'Scan Coverage',
          value: mission != null ? '${mission.coveragePercent.toInt()}%' : 'N/A',
        ),
        MetricRow(
          label: 'Irrigation System',
          value: 'Connected',
        ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref, Rover rover, bool isLoading) {
    final controller = ref.read(roverControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Controls'),
        const SizedBox(height: AppSpacing.md),
        if (rover.status == RoverStatus.scanning) ...[
          Row(
            children: [
              Expanded(
                child: SecondaryButton(
                  label: 'Pause',
                  isLoading: isLoading,
                  onPressed: () => controller.pauseScan(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Return to Base',
                  isLoading: isLoading,
                  textColor: AppColors.criticalRed,
                  borderColor: AppColors.criticalRed,
                  onPressed: () => _confirmReturnToBase(context, controller),
                ),
              ),
            ],
          ),
        ] else if (rover.status == RoverStatus.paused) ...[
          Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: 'Resume',
                  isLoading: isLoading,
                  onPressed: () => controller.resumeScan(),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: SecondaryButton(
                  label: 'Return to Base',
                  isLoading: isLoading,
                  onPressed: () => controller.returnToBase(),
                ),
              ),
            ],
          ),
        ] else if (rover.status == RoverStatus.idle) ...[
          SizedBox(
            width: double.infinity,
            child: PrimaryButton(
              label: 'Start Scan',
              isLoading: isLoading,
              onPressed: () => controller.startScan(),
            ),
          ),
        ] else if (rover.status == RoverStatus.returning) ...[
          Text(
            'Scanning will resume at base',
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
        ],
      ],
    );
  }

  void _confirmReturnToBase(BuildContext context, RoverController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceWhite,
        title: Text('Return rover to base?', style: AppTypography.headlineSmall),
        content: Text(
          'This will interrupt the current scan. The rover will return to its charging station.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.returnToBase();
            },
            child: const Text('Return to Base', style: TextStyle(color: AppColors.criticalRed)),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLinks(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('View Current Mission', style: AppTypography.bodyLarge),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {},
        ),
        const Divider(color: AppColors.divider),
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text('View Field Map', style: AppTypography.bodyLarge),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          onTap: () {},
        ),
      ],
    );
  }
}

class GeometricRoverPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    
    final fillPaint = Paint()
      ..color = AppColors.accentGreen.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw hexagon
    final path = Path();
    final w = size.width;
    final h = size.height;
    path.moveTo(w * 0.5, h * 0.1);
    path.lineTo(w * 0.9, h * 0.3);
    path.lineTo(w * 0.9, h * 0.7);
    path.lineTo(w * 0.5, h * 0.9);
    path.lineTo(w * 0.1, h * 0.7);
    path.lineTo(w * 0.1, h * 0.3);
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, paint);

    // Antenna
    canvas.drawLine(Offset(w * 0.5, h * 0.1), Offset(w * 0.5, h * 0.0), paint);
    canvas.drawCircle(Offset(w * 0.5, h * 0.0), 3, Paint()..color = AppColors.accentGreen);
    
    // Internal geometric lines
    canvas.drawLine(Offset(w * 0.1, h * 0.3), Offset(w * 0.9, h * 0.7), paint);
    canvas.drawLine(Offset(w * 0.1, h * 0.7), Offset(w * 0.9, h * 0.3), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
