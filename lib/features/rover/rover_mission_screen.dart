import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/application/rover/rover_provider.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/rover_mission.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/layout/section_header.dart';
import 'package:jeevan/widgets/skeleton/skeleton_composites.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:intl/intl.dart';

class RoverMissionScreen extends ConsumerWidget {
  const RoverMissionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionAsync = ref.watch(roverMissionProvider);

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(title: 'Rover Mission'),
      body: missionAsync.when(
        loading: () => const SingleChildScrollView(
          padding: EdgeInsets.all(AppSpacing.md),
          child: ActivityTimelineSkeleton(),
        ),
        error: (error, stack) => ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(roverMissionProvider),
        ),
        data: (mission) {
          if (mission == null) {
            return Center(
              child: Text(
                'No active mission',
                style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMissionHeader(mission),
                const SizedBox(height: AppSpacing.xl),
                _buildCoverageProgress(mission),
                const SizedBox(height: AppSpacing.xl),
                _buildZoneSequence(mission),
                const SizedBox(height: AppSpacing.xl),
                _buildActivityTimeline(mission),
                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMissionHeader(RoverMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(mission.name, style: AppTypography.headlineLarge),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            StatusBadge(
              label: mission.status.name.toUpperCase(),
              severity: mission.status == MissionStatus.running 
                  ? StatusBadgeSeverity.success 
                  : StatusBadgeSeverity.neutral,
            ),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Started: ${DateFormat('HH:mm').format(mission.startedAt)}',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCoverageProgress(RoverMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Coverage', style: AppTypography.headlineSmall),
            Text('${mission.coveragePercent.toInt()}%', style: AppTypography.headlineMedium),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LinearProgressIndicator(
          value: mission.coveragePercent / 100,
          backgroundColor: AppColors.divider,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accentGreen),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _buildZoneSequence(RoverMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Zone Sequence'),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(mission.zoneSequence.length, (index) {
              final zoneId = mission.zoneSequence[index];
              final isCurrent = zoneId == mission.currentZoneId;
              final isCompleted = mission.zoneSequence.indexOf(mission.currentZoneId) > index;
              
              return Row(
                children: [
                  _buildZoneStep(zoneId, isCurrent, isCompleted),
                  if (index < mission.zoneSequence.length - 1)
                    Container(
                      width: 40,
                      height: 2,
                      color: isCompleted ? AppColors.accentGreen : AppColors.divider,
                    ),
                ],
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildZoneStep(String zoneId, bool isCurrent, bool isCompleted) {
    final color = isCurrent || isCompleted ? AppColors.accentGreen : AppColors.divider;
    final textColor = isCurrent ? AppColors.surfaceWhite : (isCompleted ? AppColors.accentGreen : AppColors.textSecondary);
    final bgColor = isCurrent ? AppColors.accentGreen : AppColors.surfaceWhite;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
        border: Border.all(color: color, width: 2),
      ),
      alignment: Alignment.center,
      child: isCompleted
          ? Icon(Icons.check, color: color, size: 20)
          : Text(
              zoneId.split('-').last.toUpperCase(),
              style: AppTypography.bodyLarge.copyWith(color: textColor, fontWeight: FontWeight.bold),
            ),
    );
  }

  Widget _buildActivityTimeline(RoverMission mission) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Activity Log'),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(mission.activityLog.length, (index) {
          final entry = mission.activityLog[index];
          final isCurrent = index == mission.activityLog.length - 1;
          
          return IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 50,
                  child: Text(
                    DateFormat('HH:mm').format(entry.timestamp),
                    style: AppTypography.bodySmall.copyWith(
                      color: isCurrent ? AppColors.charcoalSoil : AppColors.textSecondary,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCurrent ? AppColors.accentGreen : AppColors.divider,
                        border: isCurrent ? Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3), width: 4) : null,
                      ),
                    ),
                    if (index < mission.activityLog.length - 1)
                      Expanded(
                        child: Container(
                          width: 2,
                          color: AppColors.divider,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                    child: Text(
                      entry.label,
                      style: AppTypography.bodyMedium.copyWith(
                        color: isCurrent ? AppColors.charcoalSoil : AppColors.textSecondary,
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
