import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/farm.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/repositories/farm_repository.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/mock_farm_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';

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

final farmRepositoryProvider = Provider<FarmRepository>((ref) {
  return MockFarmRepository();
});

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return MockZoneRepository();
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return MockSensorRepository();
});

final farmProvider = FutureProvider<Farm>((ref) async {
  final repo = ref.watch(farmRepositoryProvider);
  return repo.getFarm('farm-001');
});

final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  return repo.getZones('farm-001');
});

final homeAlertsProvider = FutureProvider<List<AlertData>>((ref) async {
  final zones = await ref.watch(zonesProvider.future);
  final List<AlertData> alerts = [];

  final lowMoistureZones = <String>[];

  for (final zone in zones) {
    if (zone.status == ZoneStatus.irrigationRecommended) {
      lowMoistureZones.add(zone.name);
    }
    if (zone.name == 'Zone A') {
      alerts.add(const AlertData(
        title: 'Crop Health Alert',
        subtitle: 'Possible early blight detected in Zone A (73% confidence)',
        severity: 'critical',
        actionRoute: '/field/zone/zone-a/crop-analysis',
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
  final farm = await ref.watch(farmProvider.future);
  final zones = await ref.watch(zonesProvider.future);
  
  double totalMoisture = 0;
  for (final zone in zones) {
    totalMoisture += zone.currentMoisturePercent;
  }
  
  final averageMoisture = zones.isEmpty ? 0.0 : totalMoisture / zones.length;
  
  return FarmOverview(
    totalAcreage: farm.areaAcres,
    activeZones: farm.zoneCount,
    averageMoisture: averageMoisture,
    waterUsedToday: 420.5,
  );
});
