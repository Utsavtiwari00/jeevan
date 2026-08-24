import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';

void main() {
  group('Canonical Mock Seed Data Verification', () {
    test('Zone A to D have exact canonical data', () {
      final zones = MockSeedData.zones;
      expect(zones.length, 4);

      final zoneA = zones.firstWhere((z) => z.id == 'zone-a');
      expect(zoneA.soilMoisture, 22.0);
      expect(zoneA.moistureCategory, MoistureCategory.veryLow);
      expect(zoneA.status, ZoneStatus.irrigationRecommended);
      expect(zoneA.disease, 'Possible Early Blight');
      expect(zoneA.diseaseConfidence, 73.0);

      final zoneB = zones.firstWhere((z) => z.id == 'zone-b');
      expect(zoneB.soilMoisture, 48.0);
      expect(zoneB.moistureCategory, MoistureCategory.medium);
      expect(zoneB.status, ZoneStatus.monitor);
      expect(zoneB.disease, 'none');

      final zoneC = zones.firstWhere((z) => z.id == 'zone-c');
      expect(zoneC.soilMoisture, 81.0);
      expect(zoneC.moistureCategory, MoistureCategory.high);
      expect(zoneC.status, ZoneStatus.noIrrigation);

      final zoneD = zones.firstWhere((z) => z.id == 'zone-d');
      expect(zoneD.soilMoisture, 19.0);
      expect(zoneD.moistureCategory, MoistureCategory.veryLow);
      expect(zoneD.status, ZoneStatus.irrigationRecommended);
    });

    test('Rover R-01 has canonical values', () {
      final rover = MockSeedData.rover;
      expect(rover.id, 'R-01');
      expect(rover.status, RoverStatus.scanning);
      expect(rover.connection, ConnectionStatus.strong);
      expect(rover.currentZone, 'zone-b');
    });

    test('Sensors and Tanks have canonical values', () {
      final sensors = MockSeedData.sensorData;
      expect(sensors.soilMoisture, 42.0);
      expect(sensors.temperature, 28.4);
      expect(sensors.humidity, 54.0);
      expect(sensors.rainStatus, 'NO RAIN');
      expect(sensors.isRaining, isFalse);

      final tanks = MockSeedData.tankData;
      expect(tanks.pesticideLevel, 74.0);
    });

    test('SensorData and TankData parse rover Firebase RTDB payload accurately', () {
      final rawSensors = {
        'humidity': 60.7,
        'rainIntensity': 0,
        'rainStatus': 'NO RAIN',
        'soilMoisture': 0,
        'temperature': 26.4,
      };

      final parsedSensors = SensorData.fromFirebase(rawSensors);
      expect(parsedSensors.humidity, 60.7);
      expect(parsedSensors.rainIntensity, 0.0);
      expect(parsedSensors.rainStatus, 'NO RAIN');
      expect(parsedSensors.isRaining, isFalse);
      expect(parsedSensors.soilMoisture, 0.0);
      expect(parsedSensors.temperature, 26.4);

      final rawTanks = {
        'pesticideLevel': 0,
      };

      final parsedTanks = TankData.fromFirebase(rawTanks);
      expect(parsedTanks.pesticideLevel, 0.0);
    });

    test('SensorData handles rain conditions and boolean legacy data', () {
      final rainingSensors = SensorData.fromFirebase({
        'humidity': 85.2,
        'rainIntensity': 14.5,
        'rainStatus': 'RAIN',
        'soilMoisture': 65.0,
        'temperature': 22.1,
      });
      expect(rainingSensors.isRaining, isTrue);
      expect(rainingSensors.rainStatus, 'RAIN');

      final boolSensors = SensorData.fromFirebase({
        'rainStatus': true,
        'rainIntensity': 5.0,
      });
      expect(boolSensors.isRaining, isTrue);
      expect(boolSensors.rainStatus, 'RAIN');
    });
  });
}

