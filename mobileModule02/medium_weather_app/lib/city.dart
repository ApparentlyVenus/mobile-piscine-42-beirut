class City {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String region;

  City({required this.name,
      required this.longitude,
      required this.latitude,
      required this.country,
      required this.region});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
      longitude: json['longitude'] ?? 0.0,
      latitude: json['latitude'] ?? 0.0,
      country: json['country'] ?? '',
      region: json['region'] ?? '',
    );
  }

  String get displayName {
    return name + ", " + region + ", " + country;
  }
}
