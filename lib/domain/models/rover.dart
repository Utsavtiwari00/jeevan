enum RoverStatus { idle, scanning, paused, returning, charging, offline }

extension RoverStatusExtension on RoverStatus {
  String get label {
    switch (this) {
      case RoverStatus.idle: return 'Idle';
      case RoverStatus.scanning: return 'Scanning';
      case RoverStatus.paused: return 'Paused';
      case RoverStatus.returning: return 'Returning';
      case RoverStatus.charging: return 'Charging';
      case RoverStatus.offline: return 'Offline';
    }
  }
}

enum ConnectionStatus { strong, weak, offline }

extension ConnectionStatusExtension on ConnectionStatus {
  String get label {
    switch (this) {
      case ConnectionStatus.strong: return 'Strong';
      case ConnectionStatus.weak: return 'Weak';
      case ConnectionStatus.offline: return 'Offline';
    }
  }
}

class Rover {
  final String id;
  final double batteryPercent;
  final double latitude;
  final double longitude;
  final RoverStatus status;
  final String? currentZoneId;
  final ConnectionStatus connectionStatus;
  final DateTime lastSync;

  const Rover({
    required this.id,
    required this.batteryPercent,
    required this.latitude,
    required this.longitude,
    required this.status,
    this.currentZoneId,
    required this.connectionStatus,
    required this.lastSync,
  });

  Rover copyWith({
    String? id,
    double? batteryPercent,
    double? latitude,
    double? longitude,
    RoverStatus? status,
    String? currentZoneId,
    ConnectionStatus? connectionStatus,
    DateTime? lastSync,
  }) {
    return Rover(
      id: id ?? this.id,
      batteryPercent: batteryPercent ?? this.batteryPercent,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      currentZoneId: currentZoneId ?? this.currentZoneId,
      connectionStatus: connectionStatus ?? this.connectionStatus,
      lastSync: lastSync ?? this.lastSync,
    );
  }

  factory Rover.fromJson(Map<String, dynamic> json) {
    return Rover(
      id: json['id'] as String,
      batteryPercent: (json['batteryPercent'] as num).toDouble(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: RoverStatus.values.firstWhere((e) => e.name == json['status']),
      currentZoneId: json['currentZoneId'] as String?,
      connectionStatus: ConnectionStatus.values.firstWhere((e) => e.name == json['connectionStatus']),
      lastSync: DateTime.parse(json['lastSync'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batteryPercent': batteryPercent,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'currentZoneId': currentZoneId,
      'connectionStatus': connectionStatus.name,
      'lastSync': lastSync.toIso8601String(),
    };
  }
}
