import 'package:jeevan/domain/models/rover.dart';
import 'package:jeevan/domain/repositories/rover_repository.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/core/constants/mock_latency.dart';

class MockRoverRepository implements RoverRepository {
  @override
  Future<Rover> getRover() async {
    await Future.delayed(MockLatency.standard);
    return MockSeedData.rover;
  }
}
