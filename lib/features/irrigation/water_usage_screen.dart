import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:jeevan/application/irrigation/irrigation_provider.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/irrigation_event.dart';
import 'package:jeevan/domain/repositories/irrigation_repository.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/empty_state.dart';
import 'package:jeevan/widgets/states/error_state.dart';

class WaterUsageScreen extends ConsumerWidget {
  const WaterUsageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterUsageAsync = ref.watch(waterUsageProvider);
    final historyAsync = ref.watch(irrigationHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(title: 'Water Usage'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUsageSummary(),
            const SizedBox(height: AppSpacing.xl),
            
            const SectionHeader(title: 'This Week'),
            const SizedBox(height: AppSpacing.md),
            waterUsageAsync.when(
              loading: () => const ChartSkeleton(),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(waterUsageProvider),
              ),
              data: (usageData) => _buildChart(usageData),
            ),
            const SizedBox(height: AppSpacing.xl),

            const SectionHeader(title: 'Recent Irrigation Events'),
            const SizedBox(height: AppSpacing.md),
            historyAsync.when(
              loading: () => const ActivityTimelineSkeleton(),
              error: (error, stack) => ErrorState(
                message: error.toString(),
                onRetry: () => ref.invalidate(irrigationHistoryProvider),
              ),
              data: (history) => _buildEventLog(history),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildUsageSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: _buildSummaryMetric('Today', '0L')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryMetric('This Week', '3,620L')),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: _buildSummaryMetric('This Month', '12,450L')),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            const Icon(Icons.eco, color: AppColors.accentGreen, size: 20),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'Estimated savings: 2,800L',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.accentGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryMetric(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: AppTypography.headlineSmall),
        ],
      ),
    );
  }

  Widget _buildChart(List<DailyWaterUsage> usageData) {
    final staticValues = [850.0, 620.0, 0.0, 780.0, 920.0, 450.0, 0.0];
    final dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Container(
      height: 250,
      padding: const EdgeInsets.only(top: AppSpacing.lg, right: AppSpacing.lg, bottom: AppSpacing.sm, left: AppSpacing.xs),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 1000,
          minY: 0,
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()}L',
                  AppTypography.bodyMedium.copyWith(color: AppColors.surfaceWhite),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= dayLabels.length) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      dayLabels[index],
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                    ),
                  );
                },
                reservedSize: 28,
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  if (value == 0) return const SizedBox.shrink();
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Text(
                      '${value.toInt()}',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                      textAlign: TextAlign.right,
                    ),
                  );
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 250,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: AppColors.divider,
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(
            staticValues.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: staticValues[index],
                  color: AppColors.waterBlue,
                  width: 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEventLog(List<IrrigationEvent> history) {
    if (history.isEmpty) {
      return const EmptyState(
        icon: Icons.history,
        title: 'No History',
        message: 'No irrigation events yet',
      );
    }

    // Sort by recent first
    final sortedHistory = List<IrrigationEvent>.from(history)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return Column(
      children: sortedHistory.map((event) {
        return Container(
          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.sm),
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.divider)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Zone ${event.zoneId.split('-').last.toUpperCase()}',
                    style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${DateFormat('MMM d, HH:mm').format(event.timestamp)} · ${event.triggeredBy.name}',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${event.waterUsedLiters.toInt()}L', style: AppTypography.bodyLarge),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${event.durationMinutes} min',
                    style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
