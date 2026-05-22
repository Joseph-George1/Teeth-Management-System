class CityModel {
  final int id;
  final String name;
  final double? longitude;
  final double? latitude;

  CityModel({
    required this.id,
    required this.name,
    this.longitude,
    this.latitude,
  });

  factory CityModel.fromJson(Map<String, dynamic> json) {
    return CityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      longitude: (json['longitude'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'longitude': longitude,
      'latitude': latitude,
    };
  }
}
