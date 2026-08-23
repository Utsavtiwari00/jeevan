class MissionActivityEntry {
  final DateTime timestamp;
  final String label;

  const MissionActivityEntry({
    required this.timestamp,
    required this.label,
  });

  factory MissionActivityEntry.fromJson(Map<String, dynamic> json) {
    return MissionActivityEntry(
      timestamp: DateTime.parse(json['timestamp'] as String),
      label: json['label'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'label': label,
    };
  }
}

enum MissionStatus { running, paused, completed }

class RoverMission {
  final String id;
  final String name;
  final MissionStatus status;
  final DateTime startedAt;
  final double coveragePercent;
  final List<String> zoneSequence;
  final String currentZoneId;
  final List<MissionActivityEntry> activityLog;

  const RoverMission({
    required this.id,
    required this.name,
    required this.status,
    required this.startedAt,
    required this.coveragePercent,
    required this.zoneSequence,
    required this.currentZoneId,
    required this.activityLog,
  });

  RoverMission copyWith({
    String? id,
    String? name,
    MissionStatus? status,
    DateTime? startedAt,
    double? coveragePercent,
    List<String>? zoneSequence,
    String? currentZoneId,
    List<MissionActivityEntry>? activityLog,
  }) {
    return RoverMission(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      coveragePercent: coveragePercent ?? this.coveragePercent,
      zoneSequence: zoneSequence ?? this.zoneSequence,
      currentZoneId: currentZoneId ?? this.currentZoneId,
      activityLog: activityLog ?? this.activityLog,
    );
  }

  factory RoverMission.fromJson(Map<String, dynamic> json) {
    return RoverMission(
      id: json['id'] as String,
      name: json['name'] as String,
      status: MissionStatus.values.firstWhere((e) => e.name == json['status']),
      startedAt: DateTime.parse(json['startedAt'] as String),
      coveragePercent: (json['coveragePercent'] as num).toDouble(),
      zoneSequence: (json['zoneSequence'] as List).cast<String>(),
      currentZoneId: json['currentZoneId'] as String,
      activityLog: (json['activityLog'] as List)
          .map((e) => MissionActivityEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'coveragePercent': coveragePercent,
      'zoneSequence': zoneSequence,
      'currentZoneId': currentZoneId,
      'activityLog': activityLog.map((e) => e.toJson()).toList(),
    };
  }
}
