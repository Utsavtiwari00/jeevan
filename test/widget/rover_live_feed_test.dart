import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/features/rover/rover_overview_screen.dart';
import 'package:jeevan/features/rover/widgets/rover_live_feed.dart';
import 'package:jeevan/widgets/crop/crop_health_scan_section.dart';
import 'package:jeevan/widgets/crop/ai_crop_insights_card.dart';

void main() {
  testWidgets('RoverLiveFeed renders standby state and configure options', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: RoverLiveFeed(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Live Cam'), findsOneWidget);
    expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
  });

  testWidgets('RoverOverviewScreen includes live camera feed, crop scan section, and AI insights', (tester) async {
    const mockScan = CropScanResult(
      requestId: 'test_rover_01',
      status: CropScanStatus.completed,
      crop: 'Tomato',
      disease: 'Early_blight',
      confidence: 0.9143,
      classIndex: 30,
      inferenceMs: 350.21,
      imageUrl: 'https://res.cloudinary.com/djmtbyhos/image/upload/sample.jpg',
      completedAt: 1755940000000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cropScanStreamProvider.overrideWith((ref) => Stream.value(mockScan)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RoverOverviewScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Rover Cam & Scan'), findsOneWidget);
    expect(find.byType(RoverLiveFeed), findsOneWidget);
    expect(find.byType(CropHealthScanSection), findsOneWidget);
    expect(find.byType(AiCropInsightsCard), findsOneWidget);
    expect(find.text('Early Blight'), findsOneWidget);
    expect(find.text('AI Agronomic Advisory'), findsOneWidget);
    expect(find.text('Scan Crop'), findsOneWidget);
  });
}
