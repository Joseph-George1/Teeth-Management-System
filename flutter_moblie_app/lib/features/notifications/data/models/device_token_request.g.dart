// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_token_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_DeviceTokenRequest _$DeviceTokenRequestFromJson(Map<String, dynamic> json) =>
    _DeviceTokenRequest(
      userId: (json['user_id'] as num?)?.toInt(),
      patientId: (json['patient_id'] as num?)?.toInt(),
      patientToken: json['patient_token'] as String?,
      fcmToken: json['fcmToken'] as String,
      deviceType: json['deviceType'] as String,
      deviceModel: json['deviceModel'] as String?,
      osVersion: json['osVersion'] as String?,
    );

Map<String, dynamic> _$DeviceTokenRequestToJson(_DeviceTokenRequest instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'patient_id': instance.patientId,
      'patient_token': instance.patientToken,
      'fcmToken': instance.fcmToken,
      'deviceType': instance.deviceType,
      'deviceModel': instance.deviceModel,
      'osVersion': instance.osVersion,
    };
