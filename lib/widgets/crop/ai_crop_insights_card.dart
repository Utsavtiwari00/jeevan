import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:jeevan/core/routing/route_paths.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_radius.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/core/theme/app_typography.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/application/chat/chat_provider.dart';

/// Clean, structured AI Agronomic Advisory card powered by the LLM & on-device TFLite scan.
class AiCropInsightsCard extends ConsumerWidget {
  const AiCropInsightsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scanAsync = ref.watch(cropScanStreamProvider);

    return scanAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (e, st) => const SizedBox.shrink(),
      data: (scan) {
        if (!scan.isCompleted) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceWhite,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.accentGreenLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    color: AppColors.accentGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Agronomic Insights',
                        style: AppTypography.titleSmall
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Trigger a crop scan above to receive instant structured treatment protocols.',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        return _buildStructuredAdvisory(context, ref, scan);
      },
    );
  }

  Widget _buildStructuredAdvisory(
    BuildContext context,
    WidgetRef ref,
    CropScanResult scan,
  ) {
    final hasDisease = scan.hasDisease;
    final disease = scan.formattedDisease;
    final crop = scan.formattedCrop;
    final confidence = scan.formattedConfidence;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: hasDisease
              ? AppColors.warningAmber.withValues(alpha: 0.5)
              : AppColors.accentGreen.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: hasDisease
                      ? AppColors.warningAmberLight
                      : AppColors.accentGreenLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome,
                  color: hasDisease
                      ? AppColors.warningAmber
                      : AppColors.accentGreen,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'AI Agronomic Advisory',
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.charcoalSoil,
                  ),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.paperBackground,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: Text(
                  'Jeevan AI',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.accentGreen,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // Diagnostic Summary Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.paperBackground,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  hasDisease
                      ? Icons.warning_amber_rounded
                      : Icons.check_circle_outline,
                  color: hasDisease
                      ? AppColors.warningAmber
                      : AppColors.accentGreen,
                  size: 20,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(
                    hasDisease
                        ? 'Active $disease detected on $crop ($confidence confidence). Action recommended.'
                        : 'Healthy $crop foliage verified ($confidence confidence). No pathogen symptoms.',
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalSoil,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Structured Recommendations
          if (hasDisease) ...[
            Text(
              'Immediate Field Actions:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalSoil,
              ),
            ),
            const SizedBox(height: 4),
            _buildBulletPoint(
              'Prune Infected Foliage',
              'Carefully remove and destroy lower leaves exhibiting circular necrotic lesions.',
            ),
            _buildBulletPoint(
              'Apply Fungicide Spray',
              'Spray Copper Oxychloride (0.25%) or organic Neem oil early morning.',
            ),
            _buildBulletPoint(
              'Water Management',
              'Maintain drip irrigation to avoid canopy splashing and high leaf humidity.',
            ),
          ] else ...[
            Text(
              'Preventative Maintenance:',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.charcoalSoil,
              ),
            ),
            const SizedBox(height: 4),
            _buildBulletPoint(
              'Optimal Soil Moisture',
              'Maintain 40–60% soil moisture range to prevent moisture stress.',
            ),
            _buildBulletPoint(
              'Routine Surveillance',
              'Next scheduled Trackbot scan recommended in 3 days.',
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: AppSpacing.sm),

          // Ask AI Button
          InkWell(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            onTap: () {
              final inquiry = hasDisease
                  ? 'How should I treat the $disease detected on my $crop?'
                  : 'What are the best cultivation practices for my $crop?';
              ref.read(chatControllerProvider.notifier).sendMessage(inquiry);
              context.push(RoutePaths.assistant);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.chat_bubble_outline,
                      size: 16, color: AppColors.accentGreen),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    hasDisease
                        ? 'Ask AI for Full Treatment Plan'
                        : 'Ask AI Agricultural Assistant',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.accentGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right,
                      size: 18, color: AppColors.accentGreen),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6),
            child: Icon(Icons.circle, size: 5, color: AppColors.accentGreen),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySmall
                    .copyWith(color: AppColors.textSecondary),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppColors.charcoalSoil,
                    ),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
