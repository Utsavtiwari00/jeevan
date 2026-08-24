import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/features/field/zone_detail_screen.dart';

void main() {
  testWidgets('ZoneDetailScreen renders zone details and completed crop scan from Firebase', (tester) async {
    const mockScan = CropScanResult(
      requestId: 'test001',
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
          home: const ZoneDetailScreen(zoneId: 'zone-a'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    // Verify Zone A sensor metrics
    expect(find.text('Zone A'), findsOneWidget);
    expect(find.text('Sensor Readings'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Crop Health'), findsOneWidget);

    // Verify Crop Health Section details from Firebase
    expect(find.text('Early Blight'), findsOneWidget);
    expect(find.text('Crop: Tomato'), findsOneWidget);
    expect(find.text('91.4%'), findsOneWidget);
    expect(find.text('350 ms'), findsOneWidget);
    expect(find.text('Scan Crop'), findsOneWidget);
    expect(find.text('View full analysis details'), findsOneWidget);
  });

  testWidgets('ZoneDetailScreen displays Analyzing crop... when status is requested/processing', (tester) async {
    const processingScan = CropScanResult(
      requestId: 'test002',
      status: CropScanStatus.requested,
      requestedAt: 1755940000000,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cropScanStreamProvider.overrideWith((ref) => Stream.value(processingScan)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ZoneDetailScreen(zoneId: 'zone-a'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Analyzing crop...'), findsOneWidget);
    expect(find.text('REQUESTED'), findsOneWidget);
    expect(find.text('Scan request dispatched to Raspberry Pi Trackbot...'), findsOneWidget);
  });

  testWidgets('ZoneDetailScreen displays No crop scan available when scan is idle', (tester) async {
    const idleScan = CropScanResult.idle();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          cropScanStreamProvider.overrideWith((ref) => Stream.value(idleScan)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ZoneDetailScreen(zoneId: 'zone-a'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('No crop scan available'), findsOneWidget);
    expect(find.text('Scan Crop'), findsOneWidget);
  });
}
