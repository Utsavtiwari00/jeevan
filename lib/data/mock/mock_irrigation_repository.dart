import 'package:jeevan/domain/repositories/irrigation_repository.dart';
import 'package:jeevan/domain/models/irrigation_event.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockIrrigationRepository implements IrrigationRepository {
  final List<IrrigationEvent> _history = List.from(MockSeedData.irrigationHistory);

  @override
  Future<List<IrrigationEvent>> getIrrigationHistory({DateTime? from, DateTime? to}) async {
    await Future.delayed(MockLatency.medium);
    return _history;
  }

  @override
  Future<List<DailyWaterUsage>> getWaterUsageByDay(int days) async {
    await Future.delayed(MockLatency.short);
    // Mocking the daily water usage
    return List.generate(days, (index) {
      final date = DateTime.now().subtract(Duration(days: index));
      return DailyWaterUsage(
        date: date,
        liters: index == 0 ? 0 : 850.0 - (index * 50) % 300,
        zoneBreakdown: {'zone-a': 200, 'zone-b': 300},
      );
    });
  }

  @override
  Future<void> startIrrigation(List<String> zoneIds) async {
    await Future.delayed(MockLatency.medium);
    for (final zoneId in zoneIds) {
      final event = IrrigationEvent(
        id: 'irr-${DateTime.now().millisecondsSinceEpoch}-$zoneId',
        zoneId: zoneId,
        waterUsedLiters: 450.0,
        triggeredBy: TriggerType.manual,
        durationMinutes: 30,
        timestamp: DateTime.now(),
      );
      _history.add(event);
    }
  }
}
