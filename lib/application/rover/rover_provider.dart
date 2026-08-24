import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/repositories/rover_repository.dart';
import 'package:jeevan/data/mock/mock_rover_repository.dart';

final roverRepositoryProvider = Provider<RoverRepository>((ref) {
  return MockRoverRepository();
});

final roverProvider = FutureProvider<Rover>((ref) async {
  final repo = ref.watch(roverRepositoryProvider);
  return repo.getRover();
});

class RoverController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> startScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(roverProvider);
    });
  }

  Future<void> pauseScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(roverProvider);
    });
  }

  Future<void> resumeScan() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(roverProvider);
    });
  }

  Future<void> returnToBase() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await Future.delayed(const Duration(seconds: 1));
      ref.invalidate(roverProvider);
    });
  }
}

final roverControllerProvider = AsyncNotifierProvider<RoverController, void>(() {
  return RoverController();
});
