import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/repositories/zone_repository.dart';
import 'package:jeevan/data/mock/mock_zone_repository.dart';

final zoneRepositoryProvider = Provider<ZoneRepository>((ref) {
  return MockZoneRepository();
});

class DailyWaterUsage {
  final DateTime date;
  final int liters;
  const DailyWaterUsage({required this.date, required this.liters});
}

final waterUsageProvider = FutureProvider<List<DailyWaterUsage>>((ref) async {
  // Mock data since IrrigationEvent and Repository are gone
  return List.generate(7, (index) {
    return DailyWaterUsage(
      date: DateTime.now().subtract(Duration(days: index)),
      liters: 400 + (index * 50) % 300,
    );
  });
});

final irrigationHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  return [
    {'zone': 'A', 'timestamp': 'Today, 08:30', 'waterUsed': 420, 'duration': 14, 'trigger': 'manual'},
    {'zone': 'D', 'timestamp': 'Yesterday, 17:15', 'waterUsed': 480, 'duration': 16, 'trigger': 'automatic'},
    {'zone': 'B', 'timestamp': '3 days ago', 'waterUsed': 350, 'duration': 12, 'trigger': 'automatic'},
  ];
});

final zonesNeedingIrrigationProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  final zones = await repo.getZones();
  return zones.where((z) => z.status == ZoneStatus.irrigationRecommended).toList();
});

final adequateZonesProvider = FutureProvider<List<Zone>>((ref) async {
  final repo = ref.watch(zoneRepositoryProvider);
  final zones = await repo.getZones();
  return zones.where((z) => z.status != ZoneStatus.irrigationRecommended).toList();
});

class IrrigationController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startRecommendedIrrigation(List<String> zoneIds) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(waterUsageProvider);
      ref.invalidate(zonesNeedingIrrigationProvider);
      ref.invalidate(adequateZonesProvider);
    });
  }
}

final irrigationControllerProvider = AsyncNotifierProvider<IrrigationController, void>(() {
  return IrrigationController();
});
