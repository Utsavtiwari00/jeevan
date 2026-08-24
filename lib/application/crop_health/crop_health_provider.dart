import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/domain/models/zone.dart';
import 'package:jeevan/domain/repositories/crop_scan_repository.dart';
import 'package:jeevan/data/firebase/firebase_crop_scan_repository.dart';
import 'package:jeevan/application/field/field_provider.dart' show zoneRepositoryProvider;

/// Provider for the CropScanRepository accessing Firebase Realtime Database.
final cropScanRepositoryProvider = Provider<CropScanRepository>((ref) {
  return FirebaseCropScanRepository();
});

/// Real-time stream provider listening to `trackbot/scan/` in Firebase RTDB.
final cropScanStreamProvider =
    StreamProvider.autoDispose<CropScanResult>((ref) {
  final repository = ref.watch(cropScanRepositoryProvider);
  return repository.watchLatestScan();
});

/// Controller for initiating new crop scans and managing scan state.
class CropScanController extends StateNotifier<AsyncValue<String?>> {
  final Ref _ref;

  CropScanController(this._ref) : super(const AsyncValue.data(null));

  /// Requests a new crop scan on the Raspberry Pi via Firebase RTDB.
  Future<void> triggerScan() async {
    final currentScan = _ref.read(cropScanStreamProvider).asData?.value;
    if (currentScan != null && currentScan.isProcessing) {
      // Prevent multiple simultaneous scan requests
      return;
    }
    if (state.isLoading) return;

    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(cropScanRepositoryProvider);
      final reqId = await repo.requestScan();
      state = AsyncValue.data(reqId);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }
}

final cropScanControllerProvider =
    StateNotifierProvider<CropScanController, AsyncValue<String?>>((ref) {
  return CropScanController(ref);
});

// --- Legacy / Companion Zone data providers ---
final zoneDiseaseProvider =
    FutureProvider.family<Zone, String>((ref, zoneId) async {
  final repo = ref.read(zoneRepositoryProvider);
  return repo.getZone(zoneId);
});

enum AnalysisStage {
  idle,
  imageCaptured,
  identifyingPlant,
  examiningLeaves,
  comparingPatterns,
  generatingReport,
  complete,
}

final analysisStageProvider =
    StateProvider<AnalysisStage>((ref) => AnalysisStage.idle);

class CropAnalysisController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> submitScan(String zoneId, String imagePath) async {
    state = const AsyncLoading();
    try {
      await ref.read(cropScanControllerProvider.notifier).triggerScan();
    } catch (_) {}
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
      ref.invalidate(zoneDiseaseProvider(zoneId));
    });
  }
}

final cropAnalysisControllerProvider =
    AsyncNotifierProvider<CropAnalysisController, void>(() {
  return CropAnalysisController();
});
