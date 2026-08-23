class AppUser {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String farmName;
  final String location;

  const AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.farmName,
    required this.location,
  });

  AppUser copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? farmName,
    String? location,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      farmName: farmName ?? this.farmName,
      location: location ?? this.location,
    );
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      farmName: json['farmName'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'farmName': farmName,
      'location': location,
    };
  }
}
