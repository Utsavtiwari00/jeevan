import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_colors.dart';
import 'package:jeevan/core/theme/app_spacing.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/widgets/app_bar/jeevan_app_bar.dart';
import 'package:jeevan/widgets/crop/crop_health_scan_section.dart';
import 'package:jeevan/widgets/crop/ai_crop_insights_card.dart';
import 'package:jeevan/features/rover/widgets/rover_live_feed.dart';

/// Unified Trackbot Cockpit: Live MediaMTX Camera Stream + AI Crop Health Scanning & Diagnostics.
class RoverOverviewScreen extends ConsumerWidget {
  const RoverOverviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Default reference zone for scan display
    const defaultZone = Zone(
      id: 'zone-a',
      name: 'Trackbot R-01',
      soilMoisture: 45.0,
      rainIntensity: 0.0,
      temperature: 28.0,
      humidity: 65.0,
      disease: 'none',
      diseaseConfidence: 0.0,
    );

    return Scaffold(
      backgroundColor: AppColors.paperBackground,
      appBar: const JeevanAppBar(
        title: 'Rover Cam & Scan',
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Live Camera Stream Header & Player (WebRTC WHEP / Browser)
            const RoverLiveFeed(),
            const SizedBox(height: AppSpacing.lg),

            // 2. Real-Time Crop Health AI Scan Section (Firebase RTDB trackbot/scan/)
            const CropHealthScanSection(
              zone: defaultZone,
              showViewAnalysisLink: false,
            ),
            const SizedBox(height: AppSpacing.lg),

            // 3. AI Agronomic Advisory (LLM-driven structured recommendations)
            const AiCropInsightsCard(),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }
}
