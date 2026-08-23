import 'package:flutter/material.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'skeleton_loader.dart';
import 'skeleton_card.dart';

class HomeSkeleton extends StatelessWidget {
  const HomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLine(width: 200, height: 28),
        const SizedBox(height: AppSpacing.md),
        const SkeletonCard(height: 120, lineCount: 3, hasCircle: false),
        const SizedBox(height: AppSpacing.md),
        const SkeletonLine(width: double.infinity, height: 48),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLine(width: double.infinity, height: 48),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLine(width: double.infinity, height: 48),
        const SizedBox(height: AppSpacing.md),
        const SkeletonLine(width: 150, height: 24),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonCard(height: 80, lineCount: 2, hasCircle: true),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonCard(height: 80, lineCount: 2, hasCircle: true),
      ],
    );
  }
}

class ZoneTileSkeleton extends StatelessWidget {
  const ZoneTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonCard(height: 88, lineCount: 2, hasCircle: true);
  }
}

class FieldMapSkeleton extends StatelessWidget {
  const FieldMapSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const SkeletonLoader(
      width: double.infinity,
      height: 300,
      borderRadius: AppRadius.md,
    );
  }
}

class RoverStatusSkeleton extends StatelessWidget {
  const RoverStatusSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              SkeletonCircle(size: 32),
              SizedBox(width: AppSpacing.sm),
              SkeletonLine(width: 120, height: 20),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ...List.generate(4, (index) => const Padding(
            padding: EdgeInsets.only(bottom: AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SkeletonLine(width: 80, height: 16),
                SkeletonLine(width: 60, height: 16),
              ],
            ),
          )),
          const SizedBox(height: AppSpacing.md),
          const SkeletonLine(width: double.infinity, height: 48),
        ],
      ),
    );
  }
}

class ChartSkeleton extends StatelessWidget {
  const ChartSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(7, (index) => SkeletonLoader(
          width: 24,
          height: 40.0 + (index * 15 % 100),
          borderRadius: AppRadius.xs,
        )),
      ),
    );
  }
}

class ActivityTimelineSkeleton extends StatelessWidget {
  const ActivityTimelineSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) => Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SkeletonCircle(size: 16),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonLine(width: double.infinity, height: 16),
                  SizedBox(height: AppSpacing.xs),
                  SkeletonLine(width: 150, height: 12),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}

class NotificationSkeleton extends StatelessWidget {
  const NotificationSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(5, (index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.sm),
        child: SkeletonCard(height: 80, lineCount: 2, hasCircle: true),
      )),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        const Center(child: SkeletonCircle(size: 100)),
        const SizedBox(height: AppSpacing.md),
        const Center(child: SkeletonLine(width: 150, height: 24)),
        const SizedBox(height: AppSpacing.xs),
        const Center(child: SkeletonLine(width: 200, height: 16)),
        const SizedBox(height: AppSpacing.xl),
        ...List.generate(4, (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonCard(height: 64, lineCount: 1, hasCircle: true),
        )),
      ],
    );
  }
}

class CropHealthSkeleton extends StatelessWidget {
  const CropHealthSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonLoader(width: double.infinity, height: 200, borderRadius: AppRadius.md),
        const SizedBox(height: AppSpacing.md),
        const SkeletonLine(width: 200, height: 24),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLine(width: double.infinity, height: 16),
        const SizedBox(height: AppSpacing.xs),
        const SkeletonLine(width: 250, height: 16),
        const SizedBox(height: AppSpacing.md),
        ...List.generate(3, (index) => const Padding(
          padding: EdgeInsets.only(bottom: AppSpacing.sm),
          child: SkeletonLine(width: double.infinity, height: 16),
        )),
      ],
    );
  }
}

class SensorReadingSkeleton extends StatelessWidget {
  const SensorReadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(6, (index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                SkeletonCircle(size: 24),
                SizedBox(width: AppSpacing.sm),
                SkeletonLine(width: 100, height: 16),
              ],
            ),
            SkeletonLine(width: 60, height: 16),
          ],
        ),
      )),
    );
  }
}

class InsightsSkeleton extends StatelessWidget {
  const InsightsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(3, (index) => const Padding(
        padding: EdgeInsets.only(bottom: AppSpacing.md),
        child: SkeletonCard(height: 140, lineCount: 4, hasCircle: false),
      )),
    );
  }
}

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Align(
          alignment: Alignment.centerRight,
          child: SkeletonLoader(width: 200, height: 60, borderRadius: AppRadius.md),
        ),
        const SizedBox(height: AppSpacing.md),
        const Align(
          alignment: Alignment.centerLeft,
          child: SkeletonLoader(width: 250, height: 100, borderRadius: AppRadius.md),
        ),
        const SizedBox(height: AppSpacing.md),
        const Align(
          alignment: Alignment.centerRight,
          child: SkeletonLoader(width: 150, height: 60, borderRadius: AppRadius.md),
        ),
      ],
    );
  }
}
