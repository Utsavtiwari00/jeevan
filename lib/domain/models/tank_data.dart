/// Tank data matching Firebase `tanks/` structure.
class TankData {
  final double pesticideLevel;

  const TankData({
    required this.pesticideLevel,
  });

  TankData copyWith({
    double? pesticideLevel,
  }) {
    return TankData(
      pesticideLevel: pesticideLevel ?? this.pesticideLevel,
    );
  }

  /// Parse from Firebase Realtime Database snapshot value.
  factory TankData.fromFirebase(Map<dynamic, dynamic> data) {
    return TankData(
      pesticideLevel: (data['pesticideLevel'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pesticideLevel': pesticideLevel,
    };
  }
}
