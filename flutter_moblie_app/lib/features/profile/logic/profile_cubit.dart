import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/university_model.dart';
import 'package:thoutha_mobile_app/features/profile/data/models/doctor_profile_model.dart';
import 'package:thoutha_mobile_app/features/profile/data/repos/profile_repository.dart';
import 'package:thoutha_mobile_app/features/profile/logic/profile_state.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class ProfileCubit extends Cubit<ProfileState<DoctorProfileModel>> {
  final ProfileRepository _repository;

  ProfileCubit(this._repository) : super(ProfileState.initial());

  Future<void> fetchProfile() async {
    // Emit loading state without cached data - we want fresh data from server
    emit(ProfileState.loading());

    // Fetch fresh data from server (NO CACHING)
    // Workflow: Use token in headers to get doctor data directly from server
    try {
      final results = await Future.wait([
        _repository.fetchProfile(),
        _repository.getUniversities(),
        _repository.getCities(),
        _repository.getCategories(),
      ]);

      final freshProfile = results[0] as DoctorProfileModel;
      final universities = results[1] as List<UniversityModel>;
      final cities = results[2] as List<CityModel>;
      final categories = results[3] as List<CategoryModel>;

      emit(ProfileState.success(
        freshProfile,
        universities: universities,
        cities: cities,
        categories: categories,
      ));
    } on DioException catch (e) {
      emit(ProfileState.error(
        error: _getErrorMessage(e),
        type: e.type,
      ));
    } catch (e) {
      emit(ProfileState.error(
        error: e.toString().contains('Exception:')
            ? e.toString().split('Exception:').last.trim()
            : L10nBooking.anUnexpectedErrorOccurred.tr(),
        type: null,
      ));
    }
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    // Preserve existing profile & lists before emitting loading
    DoctorProfileModel? prevProfile;
    List<UniversityModel> prevUniversities = [];
    List<CityModel> prevCities = [];
    List<CategoryModel> prevCategories = [];
    state.whenOrNull(
      success: (d, u, c, cats) {
        prevProfile = d;
        prevUniversities = u;
        prevCities = c;
        prevCategories = cats;
      },
      loading: (d, u, c, cats) {
        prevProfile = d;
        prevUniversities = u;
        prevCities = c;
        prevCategories = cats;
      },
    );

    emit(ProfileState.loading(
      cachedData: prevProfile,
      universities: prevUniversities,
      cities: prevCities,
      categories: prevCategories,
    ));

    try {
      await _repository.updateProfile(body);

      final rawUpdatedId = body['id'] ?? body['doctorId'];
      final updatedId =
          int.tryParse(rawUpdatedId?.toString() ?? '') ?? prevProfile?.id;

      // Build the updated profile directly from the saved body
      // (do NOT call fetchProfile — it decodes stale JWT and overwrites fresh data)
      final updatedProfile = DoctorProfileModel(
        id: updatedId,
        firstName: body['firstName']?.toString() ?? prevProfile?.firstName,
        lastName: body['lastName']?.toString() ?? prevProfile?.lastName,
        email: body['email']?.toString() ?? prevProfile?.email,
        phone: body['phoneNumber']?.toString() ?? prevProfile?.phone,
        faculty: body['universityName']?.toString() ?? prevProfile?.faculty,
        year: body['studyYear']?.toString() ?? prevProfile?.year,
        governorate: body['cityName']?.toString() ?? prevProfile?.governorate,
        category: body['categoryName']?.toString() ?? prevProfile?.category,
      );

      emit(ProfileState.success(
        updatedProfile,
        universities: prevUniversities,
        cities: prevCities,
        categories: prevCategories,
      ));
    } on DioException catch (e) {
      emit(ProfileState.error(
        error: _getErrorMessage(e),
        type: e.type,
      ));
    } catch (e) {
      emit(ProfileState.error(
        error: e.toString().contains('Exception:')
            ? e.toString().split('Exception:').last.trim()
            : L10nProfile.anErrorOccurredWhile.tr(),
        type: null,
      ));
    }
  }

  String _getErrorMessage(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return L10nProfile.theConnectionTimedOut.tr();
    } else if (e.type == DioExceptionType.connectionError) {
      return L10nProfile.cannotConnectToThe.tr();
    } else if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
      return L10nProfile.pleaseLogInAgain.tr();
    }
    return L10nProfile.theDataCouldNot.tr();
  }
}
