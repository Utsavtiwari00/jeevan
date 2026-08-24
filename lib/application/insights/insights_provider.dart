import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';
import 'package:jeevan/application/crop_health/crop_health_provider.dart';

enum DateRange { today, week, month }

class InsightItem {
  final String title;
  final String explanation;
  final String severity; // 'info', 'warning', 'critical', 'success'
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

// State Providers
final selectedDateRangeProvider =
    StateProvider<DateRange>((ref) => DateRange.week);

// Dynamic Insights Provider incorporating live scan data
final insightsProvider = FutureProvider<InsightsData>((ref) async {
  final scanAsync = ref.watch(cropScanStreamProvider);
  final scan = scanAsync.asData?.value;

  final List<InsightItem> cropHealthInsights = [];

  if (scan != null && scan.isCompleted) {
    if (scan.hasDisease) {
      cropHealthInsights.add(
        InsightItem(
          title: '${scan.formattedDisease} detected on ${scan.formattedCrop}',
          explanation:
              'Trackbot camera AI identified ${scan.formattedDisease} with ${scan.formattedConfidence} confidence. Immediate organic or copper-based fungicide spray recommended.',
          severity: scan.confidencePercentage > 75 ? 'critical' : 'warning',
          category: 'cropHealth',
        ),
      );
    } else {
      cropHealthInsights.add(
        InsightItem(
          title: 'Healthy ${scan.formattedCrop} verified by Trackbot',
          explanation:
              'Latest camera scan confirmed clear foliage with ${scan.formattedConfidence} confidence. No pathogen markers found.',
          severity: 'success',
          category: 'cropHealth',
        ),
      );
    }
  } else {
    cropHealthInsights.add(
      const InsightItem(
        title: 'Ready for Rover crop scan',
        explanation:
            'Trigger a scan from the Rover Cam tab to evaluate real-time plant health and disease indicators.',
        severity: 'info',
        category: 'cropHealth',
      ),
    );
  }

  return InsightsData(
    soil: const [
      InsightItem(
        title: 'Zone A is drying faster than the rest of the field',
        explanation:
            'Moisture has fallen 14% faster than neighboring zones over the past 3 days. This may indicate higher sun exposure or soil drainage differences.',
        severity: 'warning',
        category: 'soil',
      ),
    ],
    water: const [
      InsightItem(
        title: 'Water usage is 18% below weekly average',
        explanation:
            'You have used 3,620L this week compared to your 4-week average of 4,420L. Rain in Zone C contributed to reduced irrigation needs.',
        severity: 'info',
        category: 'water',
      ),
    ],
    cropHealth: cropHealthInsights,
    rover: const [
      InsightItem(
        title: 'Trackbot camera connected and streaming',
        explanation:
            'MediaMTX WebRTC stream is operational at /cam/whep. Ready for automated plant inspections.',
        severity: 'success',
        category: 'rover',
      ),
    ],
    weather: const [
      InsightItem(
        title: 'Light rain expected tomorrow afternoon',
        explanation:
            'Based on regional forecasts, light rain is expected between 2-5 PM. Consider delaying irrigation for Zone B until after the rain.',
        severity: 'info',
        category: 'weather',
      ),
    ],
  );
});

// Historical Data Provider
final historicalDataProvider =
    FutureProvider.family<HistoricalData, DateRange>((ref, range) async {
  await Future.delayed(const Duration(milliseconds: 400));

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
