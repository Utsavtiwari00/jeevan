/// Simplified Zone model matching Firebase `zones/{zone-id}` structure.
///
/// Disease and sensor data are embedded directly in the zone node.
/// `moistureCategory` and `status` are derived from `soilMoisture`.
enum MoistureCategory { veryLow, low, medium, high }

extension MoistureCategoryExtension on MoistureCategory {
  String get label {
    switch (this) {
      case MoistureCategory.veryLow:
        return 'Very Low';
      case MoistureCategory.low:
        return 'Low';
      case MoistureCategory.medium:
        return 'Medium';
      case MoistureCategory.high:
        return 'High';
    }
  }
}

enum ZoneStatus { irrigationRecommended, monitor, noIrrigation }

extension ZoneStatusExtension on ZoneStatus {
  String get label {
    switch (this) {
      case ZoneStatus.irrigationRecommended:
        return 'Irrigation recommended';
      case ZoneStatus.monitor:
        return 'Monitor';
      case ZoneStatus.noIrrigation:
        return 'No irrigation';
    }
  }
}

class Zone {
  final String id;
  final String name;
  final double soilMoisture;
  final double rainIntensity;
  final double temperature;
  final double humidity;
  final String disease;
  final double diseaseConfidence;

  /// Boundary points kept for field map rendering (from local seed data, not Firebase).
  final List<List<double>> boundaryPoints;

  const Zone({
    required this.id,
    required this.name,
    required this.soilMoisture,
    required this.rainIntensity,
    required this.temperature,
    required this.humidity,
    required this.disease,
    required this.diseaseConfidence,
    this.boundaryPoints = const [],
  });

  /// Derived from soilMoisture percentage.
  MoistureCategory get moistureCategory {
    if (soilMoisture < 25) return MoistureCategory.veryLow;
    if (soilMoisture < 45) return MoistureCategory.low;
    if (soilMoisture < 70) return MoistureCategory.medium;
    return MoistureCategory.high;
  }

  /// Derived from soilMoisture and rain.
  ZoneStatus get status {
    if (soilMoisture >= 70) return ZoneStatus.noIrrigation;
    if (soilMoisture < 30 && rainIntensity == 0) {
      return ZoneStatus.irrigationRecommended;
    }
    return ZoneStatus.monitor;
  }

  /// Whether a disease has been detected (not "none").
  bool get hasDiseaseDetected =>
      disease.isNotEmpty &&
      disease.toLowerCase() != 'none' &&
      disease.toLowerCase() != 'healthy';

  Zone copyWith({
    String? id,
    String? name,
    double? soilMoisture,
    double? rainIntensity,
    double? temperature,
    double? humidity,
    String? disease,
    double? diseaseConfidence,
    List<List<double>>? boundaryPoints,
  }) {
    return Zone(
      id: id ?? this.id,
      name: name ?? this.name,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      rainIntensity: rainIntensity ?? this.rainIntensity,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
      disease: disease ?? this.disease,
      diseaseConfidence: diseaseConfidence ?? this.diseaseConfidence,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
    );
  }

  /// Parse from Firebase Realtime Database snapshot value.
  factory Zone.fromFirebase(String id, Map<dynamic, dynamic> data) {
    return Zone(
      id: id,
      name: _formatZoneName(id),
      soilMoisture: (data['soilMoisture'] as num?)?.toDouble() ?? 0,
      rainIntensity: (data['rainIntensity'] as num?)?.toDouble() ?? 0,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0,
      disease: (data['disease'] as String?) ?? 'none',
      diseaseConfidence:
          (data['diseaseConfidence'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soilMoisture': soilMoisture,
      'rainIntensity': rainIntensity,
      'temperature': temperature,
      'humidity': humidity,
      'disease': disease,
      'diseaseConfidence': diseaseConfidence,
    };
  }

  static String _formatZoneName(String id) {
    // "zone-a" → "Zone A"
    final parts = id.split('-');
    if (parts.length == 2) {
      return 'Zone ${parts[1].toUpperCase()}';
    }
    return id;
  }
}
