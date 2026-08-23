import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/rover.dart';

void main() {
  group('Canonical Mock Seed Data Verification', () {
    test('Farm has canonical values', () {
      final farm = MockSeedData.farm;
      expect(farm.name, 'Green Valley Farm');
      expect(farm.areaAcres, 12.4);
      expect(farm.zoneCount, 4);
      expect(farm.roverConnected, true);
    });

    test('Zone A to D have exact canonical data', () {
      final zones = MockSeedData.zones;
      expect(zones.length, 4);

      final zoneA = zones.firstWhere((z) => z.id == 'zone-a');
      expect(zoneA.currentMoisturePercent, 22.0);
      expect(zoneA.moistureCategory, MoistureCategory.veryLow);
      expect(zoneA.status, ZoneStatus.irrigationRecommended);
      expect(zoneA.cropType, 'Wheat');

      final zoneB = zones.firstWhere((z) => z.id == 'zone-b');
      expect(zoneB.currentMoisturePercent, 48.0);
      expect(zoneB.moistureCategory, MoistureCategory.medium);
      expect(zoneB.status, ZoneStatus.monitor);
      expect(zoneB.cropType, 'Rice');

      final zoneC = zones.firstWhere((z) => z.id == 'zone-c');
      expect(zoneC.currentMoisturePercent, 81.0);
      expect(zoneC.moistureCategory, MoistureCategory.high);
      expect(zoneC.status, ZoneStatus.noIrrigation);
      expect(zoneC.cropType, 'Sugarcane');

      final zoneD = zones.firstWhere((z) => z.id == 'zone-d');
      expect(zoneD.currentMoisturePercent, 19.0);
      expect(zoneD.moistureCategory, MoistureCategory.veryLow);
      expect(zoneD.status, ZoneStatus.irrigationRecommended);
      expect(zoneD.cropType, 'Cotton');
    });

    test('Rover R-01 has canonical values', () {
      final rover = MockSeedData.rover;
      expect(rover.id, 'rover-01');
      expect(rover.batteryPercent, 78.0);
      expect(rover.status, RoverStatus.scanning);
      expect(rover.connectionStatus, ConnectionStatus.strong);
    });
  });
}
