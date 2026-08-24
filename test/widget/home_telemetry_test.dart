import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/core/theme/app_theme.dart';
import 'package:jeevan/features/home/home_screen.dart';
import 'package:jeevan/application/home/home_provider.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';

void main() {
  testWidgets('HomeScreen renders Rover Live Telemetry with RTDB sensor values', (tester) async {
    const testSensors = SensorData(
      soilMoisture: 0,
      temperature: 26.4,
      humidity: 60.7,
      rainStatus: 'NO RAIN',
      rainIntensity: 0,
    );

    const testTanks = TankData(
      pesticideLevel: 0,
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          homeSensorDataProvider.overrideWith((ref) => Stream.value(testSensors)),
          homeTankDataProvider.overrideWith((ref) => Stream.value(testTanks)),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      ),
    );

    await tester.pump();
    await tester.pumpAndSettle();

    // Verify Section Header & Live RTDB Badge
    expect(find.text('Rover Live Telemetry'), findsOneWidget);
    expect(find.text('LIVE RTDB'), findsOneWidget);

    // Verify Telemetry Cards matching the rover Firebase values
    expect(find.text('Soil Moisture'), findsOneWidget);
    expect(find.text('0%'), findsNWidgets(2)); // Soil Moisture (0%) and Pesticide Level (0%)

    expect(find.text('Temperature'), findsOneWidget);
    expect(find.text('26.4°C'), findsOneWidget);

    expect(find.text('Air Humidity'), findsOneWidget);
    expect(find.text('60.7%'), findsOneWidget);

    expect(find.text('Rain Status'), findsOneWidget);
    expect(find.text('NO RAIN'), findsOneWidget);

    expect(find.text('Pesticide Level'), findsOneWidget);
    expect(find.text('Trackbot R-01'), findsOneWidget);
  });
}
