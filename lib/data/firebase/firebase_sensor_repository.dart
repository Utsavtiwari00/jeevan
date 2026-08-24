import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jeevan/domain/models/sensor_data.dart';
import 'package:jeevan/domain/models/tank_data.dart';
import 'package:jeevan/domain/repositories/sensor_repository.dart';
import 'package:jeevan/data/mock/seed/mock_seed_data.dart';

/// Sensor and tank telemetry repository connected to Firebase Realtime Database.
///
/// Listens to live rover feeds on `sensors/` and `tanks/` with automatic
/// fallback to seed data when Firebase is not configured or in unit test mode.
class FirebaseSensorRepository implements SensorRepository {
  final FirebaseDatabase? _database;

  FirebaseSensorRepository([FirebaseDatabase? database])
      : _database = database ?? _tryGetDefaultDatabase();

  static FirebaseDatabase? _tryGetDefaultDatabase() {
    try {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://smart-agriculture-rover-61201-default-rtdb.asia-southeast1.firebasedatabase.app',
      );
    } catch (_) {
      try {
        return FirebaseDatabase.instance;
      } catch (_) {
        return null;
      }
    }
  }

  DatabaseReference? get _sensorsRef {
    try {
      return _database?.ref('sensors');
    } catch (_) {
      return null;
    }
  }

  DatabaseReference? get _tanksRef {
    try {
      return _database?.ref('tanks');
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<SensorData> watchSensorData() {
    try {
      final ref = _sensorsRef;
      if (ref == null) {
        return Stream.value(MockSeedData.sensorData);
      }
      return ref.onValue.map((event) {
        final value = event.snapshot.value;
        if (value is Map) {
          return SensorData.fromFirebase(value);
        }
        return MockSeedData.sensorData;
      }).handleError((error) {
        return MockSeedData.sensorData;
      });
    } catch (_) {
      return Stream.value(MockSeedData.sensorData);
    }
  }

  @override
  Stream<TankData> watchTankData() {
    try {
      final ref = _tanksRef;
      if (ref == null) {
        return Stream.value(MockSeedData.tankData);
      }
      return ref.onValue.map((event) {
        final value = event.snapshot.value;
        if (value is Map) {
          return TankData.fromFirebase(value);
        }
        return MockSeedData.tankData;
      }).handleError((error) {
        return MockSeedData.tankData;
      });
    } catch (_) {
      return Stream.value(MockSeedData.tankData);
    }
  }

  @override
  Future<SensorData> getSensorData() async {
    try {
      final ref = _sensorsRef;
      if (ref == null) return MockSeedData.sensorData;
      final snapshot = await ref.get();
      final value = snapshot.value;
      if (value is Map) {
        return SensorData.fromFirebase(value);
      }
    } catch (_) {}
    return MockSeedData.sensorData;
  }

  @override
  Future<TankData> getTankData() async {
    try {
      final ref = _tanksRef;
      if (ref == null) return MockSeedData.tankData;
      final snapshot = await ref.get();
      final value = snapshot.value;
      if (value is Map) {
        return TankData.fromFirebase(value);
      }
    } catch (_) {}
    return MockSeedData.tankData;
  }
}
