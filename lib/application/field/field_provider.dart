import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';
import 'package:jeevan/data/firebase/firebase_sensor_repository.dart';

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
  return FirebaseSensorRepository();
});

final zonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.read(zoneRepositoryProvider);
  return repo.getZones();
});

final zoneDetailProvider = FutureProvider.family<Zone, String>((ref, zoneId) async {
  final repo = ref.read(zoneRepositoryProvider);
  return repo.getZone(zoneId);
});

final sensorDataProvider = FutureProvider<SensorData>((ref) async {
  final repo = ref.read(sensorRepositoryProvider);
  return repo.getSensorData();
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
      // With the new architecture, irrigation triggers are simplified.
      // We don't have a dedicated triggerIrrigation mock right now, 
      // but we maintain the controller signature for the UI.
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(zonesProvider);
      ref.invalidate(zoneDetailProvider(zoneId));
    });
  }
}

final irrigationControllerProvider = AsyncNotifierProvider<IrrigationController, void>(() {
  return IrrigationController();
});
