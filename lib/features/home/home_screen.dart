import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/utils/formatters.dart';
import 'package:jeevan/application/home/home_provider.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/alerts/alert_banner.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(homeAlertsProvider);
    final overviewAsync = ref.watch(farmOverviewProvider);
    final sensorDataAsync = ref.watch(homeSensorDataProvider);
    final tankDataAsync = ref.watch(homeTankDataProvider);

    if (alertsAsync.isLoading || overviewAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: HomeSkeleton(),
      );
    }

    if (alertsAsync.hasError || overviewAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: ErrorState(
          message: alertsAsync.hasError
              ? alertsAsync.error.toString()
              : overviewAsync.error.toString(),
          onRetry: () {
            ref.invalidate(homeAlertsProvider);
            ref.invalidate(farmOverviewProvider);
            ref.invalidate(homeSensorDataProvider);
            ref.invalidate(homeTankDataProvider);
          },
        ),
      );
    }

    final alerts = alertsAsync.value ?? [];
    final overview = overviewAsync.value!;
    final sensorData = sensorDataAsync.value ?? MockSeedData.sensorData;
    final tankData = tankDataAsync.value ?? MockSeedData.tankData;

    final greeting =
        '${Formatters.greetingForTimeOfDay(DateTime.now())}, Utssav';

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: JeevanAppBar(
        title: 'Jeevan',
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (alerts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppColors.criticalRed,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 8,
                        minHeight: 8,
                      ),
                    ),
                  )
              ],
            ),
            onPressed: () => context.push(RoutePaths.notifications),
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () => context.push(RoutePaths.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // A. Header Greeting & Farm Identity
            Text(
              greeting,
              style: AppTypography.headlineMedium
                  .copyWith(color: AppColors.charcoalSoil),
            ),
            const SizedBox(height: 2),
            Text(
              'Green Valley Farm · 12.4 acres · 4 active zones',
              style: AppTypography.bodySmall
                  .copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),

            // B. Hero Live Rover Cam & AI Crop Scan Shortcut Card
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.go(RoutePaths.rover),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.charcoalSoil,
                      AppColors.charcoalSoil.withValues(alpha: 0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.accentGreen.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.videocam_rounded,
                        color: AppColors.accentGreen,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Trackbot Live Cockpit',
                                style: AppTypography.titleSmall.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1.5,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.criticalRed,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'LIVE',
                                  style: AppTypography.caption.copyWith(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Stream live video & trigger AI crop diagnostics',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Colors.white60,
                      size: 16,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // C. Live Rover Telemetry & Sensors (Direct Firebase RTDB Stream)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Rover Live Telemetry',
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.charcoalSoil,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreen.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.accentGreen.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.accentGreen,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'LIVE RTDB',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.accentGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.water_drop_outlined,
                    iconColor: AppColors.waterBlue,
                    title: 'Soil Moisture',
                    value:
                        '${sensorData.soilMoisture.toStringAsFixed(sensorData.soilMoisture.truncateToDouble() == sensorData.soilMoisture ? 0 : 1)}%',
                    subtitle: 'Rover probe reading',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.thermostat_outlined,
                    iconColor: const Color(0xFFE65100),
                    title: 'Temperature',
                    value: '${sensorData.temperature.toStringAsFixed(1)}°C',
                    subtitle: 'Ambient air sensor',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.air_rounded,
                    iconColor: AppColors.accentGreen,
                    title: 'Air Humidity',
                    value:
                        '${sensorData.humidity.toStringAsFixed(sensorData.humidity.truncateToDouble() == sensorData.humidity ? 0 : 1)}%',
                    subtitle: 'Relative humidity',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildTelemetryCard(
                    icon: sensorData.isRaining
                        ? Icons.grain_rounded
                        : Icons.cloud_outlined,
                    iconColor: sensorData.isRaining
                        ? AppColors.waterBlue
                        : AppColors.warningAmber,
                    title: 'Rain Status',
                    value: sensorData.rainStatus,
                    subtitle:
                        '${sensorData.rainIntensity.toStringAsFixed(0)} mm/h intensity',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.sanitizer_outlined,
                    iconColor: AppColors.accentGreen,
                    title: 'Pesticide Level',
                    value: '${tankData.pesticideLevel.toStringAsFixed(0)}%',
                    subtitle: 'Spray tank capacity',
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: _buildTelemetryCard(
                    icon: Icons.precision_manufacturing_outlined,
                    iconColor: AppColors.charcoalSoil,
                    title: 'Trackbot R-01',
                    value: 'Connected',
                    subtitle: 'IMX219 Cam Ready',
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // D. Priority Alerts Section
            const SectionHeader(title: 'Farm Alerts'),
            const SizedBox(height: AppSpacing.sm),
            if (alerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: AppColors.accentGreen),
                    const SizedBox(width: AppSpacing.md),
                    Text(
                      'All systems clear · No urgent issues',
                      style: AppTypography.bodyMedium
                          .copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...alerts.map(
                (alert) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: AlertBanner(
                    title: alert.title,
                    subtitle: alert.subtitle,
                    severity: alert.severity == 'critical'
                        ? StatusBadgeSeverity.critical
                        : StatusBadgeSeverity.warning,
                    onAction: () => context.push(alert.actionRoute),
                    actionLabel: alert.severity == 'critical'
                        ? 'View analysis'
                        : 'View field',
                  ),
                ),
              ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(RoutePaths.assistant),
        backgroundColor: AppColors.accentGreen,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 3,
        shape: const CircleBorder(),
        tooltip: 'Ask Jeevan AI',
        child: const Icon(Icons.chat_bubble_outline, size: 24),
      ),
    );
  }

  Widget _buildTelemetryCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: iconColor, size: 22),
              Text(
                value,
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.charcoalSoil,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.charcoalSoil,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
