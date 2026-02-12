import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';

class CaseRequestModel {
  final int id;
  final String description;
  final String date;
  final String time;
  final String location;
  final String specialization;
  final DoctorModel doctor;

  CaseRequestModel({
    required this.id,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.specialization,
    required this.doctor,
  });

  factory CaseRequestModel.fromJson(Map<String, dynamic> json) {
    return CaseRequestModel(
      id: json['id'] as int? ?? 0,
      description: json['description'] as String? ?? '',
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      specialization: json['specialization'] as String? ?? '',
      doctor: DoctorModel.fromJson(json['doctor'] ?? {}),
    );
  }
}
