// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'patient_booking_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PatientBookingModel _$PatientBookingModelFromJson(Map<String, dynamic> json) =>
    _PatientBookingModel(
      patientName: json['patientName'] as String? ?? 'Unknown',
      phone: json['phone'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
    );

Map<String, dynamic> _$PatientBookingModelToJson(
        _PatientBookingModel instance) =>
    <String, dynamic>{
      'patientName': instance.patientName,
      'phone': instance.phone,
      'date': instance.date,
      'time': instance.time,
    };
