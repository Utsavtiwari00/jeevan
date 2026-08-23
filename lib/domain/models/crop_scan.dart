enum CropSeverity { low, moderate, high }

class CropScan {
  final String id;
  final String zoneId;
  final String imageUrl;
  final String diagnosis;
  final double confidencePercent;
  final CropSeverity severity;
  final double observedInPercent;
  final List<String> indicators;
  final DateTime timestamp;

  const CropScan({
    required this.id,
    required this.zoneId,
    required this.imageUrl,
    required this.diagnosis,
    required this.confidencePercent,
    required this.severity,
    required this.observedInPercent,
    required this.indicators,
    required this.timestamp,
  });

  /// Convenience aliases for backward compatibility and alternate naming
  double get confidence => confidencePercent;
  double get observedAreaPercent => observedInPercent;

  CropScan copyWith({
    String? id,
    String? zoneId,
    String? imageUrl,
    String? diagnosis,
    double? confidencePercent,
    CropSeverity? severity,
    double? observedInPercent,
    List<String>? indicators,
    DateTime? timestamp,
  }) {
    return CropScan(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      imageUrl: imageUrl ?? this.imageUrl,
      diagnosis: diagnosis ?? this.diagnosis,
      confidencePercent: confidencePercent ?? this.confidencePercent,
      severity: severity ?? this.severity,
      observedInPercent: observedInPercent ?? this.observedInPercent,
      indicators: indicators ?? this.indicators,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory CropScan.fromJson(Map<String, dynamic> json) {
    return CropScan(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      imageUrl: json['imageUrl'] as String,
      diagnosis: json['diagnosis'] as String,
      confidencePercent: (json['confidencePercent'] as num).toDouble(),
      severity: CropSeverity.values.firstWhere((e) => e.name == json['severity']),
      observedInPercent: (json['observedInPercent'] as num).toDouble(),
      indicators: (json['indicators'] as List).cast<String>(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'imageUrl': imageUrl,
      'diagnosis': diagnosis,
      'confidencePercent': confidencePercent,
      'severity': severity.name,
      'observedInPercent': observedInPercent,
      'indicators': indicators,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
