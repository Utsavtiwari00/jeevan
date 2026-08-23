import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockZoneRepository implements ZoneRepository {
  // In-memory state for zones
  final List<Zone> _zones = List.from(MockSeedData.zones);

  @override
  Future<List<Zone>> getZones(String farmId) async {
    await Future.delayed(MockLatency.medium);
    return _zones;
  }

  @override
  Future<Zone> getZone(String zoneId) async {
    await Future.delayed(MockLatency.short);
    return _zones.firstWhere((z) => z.id == zoneId);
  }

  @override
  Future<void> triggerIrrigation(String zoneId, {required int durationMinutes}) async {
    await Future.delayed(MockLatency.long);
    final index = _zones.indexWhere((z) => z.id == zoneId);
    if (index != -1) {
      final zone = _zones[index];
      final newMoisture = (zone.currentMoisturePercent + 20.0).clamp(0.0, 100.0);
      _zones[index] = zone.copyWith(
        currentMoisturePercent: newMoisture,
        status: newMoisture > 75 ? ZoneStatus.noIrrigation : ZoneStatus.monitor,
        moistureCategory: newMoisture > 75 ? MoistureCategory.high : MoistureCategory.medium,
      );
    }
  }
}
