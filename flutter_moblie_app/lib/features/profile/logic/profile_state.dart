import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/university_model.dart';
import 'package:dio/dio.dart';
import 'package:thoutha_mobile_app/features/profile/data/models/doctor_profile_model.dart';

part 'profile_state.freezed.dart';

@freezed
class ProfileState<T> with _$ProfileState<T> {
  factory ProfileState.initial() = _Initial;

  // Represents "Stale-While-Revalidate" state (loading but showing cached data)
  factory ProfileState.loading({
    DoctorProfileModel? cachedData,
    @Default([]) List<UniversityModel> universities,
    @Default([]) List<CityModel> cities,
    @Default([]) List<CategoryModel> categories,
  }) = Loading<T>;

  factory ProfileState.success(
    T data, {
    @Default([]) List<UniversityModel> universities,
    @Default([]) List<CityModel> cities,
    @Default([]) List<CategoryModel> categories,
  }) = Success<T>;

  factory ProfileState.error({
    required String error,
    required DioExceptionType? type,
  }) = Error;
}
