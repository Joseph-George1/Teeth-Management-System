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
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      studyYear: json['studyYear'] as String,
      phoneNumber: json['phoneNumber'] as String,
      universityName: json['universityName'] as String,
      cityName: json['cityName'] as String,
      categoryName: json['categoryName'] as String,
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
