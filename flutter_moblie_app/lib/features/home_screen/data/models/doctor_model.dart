class DoctorModel {
  final int? id;
  final String firstName;
  final String lastName;
  final String studyYear;
  final String phoneNumber;
  final String universityName;
  final String cityName;
  final String categoryName;
  final String? photo;
  final String? email;
  final String? description;
  final double? price;

  DoctorModel({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.studyYear,
    required this.phoneNumber,
    required this.universityName,
    required this.cityName,
    required this.categoryName,
    this.photo,
    this.email,
    this.description,
    this.price,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as int?,
      firstName: (json['firstName'] ?? json['first_name'] ?? '') as String,
      lastName: (json['lastName'] ?? json['last_name'] ?? '') as String,
      studyYear: (json['studyYear'] ?? json['study_year'] ?? json['year'] ?? '') as String,
      phoneNumber: (json['phoneNumber'] ?? json['phone_number'] ?? json['phone'] ?? '') as String,
      universityName: (json['universityName'] ?? json['university_name'] ?? json['university'] ?? '') as String,
      cityName: (json['cityName'] ?? json['city_name'] ?? json['city'] ?? '') as String,
      categoryName: (json['categoryName'] ?? json['category_name'] ?? json['category'] ?? '') as String,
      photo: json['photo'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'studyYear': studyYear,
      'phoneNumber': phoneNumber,
      'universityName': universityName,
      'cityName': cityName,
      'categoryName': categoryName,
      'photo': photo,
      'email': email,
      'description': description,
      'price': price,
    };
  }

  String get fullName => '$firstName $lastName';
}
// End of DoctorModel
