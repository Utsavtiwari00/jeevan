import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/core/constants/mock_latency.dart';

class MockZoneRepository implements ZoneRepository {
  @override
  Future<List<Zone>> getZones() async {
    await Future.delayed(MockLatency.standard);
    return MockSeedData.zones;
  }

  @override
  Future<Zone> getZone(String zoneId) async {
    await Future.delayed(MockLatency.standard);
    return MockSeedData.zones.firstWhere((z) => z.id == zoneId);
  }
}
