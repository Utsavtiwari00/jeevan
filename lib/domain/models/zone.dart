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
  final String farmId;
  final String name;
  final List<List<double>> boundaryPoints;
  final String cropType;
  final double currentMoisturePercent;
  final MoistureCategory moistureCategory;
  final ZoneStatus status;

  const Zone({
    required this.id,
    required this.farmId,
    required this.name,
    required this.boundaryPoints,
    required this.cropType,
    required this.currentMoisturePercent,
    required this.moistureCategory,
    required this.status,
  });

  Zone copyWith({
    String? id,
    String? farmId,
    String? name,
    List<List<double>>? boundaryPoints,
    String? cropType,
    double? currentMoisturePercent,
    MoistureCategory? moistureCategory,
    ZoneStatus? status,
  }) {
    return Zone(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      boundaryPoints: boundaryPoints ?? this.boundaryPoints,
      cropType: cropType ?? this.cropType,
      currentMoisturePercent: currentMoisturePercent ?? this.currentMoisturePercent,
      moistureCategory: moistureCategory ?? this.moistureCategory,
      status: status ?? this.status,
    );
  }

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as String,
      farmId: json['farmId'] as String,
      name: json['name'] as String,
      boundaryPoints: (json['boundaryPoints'] as List)
          .map((point) => (point as List).map((e) => (e as num).toDouble()).toList())
          .toList(),
      cropType: json['cropType'] as String,
      currentMoisturePercent: (json['currentMoisturePercent'] as num).toDouble(),
      moistureCategory: MoistureCategory.values.firstWhere(
        (e) => e.name == json['moistureCategory'],
      ),
      status: ZoneStatus.values.firstWhere(
        (e) => e.name == json['status'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'farmId': farmId,
      'name': name,
      'boundaryPoints': boundaryPoints,
      'cropType': cropType,
      'currentMoisturePercent': currentMoisturePercent,
      'moistureCategory': moistureCategory.name,
      'status': status.name,
    };
  }
}
