import 'package:jeevan/domain/repositories/crop_scan_repository.dart';
import 'package:jeevan/domain/models/crop_scan.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockCropScanRepository implements CropScanRepository {
  final List<CropScan> _scans = List.from(MockSeedData.cropScans);

  
  @override
  Future<CropScan?> getLatestScan(String zoneId) async {
    await Future.delayed(MockLatency.short);
    return _scans.where((s) => s.zoneId == zoneId).firstOrNull;
  }

  @override
  Future<List<CropScan>> getScansForZone(String zoneId) async {
    await Future.delayed(MockLatency.medium);
    return _scans;
  }

  @override
  Future<CropScan> submitScan(String zoneId, String imagePath) async {
    await Future.delayed(MockLatency.long);
    final newScan = CropScan(
      id: 'scan-${DateTime.now().millisecondsSinceEpoch}',
      zoneId: zoneId,
      imageUrl: '',
      diagnosis: 'Healthy - Mock Scan',
      confidencePercent: 88,
      severity: CropSeverity.low,
      observedInPercent: 5,
      indicators: ['Green leaves'],
      timestamp: DateTime.now(),
    );
    _scans.add(newScan);
    return newScan;
  }
}
