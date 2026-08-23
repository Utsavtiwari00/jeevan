enum TriggerType { manual, automatic }

class IrrigationEvent {
  final String id;
  final String zoneId;
  final int durationMinutes;
  final double waterUsedLiters;
  final DateTime timestamp;
  final TriggerType triggeredBy;

  const IrrigationEvent({
    required this.id,
    required this.zoneId,
    required this.durationMinutes,
    required this.waterUsedLiters,
    required this.timestamp,
    required this.triggeredBy,
  });

  IrrigationEvent copyWith({
    String? id,
    String? zoneId,
    int? durationMinutes,
    double? waterUsedLiters,
    DateTime? timestamp,
    TriggerType? triggeredBy,
  }) {
    return IrrigationEvent(
      id: id ?? this.id,
      zoneId: zoneId ?? this.zoneId,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      waterUsedLiters: waterUsedLiters ?? this.waterUsedLiters,
      timestamp: timestamp ?? this.timestamp,
      triggeredBy: triggeredBy ?? this.triggeredBy,
    );
  }

  factory IrrigationEvent.fromJson(Map<String, dynamic> json) {
    return IrrigationEvent(
      id: json['id'] as String,
      zoneId: json['zoneId'] as String,
      durationMinutes: json['durationMinutes'] as int,
      waterUsedLiters: (json['waterUsedLiters'] as num).toDouble(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      triggeredBy: TriggerType.values.firstWhere((e) => e.name == json['triggeredBy']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'zoneId': zoneId,
      'durationMinutes': durationMinutes,
      'waterUsedLiters': waterUsedLiters,
      'timestamp': timestamp.toIso8601String(),
      'triggeredBy': triggeredBy.name,
    };
  }
}
