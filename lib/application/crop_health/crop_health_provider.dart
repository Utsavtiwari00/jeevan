import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/crop_scan.dart';
import 'package:jeevan/domain/repositories/crop_scan_repository.dart';
import 'package:jeevan/data/mock/mock_crop_scan_repository.dart';

enum AnalysisStage {
  idle,
  imageCaptured,
  identifyingPlant,
  examiningLeaves,
  comparingPatterns,
  generatingReport,
  complete,
}

final cropScanRepositoryProvider = Provider<CropScanRepository>((ref) {
  return MockCropScanRepository();
});

final latestCropScanProvider = FutureProvider.family<CropScan?, String>((ref, zoneId) async {
  final repo = ref.read(cropScanRepositoryProvider);
  return repo.getLatestScan(zoneId);
});

final cropScansForZoneProvider = FutureProvider.family<List<CropScan>, String>((ref, zoneId) async {
  final repo = ref.read(cropScanRepositoryProvider);
  return repo.getScansForZone(zoneId);
});

final analysisStageProvider = StateProvider<AnalysisStage>((ref) => AnalysisStage.idle);

class CropAnalysisController extends AsyncNotifier<CropScan?> {
  @override
  Future<CropScan?> build() async {
    return null;
  }

  Future<CropScan?> submitScan(String zoneId, String imagePath) async {
    state = const AsyncLoading();
    ref.read(analysisStageProvider.notifier).state = AnalysisStage.imageCaptured;
    
    final stages = [
      AnalysisStage.identifyingPlant,
      AnalysisStage.examiningLeaves,
      AnalysisStage.comparingPatterns,
      AnalysisStage.generatingReport,
      AnalysisStage.complete,
    ];

    for (final stage in stages) {
      await Future.delayed(const Duration(milliseconds: 800));
      ref.read(analysisStageProvider.notifier).state = stage;
    }

    state = await AsyncValue.guard(() async {
      final repo = ref.read(cropScanRepositoryProvider);
      final scan = await repo.submitScan(zoneId, imagePath);
      ref.invalidate(latestCropScanProvider(zoneId));
      ref.invalidate(cropScansForZoneProvider(zoneId));
      return scan;
    });
    
    return state.value;
  }
}

final cropAnalysisControllerProvider = AsyncNotifierProvider<CropAnalysisController, CropScan?>(() {
  return CropAnalysisController();
});
