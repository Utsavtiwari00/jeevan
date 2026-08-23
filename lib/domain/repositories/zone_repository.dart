import '../models/zone.dart';

abstract class ZoneRepository {
  Future<List<Zone>> getZones(String farmId);
  Future<Zone> getZone(String zoneId);
  Future<void> triggerIrrigation(String zoneId, {required int durationMinutes});
}
