class UniversityModel {
  final int id;
  final String name;
  final String city;
  final String location;

  UniversityModel({
    required this.id,
    required this.name,
    required this.city,
    required this.location,
  });

  factory UniversityModel.fromJson(Map<String, dynamic> json) {
    return UniversityModel(
      id: json['id'] as int,
      name: json['name'] as String,
      city: json['city'] as String,
      location: json['location'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'location': location,
    };
  }
}
