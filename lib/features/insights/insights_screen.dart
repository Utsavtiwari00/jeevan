import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/application/insights/insights_provider.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/metrics/metric_row.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);
    final selectedRange = ref.watch(selectedDateRangeProvider);
    final historicalAsync = ref.watch(historicalDataProvider(selectedRange));

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(title: 'Insights'),
      body: insightsAsync.when(
        loading: () => const InsightsSkeleton(),
        error: (err, stack) => ErrorState(
          message: 'Failed to load insights. Please try again.',
          onRetry: () => ref.refresh(insightsProvider),
        ),
        data: (data) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: DateRange.values.map((range) {
                      final isSelected = range == selectedRange;
                      final label = _getRangeLabel(range);
                      
                      return Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChip(
                          label: Text(
                            label,
                            style: TextStyle(
                              color: isSelected ? AppColors.surfaceWhite : AppColors.textSecondary,
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (_) {
                            ref.read(selectedDateRangeProvider.notifier).state = range;
                          },
                          backgroundColor: AppColors.surfaceWhite,
                          selectedColor: AppColors.accentGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            side: BorderSide(
                              color: isSelected ? AppColors.accentGreen : AppColors.divider,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              _buildInsightSection(
                title: 'Soil Health',
                icon: Icons.grass, // Representing soil/earth
                insights: data.soil,
              ),
              _buildInsightSection(
                title: 'Water Usage',
                icon: Icons.water_drop,
                insights: data.water,
              ),
              _buildInsightSection(
                title: 'Crop Health',
                icon: Icons.eco,
                insights: data.cropHealth,
              ),
              _buildInsightSection(
                title: 'Rover Activity',
                icon: Icons.radar,
                insights: data.rover,
              ),
              _buildInsightSection(
                title: 'Weather',
                icon: Icons.cloud,
                insights: data.weather,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(
                        title: 'Historical Trends',
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      historicalAsync.when(
                        loading: () => const Padding(
                          padding: EdgeInsets.all(AppSpacing.lg),
                          child: Center(child: CircularProgressIndicator(color: AppColors.accentGreen)), // Simple inner loader
                        ),
                        error: (err, stack) => const Text('Could not load historical data', style: TextStyle(color: AppColors.criticalRed)),
                        data: (historical) {
                          return Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceWhite,
                              border: Border.all(color: AppColors.divider),
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            child: Column(
                              children: [
                                MetricRow(
                                  label: 'Avg Soil Moisture',
                                  value: '${historical.avgMoisture.toStringAsFixed(1)}%',
                                ),
                                const Divider(height: 1, color: AppColors.divider),
                                MetricRow(
                                  label: 'Total Water Used',
                                  value: '${historical.totalWaterUsed}L',
                                ),
                                const Divider(height: 1, color: AppColors.divider),
                                MetricRow(
                                  label: 'Irrigation Events',
                                  value: '${historical.irrigationCount}',
                                ),
                                const Divider(height: 1, color: AppColors.divider),
                                MetricRow(
                                  label: 'Temperature Range',
                                  value: historical.tempRange,
                                ),
                                const Divider(height: 1, color: AppColors.divider),
                                MetricRow(
                                  label: 'Rain Events',
                                  value: '${historical.rainEvents}',
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: AppSpacing.xl),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getRangeLabel(DateRange range) {
    switch (range) {
      case DateRange.today:
        return 'Today';
      case DateRange.week:
        return '7 Days';
      case DateRange.month:
        return '30 Days';
    }
  }

  Widget _buildInsightSection({
    required String title,
    required IconData icon,
    required List<InsightItem> insights,
  }) {
    if (insights.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: title,
            ),
            const SizedBox(height: AppSpacing.sm),
            ...insights.map((insight) => _InsightCard(item: insight)),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final InsightItem item;

  const _InsightCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final severityColor = _getSeverityColor(item.severity);
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.divider),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 4,
              color: severityColor,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            style: const TextStyle(
                              color: AppColors.charcoalSoil,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        StatusBadge(
                          label: _getSeverityLabel(item.severity),
                          severity: _getBadgeSeverity(item.severity),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      item.explanation,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'warning':
        return AppColors.warningAmber;
      case 'critical':
        return AppColors.criticalRed;
      case 'success':
        return AppColors.accentGreen;
      case 'info':
      default:
        return AppColors.waterBlue;
    }
  }

  String _getSeverityLabel(String severity) {
    switch (severity) {
      case 'warning': return 'Warning';
      case 'critical': return 'Critical';
      case 'success': return 'Good';
      case 'info':
      default: return 'Info';
    }
  }

  StatusBadgeSeverity _getBadgeSeverity(String severity) {
    switch (severity) {
      case 'warning': return StatusBadgeSeverity.warning;
      case 'critical': return StatusBadgeSeverity.critical;
      case 'success': return StatusBadgeSeverity.success;
      case 'info':
      default: return StatusBadgeSeverity.info;
    }
  }
}
