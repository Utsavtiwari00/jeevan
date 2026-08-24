import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';
import 'package:jeevan/features/crop_health/crop_analysis_screen.dart';

void main() {
  testWidgets('CropAnalysisScreen renders analysis details and Scan Crop button from Firebase scan', (tester) async {
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
          home: const CropAnalysisScreen(zoneId: 'zone-a'),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(find.text('Crop Analysis'), findsOneWidget);
    expect(find.text('Early Blight'), findsOneWidget);
    expect(find.text('Crop: Tomato'), findsOneWidget);
    expect(find.text('91.4%'), findsOneWidget);
    expect(find.text('Recommended Action'), findsOneWidget);
    expect(find.text('Scan Crop'), findsOneWidget);
  });
}
