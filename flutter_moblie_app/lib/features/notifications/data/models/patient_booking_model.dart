import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_booking_model.freezed.dart';
part 'patient_booking_model.g.dart';

@freezed
abstract class PatientBookingModel with _$PatientBookingModel {
  const factory PatientBookingModel({
    @Default('Unknown') String patientName,
    @Default('') String phone,
    @Default('') String date,
    @Default('') String time,
  }) = _PatientBookingModel;

  factory PatientBookingModel.fromJson(Map<String, dynamic> json) =>
      _$PatientBookingModelFromJson(json);

  factory PatientBookingModel.fromMap(Map<String, dynamic> map) {
    return PatientBookingModel(
      patientName: map['patientName']?.toString() ?? 'Unknown',
      phone: map['phone']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      time: map['time']?.toString() ?? '',
    );
  }
}
