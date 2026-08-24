import 'package:jeevan/domain/models/crop_scan_result.dart';

abstract class CropScanRepository {
  /// Watches real-time updates from `trackbot/scan/`.
  Stream<CropScanResult> watchLatestScan();

  /// Gets a one-time snapshot of the latest scan.
  Future<CropScanResult> getLatestScan();

  /// Initiates a new scan request by writing to `trackbot/scan/`.
  Future<String> requestScan();
}
