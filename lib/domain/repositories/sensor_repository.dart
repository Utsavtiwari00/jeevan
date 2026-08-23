import '../models/sensor_reading.dart';

abstract class SensorRepository {
  Future<SensorReading> getLatestReading(String zoneId);
  Future<List<SensorReading>> getReadingsForZone(String zoneId, {DateTime? from, DateTime? to});
}
