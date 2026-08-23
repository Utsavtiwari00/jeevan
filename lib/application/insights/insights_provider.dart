import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/domain/repositories/irrigation_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';
import 'package:jeevan/data/mock/mock_irrigation_repository.dart';

enum DateRange { today, week, month }

class InsightItem {
  final String title;
  final String explanation;
  final String severity; // e.g., 'info', 'warning', 'critical', 'success'
  final String category; // 'soil', 'water', 'cropHealth', 'rover', 'weather'

  const InsightItem({
    required this.title,
    required this.explanation,
    required this.severity,
    required this.category,
  });
}

class InsightsData {
  final List<InsightItem> soil;
  final List<InsightItem> water;
  final List<InsightItem> cropHealth;
  final List<InsightItem> rover;
  final List<InsightItem> weather;

  const InsightsData({
    required this.soil,
    required this.water,
    required this.cropHealth,
    required this.rover,
    required this.weather,
  });
}

class HistoricalData {
  final double avgMoisture;
  final int totalWaterUsed;
  final int irrigationCount;
  final String tempRange;
  final int rainEvents;

  const HistoricalData({
    required this.avgMoisture,
    required this.totalWaterUsed,
    required this.irrigationCount,
    required this.tempRange,
    required this.rainEvents,
  });
}

// Repositories
final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return MockSensorRepository();
});

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  return MockIrrigationRepository();
});

// State Providers
final selectedDateRangeProvider = StateProvider<DateRange>((ref) => DateRange.week);

// Insights Provider
final insightsProvider = FutureProvider<InsightsData>((ref) async {
  // Simulate network delay
  await Future.delayed(const Duration(milliseconds: 1200));

  return const InsightsData(
    soil: [
      InsightItem(
        title: 'Zone A is drying faster than the rest of the field',
        explanation: 'Moisture has fallen 14% faster than neighboring zones over the past 3 days. This may indicate higher sun exposure or soil drainage differences.',
        severity: 'warning',
        category: 'soil',
      ),
    ],
    water: [
      InsightItem(
        title: 'Water usage is 18% below weekly average',
        explanation: 'You\'ve used 3,620L this week compared to your 4-week average of 4,420L. Rain in Zone C likely contributed to reduced irrigation needs.',
        severity: 'info',
        category: 'water',
      ),
    ],
    cropHealth: [
      InsightItem(
        title: 'Possible early blight detected in Zone A',
        explanation: 'A recent scan identified potential early blight symptoms with 73% confidence. Monitor closely and consider preventive measures.',
        severity: 'warning',
        category: 'cropHealth',
      ),
    ],
    rover: [
      InsightItem(
        title: 'Rover R-01 has completed 3 full scans this week',
        explanation: 'Coverage has been consistent. All four zones have been scanned at least once in the past 48 hours.',
        severity: 'success', // or info, treating as success feel
        category: 'rover',
      ),
    ],
    weather: [
      InsightItem(
        title: 'Light rain expected tomorrow afternoon',
        explanation: 'Based on regional forecasts, light rain is expected between 2-5 PM. Consider delaying irrigation for Zone B until after the rain.',
        severity: 'info',
        category: 'weather',
      ),
    ],
  );
});

// Historical Data Provider
final historicalDataProvider = FutureProvider.family<HistoricalData, DateRange>((ref, range) async {
  await Future.delayed(const Duration(milliseconds: 800));
  
  switch (range) {
    case DateRange.today:
      return const HistoricalData(
        avgMoisture: 42.0,
        totalWaterUsed: 520,
        irrigationCount: 1,
        tempRange: '26°C - 30°C',
        rainEvents: 0,
      );
    case DateRange.week:
      return const HistoricalData(
        avgMoisture: 45.5,
        totalWaterUsed: 3620,
        irrigationCount: 6,
        tempRange: '24°C - 31°C',
        rainEvents: 1,
      );
    case DateRange.month:
      return const HistoricalData(
        avgMoisture: 48.2,
        totalWaterUsed: 14200,
        irrigationCount: 22,
        tempRange: '22°C - 33°C',
        rainEvents: 4,
      );
  }
});
