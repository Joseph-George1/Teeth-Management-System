import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thoutha_mobile_app/core/di/dependency_injection.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/networking/dio_factory.dart';
import 'package:thoutha_mobile_app/core/networking/models/category_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/city_model.dart';
import 'package:thoutha_mobile_app/core/networking/models/university_model.dart';
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

import '../models/doctor_profile_model.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;

class ProfileRepository {
  final Dio _dio = DioFactory.getDio();

  /// Centralized logic to fetch profile from server using token in headers
  /// NO CACHING - Always fetches fresh data from the server
  /// Workflow: Login (save token) -> Use token to fetch doctor data -> Display it
  Future<DoctorProfileModel> fetchProfile() async {
    // Primary: Try getDoctorById using token from headers (no request body)
    // الـ Token موجود في headers تلقائياً من DioFactory
    debugPrint(
        '=== fetchProfile: Attempting to fetch doctor profile using token ===');
    try {
      final profileResult = await getIt<ApiService>().getDoctorById();
      if (profileResult['success'] == true &&
          profileResult['data'] is DoctorProfileModel) {
        final profile = profileResult['data'] as DoctorProfileModel;
        debugPrint(
            '=== fetchProfile: Successfully fetched fresh doctor profile ===');
        // NO CACHING - Return fresh data directly from server
        return profile;
      }
    } catch (e) {
      debugPrint('=== fetchProfile: getDoctorById failed: $e ===');
      // Continue to fallback endpoints
    }

    // Fallback: Try other endpoints if primary fails
    Response? response;
    final endpoints = [
      '/api/auth/profile',
      '/api/doctor/profile',
      '/api/user/me',
      '/api/me',
      '/profile',
      '/me'
    ];

    for (final path in endpoints) {
      try {
        debugPrint('=== fetchProfile: Trying endpoint: $path ===');
        response = await _dio.get(path);

        if (response.statusCode == 200 &&
            response.data != null &&
            response.data is Map<String, dynamic>) {
          final data = response.data;
          Map<String, dynamic> jsonData = data as Map<String, dynamic>;

          // Unwrap if nested under 'user', 'data', or 'doctor'
          if (jsonData.containsKey('user') && jsonData['user'] is Map) {
            jsonData = Map<String, dynamic>.from(jsonData['user']);
          } else if (jsonData.containsKey('data') && jsonData['data'] is Map) {
            jsonData = Map<String, dynamic>.from(jsonData['data']);
          } else if (jsonData.containsKey('doctor') &&
              jsonData['doctor'] is Map) {
            jsonData = Map<String, dynamic>.from(jsonData['doctor']);
          }

          debugPrint(
              '=== fetchProfile: Successfully fetched profile from $path ===');
          final profile = DoctorProfileModel.fromJson(jsonData);
          // NO CACHING - Return fresh data directly
          return profile;
        }
      } catch (e) {
        debugPrint('=== fetchProfile: Endpoint $path failed: $e ===');
        // Continue to next endpoint
      }
    }

    // FINAL FALLBACK: Return cached data only if API completely fails
    // This ensures the app doesn't crash, but users see stale data
    try {
      final cached = await getCachedProfile();
      if (cached.firstName != null && cached.firstName!.isNotEmpty) {
        debugPrint(
            '=== fetchProfile: All endpoints failed, returning cached profile ===');
        return cached;
      }
    } catch (_) {
      debugPrint('=== fetchProfile: No cached profile available ===');
    }

    throw Exception(L10nProfile.dataCannotBeLoaded.tr());
  }

  Future<DoctorProfileModel> getCachedProfile() async {
    final cachedFirst = await SharedPrefHelper.getString('first_name');
    final cachedLast = await SharedPrefHelper.getString('last_name');
    final cachedEmail = await SharedPrefHelper.getString('email');
    final cachedPhone = await SharedPrefHelper.getString('phone');
    final cachedFaculty = await SharedPrefHelper.getString('faculty');
    final cachedYear = await SharedPrefHelper.getString('year');
    final cachedGov = await SharedPrefHelper.getString('governorate');
    final cachedCat = await SharedPrefHelper.getString('category');

    return DoctorProfileModel(
      id: null,
      // لا نحفظ الـ ID - التوكن كافي
      firstName: cachedFirst,
      lastName: cachedLast,
      email: cachedEmail,
      phone: cachedPhone,
      faculty: cachedFaculty,
      year: cachedYear,
      governorate: cachedGov,
      category: cachedCat,
    );
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    // NO CACHING - Just call the API to update the profile
    // The UI will handle displaying the updated data without caching it
    final result = await getIt<ApiService>().updateDoctor(body);
    if (result['success'] != true) {
      throw Exception(result['error']?.toString() ?? L10nProfile.dataUpdateFailed.tr());
    }
    // Profile updated successfully - no caching, fresh data will be fetched when needed
  }

  Future<List<UniversityModel>> getUniversities() async {
    final result = await getIt<ApiService>().getUniversities();
    if (result['success'] == true) {
      return result['data'] as List<UniversityModel>;
    }
    throw Exception(result['error'] ?? L10nProfile.failedToLoadList1.tr());
  }

  Future<List<CityModel>> getCities() async {
    final result = await getIt<ApiService>().getCities();
    if (result['success'] == true) {
      return result['data'] as List<CityModel>;
    }
    throw Exception(result['error'] ?? L10nProfile.failedToLoadList.tr());
  }

  Future<List<CategoryModel>> getCategories() async {
    final result = await getIt<ApiService>().getCategories();
    if (result['success'] == true) {
      return result['data'] as List<CategoryModel>;
    }
    throw Exception(result['error'] ?? L10nProfile.failedToLoadList2.tr());
  }
}
