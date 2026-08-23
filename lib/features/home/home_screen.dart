import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/utils/formatters.dart';
import 'package:jeevan/application/home/home_provider.dart';
import 'package:jeevan/application/auth/auth_provider.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/metrics/metric_row.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/alerts/alert_banner.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final farmAsync = ref.watch(farmProvider);
    final alertsAsync = ref.watch(homeAlertsProvider);
    final overviewAsync = ref.watch(farmOverviewProvider);

    if (farmAsync.isLoading || alertsAsync.isLoading || overviewAsync.isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: HomeSkeleton(),
      );
    }

    if (farmAsync.hasError) {
      return Scaffold(
        backgroundColor: AppColors.paperBackground,
        body: ErrorState(
          message: farmAsync.error.toString(),
          onRetry: () {
            ref.invalidate(farmProvider);
            ref.invalidate(homeAlertsProvider);
            ref.invalidate(farmOverviewProvider);
          },
        ),
      );
    }

    final user = userAsync.value;
    final farm = farmAsync.value!;
    final alerts = alertsAsync.value ?? [];
    final overview = overviewAsync.value!;

    String greeting = Formatters.greetingForTimeOfDay(DateTime.now());
    if (user != null && user.name.isNotEmpty) {
      greeting += ', ${user.name.split(' ').first}';
    }

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: JeevanAppBar(
        title: 'Jeevan',
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications),
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
            icon: const Icon(Icons.account_circle),
            onPressed: () => context.push(RoutePaths.profile),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // A. Greeting Section
            Text(
              greeting,
              style: AppTypography.headlineMedium.copyWith(color: AppColors.charcoalSoil),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              alerts.isEmpty 
                  ? 'Your farm is looking stable today.' 
                  : 'Attention needed on your farm.',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // B. Farm Identity Block
            Text(
              farm.name,
              style: AppTypography.headlineSmall.copyWith(color: AppColors.charcoalSoil),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              '${farm.areaAcres} acres · ${farm.zoneCount} zones · R-01 connected',
              style: AppTypography.bodySmall.copyWith(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppSpacing.xl),

            // C. Field Status Section
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  MetricRow(
                    icon: Icons.water_drop,
                    label: 'Soil Moisture',
                    value: '${overview.averageMoisture.toStringAsFixed(1)}%',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  MetricRow(
                    icon: Icons.opacity,
                    label: 'Water Availability',
                    value: '74%',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  MetricRow(
                    icon: Icons.cloud,
                    label: 'Rain Status',
                    value: alerts.any((a) => a.title.contains('Rain')) ? 'Detected' : 'None',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  MetricRow(
                    icon: Icons.precision_manufacturing,
                    label: 'Rover Status',
                    value: 'Scanning',
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // D. Alerts Section
            SectionHeader(
              title: 'Alerts',
            ),
            const SizedBox(height: AppSpacing.md),
            if (alerts.isEmpty)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.surfaceWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, color: AppColors.accentGreen),
                    const SizedBox(width: AppSpacing.md),
                    Text('All clear', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  ],
                ),
              )
            else
              ...alerts.map((alert) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AlertBanner(
                  title: alert.title,
                  subtitle: alert.subtitle,
                  severity: alert.severity == 'critical' ? StatusBadgeSeverity.critical : StatusBadgeSeverity.warning,
                  onAction: () => context.push(alert.actionRoute),
                  actionLabel: alert.severity == 'critical' ? 'View analysis' : 'View field',
                ),
              )),
            const SizedBox(height: AppSpacing.xxl),

            // E. Farm Overview Section
            const SectionHeader(
              title: 'Farm Overview',
            ),
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  MetricRow(
                    icon: Icons.landscape,
                    label: 'Total Acreage',
                    value: '${overview.totalAcreage}',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  MetricRow(
                    icon: Icons.grid_view,
                    label: 'Active Zones',
                    value: '${overview.activeZones}',
                  ),
                  const Divider(color: AppColors.divider, height: AppSpacing.lg),
                  MetricRow(
                    icon: Icons.local_drink,
                    label: 'Water Used Today',
                    value: '${overview.waterUsedToday}',
                  ),
                ],
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
        tooltip: 'Ask Jeevan',
        child: const Icon(Icons.chat_bubble_outline, size: 24),
      ),
    );
  }
}
