import '../models/rover.dart';
import '../models/rover_mission.dart';

abstract class RoverRepository {
  Future<Rover> getRover(String roverId);
  Future<RoverMission?> getActiveMission(String roverId);
  Future<void> startScan(String roverId);
  Future<void> pauseScan(String roverId);
  Future<void> resumeScan(String roverId);
  Future<void> returnToBase(String roverId);
}
