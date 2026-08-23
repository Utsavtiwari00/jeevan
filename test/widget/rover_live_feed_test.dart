import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/features/rover/rover_overview_screen.dart';
import 'package:jeevan/features/rover/widgets/rover_live_feed.dart';

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

  testWidgets('RoverOverviewScreen includes the live camera feed section', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const RoverOverviewScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Rover Overview'), findsOneWidget);
    expect(find.textContaining('Live Cam'), findsOneWidget);
    expect(find.byType(RoverLiveFeed), findsOneWidget);
  });
}
