import 'package:freezed_annotation/freezed_annotation.dart';

part 'doctor_model.freezed.dart';
part 'doctor_model.g.dart';

@freezed
abstract class DoctorModel with _$DoctorModel {
  const DoctorModel._();

  const factory DoctorModel({
    int? id,
    @Default('') String firstName,
    @Default('') String lastName,
    @Default('') String studyYear,
    @Default('') String phoneNumber,
    @Default('') String universityName,
    @Default('') String cityName,
    @Default('') String categoryName,
    String? photo,
    String? email,
    String? description,
    double? price,
  }) = _DoctorModel;

  factory DoctorModel.fromJson(Map<String, dynamic> json) =>
      _$DoctorModelFromJson(json);

  String get fullName => '$firstName $lastName';

  bool get hasValidData {
    return firstName.isNotEmpty &&
        lastName.isNotEmpty &&
        categoryName.isNotEmpty &&
        cityName.isNotEmpty;
  }
}
