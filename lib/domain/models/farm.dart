class Farm {
  final String id;
  final String name;
  final String location;
  final double areaAcres;
  final int zoneCount;
  final bool roverConnected;
  final DateTime createdAt;

  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.areaAcres,
    required this.zoneCount,
    required this.roverConnected,
    required this.createdAt,
  });

  Farm copyWith({
    String? id,
    String? name,
    String? location,
    double? areaAcres,
    int? zoneCount,
    bool? roverConnected,
    DateTime? createdAt,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      location: location ?? this.location,
      areaAcres: areaAcres ?? this.areaAcres,
      zoneCount: zoneCount ?? this.zoneCount,
      roverConnected: roverConnected ?? this.roverConnected,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Farm.fromJson(Map<String, dynamic> json) {
    return Farm(
      id: json['id'] as String,
      name: json['name'] as String,
      location: json['location'] as String,
      areaAcres: (json['areaAcres'] as num).toDouble(),
      zoneCount: json['zoneCount'] as int,
      roverConnected: json['roverConnected'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'areaAcres': areaAcres,
      'zoneCount': zoneCount,
      'roverConnected': roverConnected,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
