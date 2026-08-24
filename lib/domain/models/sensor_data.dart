/// Global sensor data matching Firebase `sensors/` structure.
///
/// Aggregate readings from the rover's sensors:
/// - humidity: double (%) e.g. 60.7
/// - rainIntensity: double (mm/h) e.g. 0.0
/// - rainStatus: String e.g. "NO RAIN"
/// - soilMoisture: double (%) e.g. 0.0
/// - temperature: double (°C) e.g. 26.4
class SensorData {
  final double soilMoisture;
  final double rainIntensity;
  final String rainStatus;
  final double temperature;
  final double humidity;

  const SensorData({
    required this.soilMoisture,
    required this.rainIntensity,
    required this.rainStatus,
    required this.temperature,
    required this.humidity,
  });

  /// Helper getter to determine if rain is actively occurring
  bool get isRaining {
    final s = rainStatus.trim().toUpperCase();
    return s != 'NO RAIN' &&
        s != 'NONE' &&
        s != 'FALSE' &&
        s != '0' &&
        s.isNotEmpty;
  }

  SensorData copyWith({
    double? soilMoisture,
    double? rainIntensity,
    String? rainStatus,
    double? temperature,
    double? humidity,
  }) {
    return SensorData(
      soilMoisture: soilMoisture ?? this.soilMoisture,
      rainIntensity: rainIntensity ?? this.rainIntensity,
      rainStatus: rainStatus ?? this.rainStatus,
      temperature: temperature ?? this.temperature,
      humidity: humidity ?? this.humidity,
    );
  }

  /// Parse from Firebase Realtime Database snapshot value.
  factory SensorData.fromFirebase(Map<dynamic, dynamic> data) {
    final rawRainStatus = data['rainStatus'];
    String parsedRainStatus;
    if (rawRainStatus is bool) {
      parsedRainStatus = rawRainStatus ? 'RAIN' : 'NO RAIN';
    } else if (rawRainStatus is num) {
      parsedRainStatus = rawRainStatus > 0 ? 'RAIN' : 'NO RAIN';
    } else if (rawRainStatus is String) {
      parsedRainStatus = rawRainStatus.trim();
    } else {
      parsedRainStatus = 'NO RAIN';
    }

    return SensorData(
      soilMoisture: (data['soilMoisture'] as num?)?.toDouble() ?? 0.0,
      rainIntensity: (data['rainIntensity'] as num?)?.toDouble() ?? 0.0,
      rainStatus: parsedRainStatus,
      temperature: (data['temperature'] as num?)?.toDouble() ?? 0.0,
      humidity: (data['humidity'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'soilMoisture': soilMoisture,
      'rainIntensity': rainIntensity,
      'rainStatus': rainStatus,
      'temperature': temperature,
      'humidity': humidity,
    };
  }
}
