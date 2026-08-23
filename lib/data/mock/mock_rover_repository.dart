import 'package:jeevan/domain/repositories/rover_repository.dart';
import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/models/rover_mission.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockRoverRepository implements RoverRepository {
  Rover _rover = MockSeedData.rover;
  RoverMission? _mission = MockSeedData.activeMission;

  @override
  Future<Rover> getRover(String roverId) async {
    await Future.delayed(MockLatency.short);
    return _rover;
  }

  @override
  Future<RoverMission?> getActiveMission(String roverId) async {
    await Future.delayed(MockLatency.short);
    return _mission;
  }

  @override
  Future<void> startScan(String roverId) async {
    await Future.delayed(MockLatency.medium);
    _rover = _rover.copyWith(status: RoverStatus.scanning);
    if (_mission != null) {
      _mission = _mission!.copyWith(status: MissionStatus.running);
    }
  }

  @override
  Future<void> pauseScan(String roverId) async {
    await Future.delayed(MockLatency.medium);
    _rover = _rover.copyWith(status: RoverStatus.paused);
    if (_mission != null) {
      _mission = _mission!.copyWith(status: MissionStatus.paused);
    }
  }

  @override
  Future<void> resumeScan(String roverId) async {
    await Future.delayed(MockLatency.medium);
    _rover = _rover.copyWith(status: RoverStatus.scanning);
    if (_mission != null) {
      _mission = _mission!.copyWith(status: MissionStatus.running);
    }
  }

  @override
  Future<void> returnToBase(String roverId) async {
    await Future.delayed(MockLatency.medium);
    _rover = _rover.copyWith(status: RoverStatus.returning);
    if (_mission != null) {
      _mission = _mission!.copyWith(status: MissionStatus.completed);
    }
  }
}
