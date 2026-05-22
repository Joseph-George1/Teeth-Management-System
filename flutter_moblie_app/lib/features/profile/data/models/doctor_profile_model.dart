import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_profile_model.freezed.dart';
part 'doctor_profile_model.g.dart';

Object? readFirstName(Map json, String key) =>
    json['firstName'] ?? json['first_name'] ?? json['name'];
Object? readLastName(Map json, String key) =>
    json['lastName'] ?? json['last_name'];
Object? readEmail(Map json, String key) =>
    json['email'] ?? json['sub'] ?? json['Email'];
Object? readPhone(Map json, String key) {
  final keys = [
    'phoneNumber',
    'phone',
    'tel',
    'telephone',
    'phone_number',
    'mobile'
  ];
  for (var k in keys) {
    if (json[k] != null &&
        json[k].toString().isNotEmpty &&
        !json[k].toString().contains('@')) {
      return json[k];
    }
  }
  return null;
}

Object? readFaculty(Map json, String key) =>
    json['faculty'] ??
    json['universityName'] ??
    json['university_name'] ??
    json['college'];
Object? readYear(Map json, String key) =>
    json['year'] ?? json['studyYear'] ?? json['study_year'] ?? json['level'];
Object? readGov(Map json, String key) =>
    json['governorate'] ??
    json['cityName'] ??
    json['city_name'] ??
    json['city'] ??
    json['governorate_id'];
Object? readCat(Map json, String key) =>
    json['category'] ??
    json['categoryName'] ??
    json['category_name'] ??
    json['specialty'] ??
    json['specialization'];

@freezed
abstract class DoctorProfileModel with _$DoctorProfileModel {
  const factory DoctorProfileModel({
    int? id,
    @JsonKey(readValue: readFirstName) String? firstName,
    @JsonKey(readValue: readLastName) String? lastName,
    @JsonKey(readValue: readEmail) String? email,
    @JsonKey(readValue: readPhone) String? phone,
    @JsonKey(readValue: readFaculty) String? faculty,
    @JsonKey(readValue: readYear) String? year,
    @JsonKey(readValue: readGov) String? governorate,
    @JsonKey(readValue: readCat) String? category,
  }) = _DoctorProfileModel;

  factory DoctorProfileModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorProfileModelFromJson(json);
}
