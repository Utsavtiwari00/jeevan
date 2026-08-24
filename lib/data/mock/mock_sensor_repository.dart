import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';
import 'package:jeevan/core/constants/mock_latency.dart';

class MockSensorRepository implements SensorRepository {
  @override
  Future<SensorData> getSensorData() async {
    await Future.delayed(MockLatency.standard);
    return MockSeedData.sensorData;
  }

  @override
  Future<TankData> getTankData() async {
    await Future.delayed(MockLatency.standard);
    return MockSeedData.tankData;
  }

  @override
  Stream<SensorData> watchSensorData() {
    return Stream.value(MockSeedData.sensorData);
  }

  @override
  Stream<TankData> watchTankData() {
    return Stream.value(MockSeedData.tankData);
  }
}
