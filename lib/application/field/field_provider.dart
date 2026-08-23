import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/sensor_reading.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/mock/mock_sensor_repository.dart';

enum MapLayer {
  soilMoisture,
  roverPath,
  waterZones,
  cropHealth,
  scanCoverage,
}

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return MockZoneRepository();
});

final sensorRepositoryProvider = Provider<SensorRepository>((ref) {
  return MockSensorRepository();
});

final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.read(zoneRepositoryProvider);
  return repo.getZones('farm-001');
});

final zoneDetailProvider = FutureProvider.family<Zone, String>((ref, zoneId) async {
  final repo = ref.read(zoneRepositoryProvider);
  return repo.getZone(zoneId);
});

final sensorReadingProvider = FutureProvider.family<SensorReading, String>((ref, zoneId) async {
  final repo = ref.read(sensorRepositoryProvider);
  return repo.getLatestReading(zoneId);
});

final selectedMapLayerProvider = StateProvider<Set<MapLayer>>((ref) {
  return {MapLayer.soilMoisture};
});

final selectedZoneProvider = StateProvider<String?>((ref) => null);

class IrrigationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> triggerIrrigation(String zoneId, int durationMinutes) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(zoneRepositoryProvider);
      await repo.triggerIrrigation(zoneId, durationMinutes: durationMinutes);
      ref.invalidate(zonesProvider);
      ref.invalidate(zoneDetailProvider(zoneId));
    });
  }
}

final irrigationControllerProvider = AsyncNotifierProvider<IrrigationController, void>(() {
  return IrrigationController();
});
