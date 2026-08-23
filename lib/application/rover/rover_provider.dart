import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/rover_mission.dart';
import 'package:jeevan/domain/repositories/rover_repository.dart';
import 'package:jeevan/data/mock/mock_rover_repository.dart';

final roverRepositoryProvider = Provider<RoverRepository>((ref) {
  return MockRoverRepository();
});

final roverProvider = FutureProvider<Rover>((ref) async {
  final repo = ref.watch(roverRepositoryProvider);
  return repo.getRover('rover-01');
});

final roverMissionProvider = FutureProvider<RoverMission?>((ref) async {
  final repo = ref.watch(roverRepositoryProvider);
  return repo.getActiveMission('rover-01');
});

class RoverController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(roverRepositoryProvider);
      await repo.startScan('rover-01');
      ref.invalidate(roverProvider);
      ref.invalidate(roverMissionProvider);
    });
  }

  Future<void> pauseScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(roverRepositoryProvider);
      await repo.pauseScan('rover-01');
      ref.invalidate(roverProvider);
      ref.invalidate(roverMissionProvider);
    });
  }

  Future<void> resumeScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(roverRepositoryProvider);
      await repo.resumeScan('rover-01');
      ref.invalidate(roverProvider);
      ref.invalidate(roverMissionProvider);
    });
  }

  Future<void> returnToBase() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(roverRepositoryProvider);
      await repo.returnToBase('rover-01');
      ref.invalidate(roverProvider);
      ref.invalidate(roverMissionProvider);
    });
  }
}

final roverControllerProvider = AsyncNotifierProvider<RoverController, void>(() {
  return RoverController();
});
