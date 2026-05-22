// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CaseRequestModel _$CaseRequestModelFromJson(Map<String, dynamic> json) =>
    _CaseRequestModel(
      id: (json['id'] as num?)?.toInt(),
      doctorFirstName: json['doctorFirstName'] as String? ?? '',
      doctorLastName: json['doctorLastName'] as String? ?? '',
      doctorPhoneNumber: json['doctorPhoneNumber'] as String? ?? '',
      doctorCityName: json['doctorCityName'] as String? ?? '',
      doctorUniversityName: json['doctorUniversityName'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? '',
      description: json['description'] as String? ?? '',
      dateTime: json['dateTime'] as String? ?? '',
    );

Map<String, dynamic> _$CaseRequestModelToJson(_CaseRequestModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'doctorFirstName': instance.doctorFirstName,
      'doctorLastName': instance.doctorLastName,
      'doctorPhoneNumber': instance.doctorPhoneNumber,
      'doctorCityName': instance.doctorCityName,
      'doctorUniversityName': instance.doctorUniversityName,
      'categoryName': instance.categoryName,
      'description': instance.description,
      'dateTime': instance.dateTime,
    };
