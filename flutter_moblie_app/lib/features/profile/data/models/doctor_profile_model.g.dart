// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'doctor_profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DoctorProfileModel _$DoctorProfileModelFromJson(Map<String, dynamic> json) =>
    _DoctorProfileModel(
      id: (json['id'] as num?)?.toInt(),
      firstName: readFirstName(json, 'firstName') as String?,
      lastName: readLastName(json, 'lastName') as String?,
      email: readEmail(json, 'email') as String?,
      phone: readPhone(json, 'phone') as String?,
      faculty: readFaculty(json, 'faculty') as String?,
      year: readYear(json, 'year') as String?,
      governorate: readGov(json, 'governorate') as String?,
      category: readCat(json, 'category') as String?,
    );

Map<String, dynamic> _$DoctorProfileModelToJson(_DoctorProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'email': instance.email,
      'phone': instance.phone,
      'faculty': instance.faculty,
      'year': instance.year,
      'governorate': instance.governorate,
      'category': instance.category,
    };
