// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_NotificationLogModel _$NotificationLogModelFromJson(
        Map<String, dynamic> json) =>
    _NotificationLogModel(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      body: json['body'] as String? ?? '',
      status: json['status'] as String? ?? 'SENT',
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String?,
      readStatus: json['readStatus'] as bool? ?? false,
      payload: json['payload'] as Map<String, dynamic>? ?? const {},
      appointmentId: json['appointmentId'] as String? ?? '',
      messageId: json['messageId'] as String? ?? '',
      doctorId: json['doctorId'] as String? ?? '',
      type: json['type'] as String? ?? '',
      time: json['time'] as String? ?? '',
      clinic: json['clinic'] as String? ?? '',
      doctorName: json['doctorName'] as String? ?? '',
    );

Map<String, dynamic> _$NotificationLogModelToJson(
        _NotificationLogModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'body': instance.body,
      'status': instance.status,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'readStatus': instance.readStatus,
      'payload': instance.payload,
      'appointmentId': instance.appointmentId,
      'messageId': instance.messageId,
      'doctorId': instance.doctorId,
      'type': instance.type,
      'time': instance.time,
      'clinic': instance.clinic,
      'doctorName': instance.doctorName,
    };
