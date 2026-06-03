class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.radiusKm = 5,
    this.latitude,
    this.longitude,
  });

  final int id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int radiusKm;
  final double? latitude;
  final double? longitude;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: (json['id'] as num).toInt(),
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        avatarUrl: json['avatar_url'],
        radiusKm: (json['radius_km'] as num?)?.toInt() ?? 5,
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
        'radius_km': radiusKm,
        'latitude': latitude,
        'longitude': longitude,
      };
}
