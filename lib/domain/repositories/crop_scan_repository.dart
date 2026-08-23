import '../models/crop_scan.dart';

abstract class CropScanRepository {
  Future<CropScan?> getLatestScan(String zoneId);
  Future<List<CropScan>> getScansForZone(String zoneId);
  Future<CropScan> submitScan(String zoneId, String imagePath);
}
