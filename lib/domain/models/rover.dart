/// Simplified Rover model matching Firebase `rover/` structure.
///
/// Since there is only one rover, this is treated as a singleton in the app.
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
  final RoverStatus status;
  final String currentZone;
  final ConnectionStatus connection;

  const Rover({
    required this.id,
    required this.status,
    required this.currentZone,
    required this.connection,
  });

  Rover copyWith({
    String? id,
    RoverStatus? status,
    String? currentZone,
    ConnectionStatus? connection,
  }) {
    return Rover(
      id: id ?? this.id,
      status: status ?? this.status,
      currentZone: currentZone ?? this.currentZone,
      connection: connection ?? this.connection,
    );
  }

  /// Parse from Firebase Realtime Database snapshot value.
  factory Rover.fromFirebase(Map<dynamic, dynamic> data) {
    return Rover(
      id: (data['id'] as String?) ?? 'R-01',
      status: _parseStatus((data['status'] as String?) ?? 'idle'),
      currentZone: (data['currentZone'] as String?) ?? '',
      connection: _parseConnection((data['connection'] as String?) ?? 'offline'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'currentZone': currentZone,
      'connection': connection.name,
    };
  }

  static RoverStatus _parseStatus(String value) {
    return RoverStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => RoverStatus.offline,
    );
  }

  static ConnectionStatus _parseConnection(String value) {
    return ConnectionStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ConnectionStatus.offline,
    );
  }
}
