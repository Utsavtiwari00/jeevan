import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/features/crop_health/crop_analysis_screen.dart';

void main() {
  testWidgets('CropAnalysisScreen renders analysis details and Scan Again button without opening camera', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
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
    expect(find.text('Possible Early Blight'), findsOneWidget);
    expect(find.text('73% confidence'), findsOneWidget);
    expect(find.text('Recommended Action'), findsOneWidget);
    expect(find.text('Scan Again'), findsOneWidget);
  });
}
