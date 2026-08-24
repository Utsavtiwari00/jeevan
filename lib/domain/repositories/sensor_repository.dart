import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';

abstract class SensorRepository {
  Future<SensorData> getSensorData();
  Future<TankData> getTankData();
  Stream<SensorData> watchSensorData();
  Stream<TankData> watchTankData();
}
