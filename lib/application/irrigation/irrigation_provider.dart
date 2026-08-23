import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/irrigation_event.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/repositories/irrigation_repository.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/data/mock/mock_irrigation_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';

final irrigationRepositoryProvider = Provider<IrrigationRepository>((ref) {
  return MockIrrigationRepository();
});

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return MockZoneRepository();
});

final irrigationHistoryProvider = FutureProvider<List<IrrigationEvent>>((ref) async {
  final repo = ref.watch(irrigationRepositoryProvider);
  return repo.getIrrigationHistory();
});

final waterUsageProvider = FutureProvider<List<DailyWaterUsage>>((ref) async {
  final repo = ref.watch(irrigationRepositoryProvider);
  return repo.getWaterUsageByDay(7);
});

final zonesNeedingIrrigationProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  final zones = await repo.getZones('farm-01');
  return zones.where((z) => z.status == ZoneStatus.irrigationRecommended).toList();
});

final adequateZonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  final zones = await repo.getZones('farm-01');
  return zones.where((z) => z.status != ZoneStatus.irrigationRecommended).toList();
});

class IrrigationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startRecommendedIrrigation(List<String> zoneIds) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(irrigationRepositoryProvider);
      await repo.startIrrigation(zoneIds);
      ref.invalidate(irrigationHistoryProvider);
      ref.invalidate(waterUsageProvider);
      ref.invalidate(zonesNeedingIrrigationProvider);
      ref.invalidate(adequateZonesProvider);
    });
  }
}

final irrigationControllerProvider = AsyncNotifierProvider<IrrigationController, void>(() {
  return IrrigationController();
});
