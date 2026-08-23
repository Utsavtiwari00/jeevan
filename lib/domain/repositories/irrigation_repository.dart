import '../models/irrigation_event.dart';

class DailyWaterUsage {
  final DateTime date;
  final double liters;
  final Map<String, double> zoneBreakdown;

  const DailyWaterUsage({
    required this.date,
    required this.liters,
    required this.zoneBreakdown,
  });
}

abstract class IrrigationRepository {
  Future<List<IrrigationEvent>> getIrrigationHistory({DateTime? from, DateTime? to});
  Future<List<DailyWaterUsage>> getWaterUsageByDay(int days);
  Future<void> startIrrigation(List<String> zoneIds);
}
