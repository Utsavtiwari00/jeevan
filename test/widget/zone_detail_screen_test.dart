import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/features/field/zone_detail_screen.dart';

void main() {
  testWidgets('ZoneDetailScreen renders zone details and crop health without crash', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const ZoneDetailScreen(zoneId: 'zone-a'),
        ),
      ),
    );

    // Initial load frame
    await tester.pump();
    // Allow mock latency (short=400ms) to resolve
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify Zone A details are rendered
    expect(find.text('Zone A'), findsOneWidget);
    expect(find.text('Wheat'), findsOneWidget);
    expect(find.text('Sensor Readings'), findsOneWidget);
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('Crop Health'), findsOneWidget);
    expect(find.text('Possible Early Blight'), findsOneWidget);
    expect(find.text('Confidence: 73%'), findsOneWidget);
    expect(find.text('View analysis'), findsOneWidget);
  });
}
