import 'package:flutter_test/flutter_test.dart';
import 'package:jeevan/domain/models/crop_scan_result.dart';

void main() {
  group('CropScanResult unit tests', () {
    test('parses completed Firebase data map with decimal confidence', () {
      final data = {
        'requestId': 'test001',
        'status': 'completed',
        'crop': 'Tomato',
        'disease': 'Early_blight',
        'confidence': 0.9143,
        'classIndex': 30,
        'inferenceMs': 350.21,
        'imageUrl': 'https://res.cloudinary.com/djmtbyhos/image/upload/sample.jpg',
        'completedAt': 1755940000000,
        'requestedAt': 1755939999000,
      };

      final result = CropScanResult.fromFirebase(data);

      expect(result.requestId, 'test001');
      expect(result.status, CropScanStatus.completed);
      expect(result.isCompleted, isTrue);
      expect(result.isProcessing, isFalse);
      expect(result.crop, 'Tomato');
      expect(result.disease, 'Early_blight');
      expect(result.formattedCrop, 'Tomato');
      expect(result.formattedDisease, 'Early Blight');
      expect(result.confidencePercentage, closeTo(91.43, 0.01));
      expect(result.formattedConfidence, '91.4%');
      expect(result.classIndex, 30);
      expect(result.inferenceMs, 350.21);
      expect(result.formattedInferenceTime, '350 ms');
      expect(result.imageUrl, 'https://res.cloudinary.com/djmtbyhos/image/upload/sample.jpg');
      expect(result.hasDisease, isTrue);
    });

    test('handles composite label format Tomato___Early_blight', () {
      final data = {
        'requestId': 'test002',
        'status': 'completed',
        'crop': 'Tomato___Early_blight',
        'confidence': 95.5, // 0-100 scale test
      };

      final result = CropScanResult.fromFirebase(data);
      expect(result.formattedCrop, 'Tomato');
      expect(result.formattedDisease, 'Early Blight');
      expect(result.confidencePercentage, 95.5);
      expect(result.formattedConfidence, '95.5%');
    });

    test('handles healthy plant labels without showing disease alert', () {
      final data = {
        'status': 'completed',
        'crop': 'Potato',
        'disease': 'healthy',
        'confidence': 0.98,
      };

      final result = CropScanResult.fromFirebase(data);
      expect(result.hasDisease, isFalse);
      expect(result.formattedDisease, 'Healthy');
    });

    test('handles idle / empty data safely', () {
      final result = CropScanResult.fromFirebase(null);
      expect(result.isIdle, isTrue);
      expect(result.isProcessing, isFalse);
      expect(result.isCompleted, isFalse);
      expect(result.confidencePercentage, 0.0);
      expect(result.formattedConfidence, 'N/A');
    });

    test('handles requested and processing statuses', () {
      final reqResult = CropScanResult.fromFirebase({
        'requestId': 'req123',
        'status': 'requested',
        'requestedAt': 1755940000000,
      });
      expect(reqResult.isRequested, isTrue);
      expect(reqResult.isProcessing, isTrue);
      expect(reqResult.isCompleted, isFalse);

      final procResult = CropScanResult.fromFirebase({
        'requestId': 'req123',
        'status': 'processing',
        'requestedAt': 1755940000000,
      });
      expect(procResult.isProcessing, isTrue);
      expect(procResult.isCompleted, isFalse);
    });

    test('handles error status with error message', () {
      final errResult = CropScanResult.fromFirebase({
        'requestId': 'err123',
        'status': 'error',
        'error': 'Camera capture timed out on Pi',
      });
      expect(errResult.isError, isTrue);
      expect(errResult.rawError, 'Camera capture timed out on Pi');
    });
  });
}
