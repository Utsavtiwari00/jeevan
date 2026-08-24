import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/firebase/firebase_sensor_repository.dart';

class AlertData {
  final String title;
  final String subtitle;
  final String severity;
  final String actionRoute;

  const AlertData({
    required this.title,
    required this.subtitle,
    required this.severity,
    required this.actionRoute,
  });
}

class FarmOverview {
  final double totalAcreage;
  final int activeZones;
  final double averageMoisture;
  final double waterUsedToday;

  const FarmOverview({
    required this.totalAcreage,
    required this.activeZones,
    required this.averageMoisture,
    required this.waterUsedToday,
  });
}

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return MockZoneRepository();
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return FirebaseSensorRepository();
});

final homeSensorDataProvider = StreamProvider<SensorData>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchSensorData();
});

final homeTankDataProvider = StreamProvider<TankData>((ref) {
  final repo = ref.watch(sensorRepositoryProvider);
  return repo.watchTankData();
});

final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  return repo.getZones();
});

final homeAlertsProvider = FutureProvider<List<AlertData>>((ref) async {
  final zones = await ref.watch(zonesProvider.future);
  final List<AlertData> alerts = [];

  final lowMoistureZones = <String>[];

  for (final zone in zones) {
    if (zone.status == ZoneStatus.irrigationRecommended) {
      lowMoistureZones.add(zone.name);
    }
    if (zone.hasDiseaseDetected) {
      alerts.add(AlertData(
        title: 'Crop Health Alert',
        subtitle: '${zone.disease} detected in ${zone.name} (${zone.diseaseConfidence}% confidence)',
        severity: 'critical',
        actionRoute: '/field/zone/${zone.id}/crop-analysis',
      ));
    }
  }

  if (lowMoistureZones.isNotEmpty) {
    alerts.add(AlertData(
      title: 'Irrigation Recommended',
      subtitle: '${lowMoistureZones.join(' and ')} need water — soil moisture is critically low',
      severity: 'warning',
      actionRoute: '/field',
    ));
  }

  alerts.add(const AlertData(
    title: 'Rain Detected Earlier',
    subtitle: 'Light rain detected in Zone C — consider delaying irrigation',
    severity: 'info',
    actionRoute: '/field',
  ));

  return alerts;
});

final farmOverviewProvider = FutureProvider<FarmOverview>((ref) async {
  final zones = await ref.watch(zonesProvider.future);
  
  double totalMoisture = 0;
  for (final zone in zones) {
    totalMoisture += zone.soilMoisture;
  }
  
  final averageMoisture = zones.isEmpty ? 0.0 : totalMoisture / zones.length;
  
  return FarmOverview(
    totalAcreage: 12.4,
    activeZones: zones.length,
    averageMoisture: averageMoisture,
    waterUsedToday: 420.5,
  );
});
