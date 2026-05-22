// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoctorModel _$DoctorModelFromJson(Map<String, dynamic> json) => _DoctorModel(
      id: (json['id'] as num?)?.toInt(),
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      studyYear: json['studyYear'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      universityName: json['universityName'] as String? ?? '',
      cityName: json['cityName'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      photo: json['photo'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      price: (json['price'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$DoctorModelToJson(_DoctorModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'studyYear': instance.studyYear,
      'phoneNumber': instance.phoneNumber,
      'universityName': instance.universityName,
      'cityName': instance.cityName,
      'categoryName': instance.categoryName,
      'photo': instance.photo,
      'email': instance.email,
      'description': instance.description,
      'price': instance.price,
    };
