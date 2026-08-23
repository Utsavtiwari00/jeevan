import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/widgets/status/status_badge.dart';
import 'package:jeevan/widgets/alerts/alert_banner.dart';
import 'package:jeevan/widgets/metrics/metric_row.dart';
import 'package:jeevan/widgets/states/empty_state.dart';
import 'package:jeevan/widgets/states/error_state.dart';
import 'package:jeevan/widgets/skeleton/skeleton_loader.dart';

Widget createTestableWidget(Widget child) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(body: child),
  );
}

void main() {
  group('Shared Widgets Tests', () {
    testWidgets('StatusBadge displays label and color for accessibility', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const StatusBadge(
          label: 'Very Low — 22%',
          severity: StatusBadgeSeverity.critical,
        ),
      ));

      expect(find.text('Very Low — 22%'), findsOneWidget);
    });

    testWidgets('AlertBanner displays title, subtitle and severity badge', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        AlertBanner(
          title: 'Irrigation Recommended',
          subtitle: 'Zone A needs water immediately',
          severity: StatusBadgeSeverity.warning,
          actionLabel: 'View field',
          onAction: () {},
        ),
      ));

      expect(find.text('Irrigation Recommended'), findsOneWidget);
      expect(find.text('Zone A needs water immediately'), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('View field'), findsOneWidget);
    });

    testWidgets('MetricRow displays label and value properly', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const MetricRow(
          label: 'Soil Moisture',
          value: '48%',
          unit: 'volumetric',
        ),
      ));

      expect(find.text('Soil Moisture'), findsOneWidget);
      expect(find.text('48%'), findsOneWidget);
      expect(find.text('volumetric'), findsOneWidget);
    });

    testWidgets('EmptyState displays icon, title, message and action', (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(createTestableWidget(
        EmptyState(
          icon: Icons.notifications_none,
          title: 'No Notifications',
          message: 'All caught up for today',
          actionLabel: 'Refresh',
          onAction: () => actionTapped = true,
        ),
      ));

      expect(find.text('No Notifications'), findsOneWidget);
      expect(find.text('All caught up for today'), findsOneWidget);
      expect(find.text('Refresh'), findsOneWidget);

      await tester.tap(find.text('Refresh'));
      expect(actionTapped, isTrue);
    });

    testWidgets('ErrorState displays message and retry button', (tester) async {
      bool retryTapped = false;
      await tester.pumpWidget(createTestableWidget(
        ErrorState(
          message: 'Unable to connect to field telemetry',
          onRetry: () => retryTapped = true,
        ),
      ));

      expect(find.text('Unable to connect to field telemetry'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retryTapped, isTrue);
    });

    testWidgets('SkeletonLoader renders without crash', (tester) async {
      await tester.pumpWidget(createTestableWidget(
        const SkeletonLoader(width: 100, height: 20),
      ));

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });
}
