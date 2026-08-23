class SensorReading {
  final String zoneId;
  final double soilMoisture;
  final double soilTemperature;
  final double airTemperature;
  final double humidity;
  final bool rainDetected;
  final double lightIntensity;
  final double waterLevel;
  final double ph;
  final double ec;
  final double flowRate;
  final DateTime timestamp;

  const SensorReading({
    required this.zoneId,
    required this.soilMoisture,
    required this.soilTemperature,
    required this.airTemperature,
    required this.humidity,
    required this.rainDetected,
    required this.lightIntensity,
    required this.waterLevel,
    required this.ph,
    required this.ec,
    required this.flowRate,
    required this.timestamp,
  });

  SensorReading copyWith({
    String? zoneId,
    double? soilMoisture,
    double? soilTemperature,
    double? airTemperature,
    double? humidity,
    bool? rainDetected,
    double? lightIntensity,
    double? waterLevel,
    double? ph,
    double? ec,
    double? flowRate,
    DateTime? timestamp,
  }) {
    return SensorReading(
      zoneId: zoneId ?? this.zoneId,
      soilMoisture: soilMoisture ?? this.soilMoisture,
      soilTemperature: soilTemperature ?? this.soilTemperature,
      airTemperature: airTemperature ?? this.airTemperature,
      humidity: humidity ?? this.humidity,
      rainDetected: rainDetected ?? this.rainDetected,
      lightIntensity: lightIntensity ?? this.lightIntensity,
      waterLevel: waterLevel ?? this.waterLevel,
      ph: ph ?? this.ph,
      ec: ec ?? this.ec,
      flowRate: flowRate ?? this.flowRate,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  factory SensorReading.fromJson(Map<String, dynamic> json) {
    return SensorReading(
      zoneId: json['zoneId'] as String,
      soilMoisture: (json['soilMoisture'] as num).toDouble(),
      soilTemperature: (json['soilTemperature'] as num).toDouble(),
      airTemperature: (json['airTemperature'] as num).toDouble(),
      humidity: (json['humidity'] as num).toDouble(),
      rainDetected: json['rainDetected'] as bool,
      lightIntensity: (json['lightIntensity'] as num).toDouble(),
      waterLevel: (json['waterLevel'] as num).toDouble(),
      ph: (json['ph'] as num).toDouble(),
      ec: (json['ec'] as num).toDouble(),
      flowRate: (json['flowRate'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'zoneId': zoneId,
      'soilMoisture': soilMoisture,
      'soilTemperature': soilTemperature,
      'airTemperature': airTemperature,
      'humidity': humidity,
      'rainDetected': rainDetected,
      'lightIntensity': lightIntensity,
      'waterLevel': waterLevel,
      'ph': ph,
      'ec': ec,
      'flowRate': flowRate,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
