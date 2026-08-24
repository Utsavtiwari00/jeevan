import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';
import 'package:jeevan/domain/repositories/crop_scan_repository.dart';

class FirebaseCropScanRepository implements CropScanRepository {
  final FirebaseDatabase _database;

  FirebaseCropScanRepository([FirebaseDatabase? database])
      : _database = database ?? _getDefaultDatabase();

  static FirebaseDatabase _getDefaultDatabase() {
    try {
      return FirebaseDatabase.instanceFor(
        app: Firebase.app(),
        databaseURL:
            'https://smart-agriculture-rover-61201-default-rtdb.asia-southeast1.firebasedatabase.app',
      );
    } catch (_) {
      return FirebaseDatabase.instance;
    }
  }

  DatabaseReference get _scanRef => _database.ref('trackbot/scan');

  @override
  Stream<CropScanResult> watchLatestScan() {
    return _scanRef.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) {
        return const CropScanResult.idle();
      }
      if (value is Map) {
        return CropScanResult.fromFirebase(value);
      }
      return const CropScanResult.idle();
    }).handleError((error) {
      return CropScanResult(
        status: CropScanStatus.error,
        rawError: error.toString(),
      );
    });
  }

  @override
  Future<CropScanResult> getLatestScan() async {
    final snapshot = await _scanRef.get();
    final value = snapshot.value;
    if (value is Map) {
      return CropScanResult.fromFirebase(value);
    }
    return const CropScanResult.idle();
  }

  @override
  Future<String> requestScan() async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final requestId = 'scan_$timestamp';

    // Update trackbot/scan with request payload
    await _scanRef.update({
      'requestId': requestId,
      'status': 'requested',
      'requestedAt': timestamp,
    });

    return requestId;
  }
}
