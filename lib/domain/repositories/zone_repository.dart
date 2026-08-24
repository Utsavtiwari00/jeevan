import 'package:jeevan/domain/models/zone.dart';

abstract class ZoneRepository {
  Future<List<Zone>> getZones();
  Future<Zone> getZone(String zoneId);
}
