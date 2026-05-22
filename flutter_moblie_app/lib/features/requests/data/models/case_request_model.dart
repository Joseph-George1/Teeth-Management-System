import 'package:freezed_annotation/freezed_annotation.dart';

part 'case_request_model.freezed.dart';
part 'case_request_model.g.dart';

@freezed
abstract class CaseRequestModel with _$CaseRequestModel {
  const CaseRequestModel._(); // Needed for custom getters/methods

  const factory CaseRequestModel({
    int? id,
    @Default('') String doctorFirstName,
    @Default('') String doctorLastName,
    @Default('') String doctorPhoneNumber,
    @Default('') String doctorCityName,
    @Default('') String doctorUniversityName,
    @Default('') String categoryName,
    @Default('') String description,
    @Default('') String dateTime, // raw ISO string e.g. "2026-03-10T21:12:00"
  }) = _CaseRequestModel;

  factory CaseRequestModel.fromJson(Map<String, dynamic> json) =>
      _$CaseRequestModelFromJson(json);

  /// Full doctor name helper
  String get doctorFullName => '$doctorFirstName $doctorLastName'.trim();

  /// Returns the date part formatted as "10/03/2026"
  String get formattedDate {
    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return dateTime;
    }
  }

  /// Returns the time part as "hh:mm a" in 12-hour format
  String get formattedTime {
    try {
      final dt = DateTime.parse(dateTime);
      final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
      final minuteStr = dt.minute.toString().padLeft(2, '0');
      final period = dt.hour < 12 ? 'صباحاً' : 'مساءً';
      return '${hour.toString().padLeft(2, '0')}:$minuteStr $period';
    } catch (_) {
      return '';
    }
  }
}
