import 'package:jeevan/domain/repositories/farm_repository.dart';
import 'package:jeevan/domain/models/farm.dart';
import 'package:jeevan/core/constants/mock_latency.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

class MockFarmRepository implements FarmRepository {
  @override
  Future<Farm> getFarm(String farmId) async {
    await Future.delayed(MockLatency.medium);
    return MockSeedData.farm;
  }
}
