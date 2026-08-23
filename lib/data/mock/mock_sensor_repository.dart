import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/domain/models/sensor_reading.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockSensorRepository implements SensorRepository {
  @override
  Future<SensorReading> getLatestReading(String zoneId) async {
    await Future.delayed(MockLatency.short);
    return MockSeedData.sensorReadings[zoneId] ?? MockSeedData.sensorReadings.values.first;
  }

  @override
  Future<List<SensorReading>> getReadingsForZone(String zoneId, {DateTime? from, DateTime? to}) async {
    await Future.delayed(MockLatency.medium);
    final baseReading = MockSeedData.sensorReadings[zoneId] ?? MockSeedData.sensorReadings.values.first;
    List<SensorReading> timeSeries = [];
    
    DateTime current = from ?? DateTime.now().subtract(const Duration(days: 1));
    final endDate = to ?? DateTime.now();
    double drift = 0;
    while (current.isBefore(endDate)) {
      timeSeries.add(baseReading.copyWith(
        timestamp: current,
        soilMoisture: (baseReading.soilMoisture + drift).clamp(0, 100).toDouble(),
        soilTemperature: baseReading.soilTemperature + (drift * 0.1),
      ));
      current = current.add(const Duration(hours: 1));
      drift += (current.hour % 2 == 0 ? 0.5 : -0.2); // Simple predictable drift
    }
    return timeSeries;
  }
}
