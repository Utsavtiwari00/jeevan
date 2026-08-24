import 'package:intl/intl.dart';

/// Status of the crop scanning process in Firebase RTDB (`trackbot/scan/status`).
enum CropScanStatus {
  idle,
  requested,
  processing,
  completed,
  error,
}

/// Represents the crop health scan data stored at `trackbot/scan` in Firebase Realtime Database.
class CropScanResult {
  final String? requestId;
  final CropScanStatus status;
  final int? requestedAt;
  final int? completedAt;
  final String? crop;
  final String? disease;
  final double? confidence;
  final int? classIndex;
  final double? inferenceMs;
  final String? imageUrl;
  final String? rawError;

  const CropScanResult({
    this.requestId,
    this.status = CropScanStatus.idle,
    this.requestedAt,
    this.completedAt,
    this.crop,
    this.disease,
    this.confidence,
    this.classIndex,
    this.inferenceMs,
    this.imageUrl,
    this.rawError,
  });

  const CropScanResult.idle()
      : requestId = null,
        status = CropScanStatus.idle,
        requestedAt = null,
        completedAt = null,
        crop = null,
        disease = null,
        confidence = null,
        classIndex = null,
        inferenceMs = null,
        imageUrl = null,
        rawError = null;

  bool get isIdle => status == CropScanStatus.idle;
  bool get isRequested => status == CropScanStatus.requested;
  bool get isProcessing =>
      status == CropScanStatus.requested || status == CropScanStatus.processing;
  bool get isCompleted => status == CropScanStatus.completed;
  bool get isError => status == CropScanStatus.error;

  /// Whether a disease is detected (excluding healthy/none/empty).
  bool get hasDisease {
    if (disease == null || disease!.isEmpty) return false;
    final lower = disease!.toLowerCase();
    return lower != 'none' &&
        lower != 'healthy' &&
        !lower.contains('healthy') &&
        lower != 'no_disease';
  }

  /// Normalized confidence value as a percentage (0.0 to 100.0).
  double get confidencePercentage {
    if (confidence == null) return 0.0;
    // If stored as 0-1 decimal (e.g. 0.9143), convert to 0-100%
    if (confidence! <= 1.0 && confidence! >= 0.0) {
      return confidence! * 100.0;
    }
    return confidence!;
  }

  /// Human-readable confidence string (e.g., "91.4%").
  String get formattedConfidence {
    if (confidence == null) return 'N/A';
    return '${confidencePercentage.toStringAsFixed(1)}%';
  }

  /// Human-readable formatted crop name (e.g., "Tomato").
  String get formattedCrop {
    final parsed = _parseLabels(crop, disease);
    if (parsed.crop.isNotEmpty) return parsed.crop;
    return 'Unknown Crop';
  }

  /// Human-readable formatted disease name (e.g., "Early Blight" or "Healthy").
  String get formattedDisease {
    final parsed = _parseLabels(crop, disease);
    if (parsed.disease.isNotEmpty) {
      final lower = parsed.disease.toLowerCase();
      if (lower == 'none' || lower == 'healthy' || lower == 'healthy plant') {
        return 'Healthy';
      }
      return parsed.disease;
    }
    if (!hasDisease && isCompleted) return 'Healthy';
    return 'Unknown Diagnosis';
  }

  /// Human-readable inference time (e.g., "350 ms" or "1.25 s").
  String? get formattedInferenceTime {
    if (inferenceMs == null) return null;
    if (inferenceMs! < 1000) {
      return '${inferenceMs!.toStringAsFixed(0)} ms';
    }
    return '${(inferenceMs! / 1000).toStringAsFixed(2)} s';
  }

  /// Human-readable timestamp of the scan.
  String? get formattedTimestamp {
    final ts = completedAt ?? requestedAt;
    if (ts == null) return null;
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(ts);
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      final timeStr = DateFormat('h:mm a').format(dateTime);
      if (diff.inDays == 0 && dateTime.day == now.day) {
        return 'Today at $timeStr';
      } else if (diff.inDays <= 1 && (now.day - dateTime.day == 1)) {
        return 'Yesterday at $timeStr';
      }
      return DateFormat('MMM d, yyyy • h:mm a').format(dateTime);
    } catch (_) {
      return null;
    }
  }

  /// Parses the Firebase Realtime Database snapshot map.
  factory CropScanResult.fromFirebase(Map<dynamic, dynamic>? data) {
    if (data == null || data.isEmpty) {
      return const CropScanResult.idle();
    }

    final rawStatus = data['status']?.toString().toLowerCase().trim();
    CropScanStatus scanStatus;
    switch (rawStatus) {
      case 'requested':
        scanStatus = CropScanStatus.requested;
        break;
      case 'processing':
        scanStatus = CropScanStatus.processing;
        break;
      case 'completed':
        scanStatus = CropScanStatus.completed;
        break;
      case 'error':
        scanStatus = CropScanStatus.error;
        break;
      default:
        if (data['imageUrl'] != null || data['disease'] != null) {
          scanStatus = CropScanStatus.completed;
        } else {
          scanStatus = CropScanStatus.idle;
        }
    }

    // Confidence parsing
    double? parsedConfidence;
    final rawConf = data['confidence'];
    if (rawConf is num) {
      parsedConfidence = rawConf.toDouble();
    } else if (rawConf is String) {
      parsedConfidence = double.tryParse(rawConf);
    }

    // InferenceMs parsing
    double? parsedInferenceMs;
    final rawInf = data['inferenceMs'];
    if (rawInf is num) {
      parsedInferenceMs = rawInf.toDouble();
    } else if (rawInf is String) {
      parsedInferenceMs = double.tryParse(rawInf);
    }

    // ClassIndex parsing
    int? parsedClassIndex;
    final rawIndex = data['classIndex'];
    if (rawIndex is num) {
      parsedClassIndex = rawIndex.toInt();
    } else if (rawIndex is String) {
      parsedClassIndex = int.tryParse(rawIndex);
    }

    // Timestamps parsing
    int? parsedRequestedAt;
    final rawReq = data['requestedAt'];
    if (rawReq is num) {
      parsedRequestedAt = rawReq.toInt();
    } else if (rawReq is String) {
      parsedRequestedAt = int.tryParse(rawReq);
    }

    int? parsedCompletedAt;
    final rawComp = data['completedAt'];
    if (rawComp is num) {
      parsedCompletedAt = rawComp.toInt();
    } else if (rawComp is String) {
      parsedCompletedAt = int.tryParse(rawComp);
    }

    return CropScanResult(
      requestId: data['requestId']?.toString(),
      status: scanStatus,
      requestedAt: parsedRequestedAt,
      completedAt: parsedCompletedAt,
      crop: data['crop']?.toString(),
      disease: data['disease']?.toString(),
      confidence: parsedConfidence,
      classIndex: parsedClassIndex,
      inferenceMs: parsedInferenceMs,
      imageUrl: data['imageUrl']?.toString(),
      rawError: data['error']?.toString() ?? data['message']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestId': requestId,
      'status': status.name,
      'requestedAt': requestedAt,
      'completedAt': completedAt,
      'crop': crop,
      'disease': disease,
      'confidence': confidence,
      'classIndex': classIndex,
      'inferenceMs': inferenceMs,
      'imageUrl': imageUrl,
      if (rawError != null) 'error': rawError,
    };
  }

  CropScanResult copyWith({
    String? requestId,
    CropScanStatus? status,
    int? requestedAt,
    int? completedAt,
    String? crop,
    String? disease,
    double? confidence,
    int? classIndex,
    double? inferenceMs,
    String? imageUrl,
    String? rawError,
  }) {
    return CropScanResult(
      requestId: requestId ?? this.requestId,
      status: status ?? this.status,
      requestedAt: requestedAt ?? this.requestedAt,
      completedAt: completedAt ?? this.completedAt,
      crop: crop ?? this.crop,
      disease: disease ?? this.disease,
      confidence: confidence ?? this.confidence,
      classIndex: classIndex ?? this.classIndex,
      inferenceMs: inferenceMs ?? this.inferenceMs,
      imageUrl: imageUrl ?? this.imageUrl,
      rawError: rawError ?? this.rawError,
    );
  }

  /// Parses composite class names like "Tomato___Early_blight" or separate crop/disease.
  static ({String crop, String disease}) _parseLabels(
      String? rawCrop, String? rawDisease) {
    if (rawCrop != null && rawCrop.contains('___')) {
      final parts = rawCrop.split('___');
      return (
        crop: _formatWord(parts[0]),
        disease: _formatWord(parts.length > 1 ? parts[1] : ''),
      );
    }
    if (rawDisease != null && rawDisease.contains('___')) {
      final parts = rawDisease.split('___');
      return (
        crop: _formatWord(parts[0]),
        disease: _formatWord(parts.length > 1 ? parts[1] : ''),
      );
    }
    return (
      crop: _formatWord(rawCrop ?? ''),
      disease: _formatWord(rawDisease ?? ''),
    );
  }

  static String _formatWord(String text) {
    if (text.isEmpty) return '';
    final cleaned = text.replaceAll('_', ' ').replaceAll('-', ' ').trim();
    if (cleaned.isEmpty) return '';
    return cleaned.split(RegExp(r'\s+')).map((w) {
      if (w.isEmpty) return '';
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
