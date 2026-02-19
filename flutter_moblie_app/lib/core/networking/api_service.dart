import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/api_constants.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/networking/models/category_model.dart';
import 'package:thotha_mobile_app/core/networking/models/city_model.dart';
import 'package:thotha_mobile_app/core/networking/models/university_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/doctor_model.dart';
import 'package:thotha_mobile_app/features/home_screen/data/models/case_request_model.dart';

class ApiService {
  final Dio _dio = DioFactory.getDio();

  /// Fetch doctors filtered by city ID.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getDoctorsByCity(int cityId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getDoctorsByCities}',
        queryParameters: {'cityId': cityId},
      );

      if (response.statusCode == 200) {
        final List<DoctorModel> doctors = (response.data as List)
            .map((json) => DoctorModel.fromJson(json))
            .toList();
        return {'success': true, 'data': doctors};
      }

      return {
        'success': false,
        'error': 'فشل في تحميل الأطباء',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
    }
  }

  /// Fetch doctors filtered by category ID.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getDoctorsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getDoctorsByCategories}',
        queryParameters: {'categoryId': categoryId},
      );

      if (response.statusCode == 200) {
        final List<DoctorModel> doctors = (response.data as List)
            .map((json) => DoctorModel.fromJson(json))
            .toList();
        return {'success': true, 'data': doctors};
      }

      return {
        'success': false,
        'error': 'فشل في تحميل الأطباء',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
    }
  }

  /// Fetch all dental categories.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getCategories() async {
    // Try different endpoint variations
    final endpoints = [
      ApiConstants.getCategories,
      ApiConstants.getCategoriesAlt,
      ApiConstants.getCategoriesFallback,
    ];
    
    for (String endpoint in endpoints) {
      try {
        final url = '${ApiConstants.baseUrl}$endpoint';
        print('=== API Call ===');
        print('Trying URL: $url');
        
        final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
        
        print('Response Status: ${response.statusCode}');
        print('Response Type: ${response.data.runtimeType}');

        if (response.statusCode == 200) {
          // Manual UTF-8 decoding to fix Arabic characters
          final decodedData = jsonDecode(utf8.decode(response.data.toString().codeUnits));
          final List<CategoryModel> categories = (decodedData as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
          print('✅ Success with endpoint: $endpoint');
          return {'success': true, 'data': categories};
        }
      } on DioException catch (e) {
        print('❌ Failed with endpoint $endpoint: ${e.response?.statusCode}');
        continue; // Try next endpoint
      } catch (e) {
        print('❌ Exception with endpoint $endpoint: $e');
        continue; // Try next endpoint
      }
    }
    
    // All endpoints failed
    print('❌ All endpoints failed');
    return {
      'success': false,
      'error': 'فشل في تحميل التخصصات - جميع الـ endpoints فشلت',
    };
  }

  /// Fetch all cities.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getCities() async {
    // Try different endpoint variations, starting with the new one
    final endpoints = [
      ApiConstants.getCities,      // Primary: /api/cities/getAllCities
      ApiConstants.getCitiesAlt,   // Fallback: /cities
      ApiConstants.getCitiesFallback, // Fallback: /api/cities
    ];
    
    for (String endpoint in endpoints) {
      try {
        final url = '${ApiConstants.baseUrl}$endpoint';
        print('=== Cities API Call ===');
        print('Trying URL: $url');
        
        final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
        
        print('Response Status: ${response.statusCode}');
        print('Response Type: ${response.data.runtimeType}');

        if (response.statusCode == 200) {
          // Manual UTF-8 decoding
          final decodedData = jsonDecode(utf8.decode(response.data.toString().codeUnits));
          final List<CityModel> cities = (decodedData as List)
              .map((json) => CityModel.fromJson(json))
              .toList();
          print('✅ Success with endpoint: $endpoint');
          return {'success': true, 'data': cities};
        }
      } on DioException catch (e) {
        print('❌ Failed with endpoint $endpoint: ${e.response?.statusCode}');
        continue; // Try next endpoint
      } catch (e) {
        print('❌ Exception with endpoint $endpoint: $e');
        continue; // Try next endpoint
      }
    }
    
    // All endpoints failed
    print('❌ All endpoints failed');
    return {
      'success': false,
      'error': 'فشل في تحميل المدن - جميع الـ endpoints فشلت',
    };
  }

  /// Fetch all universities.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getUniversities() async {
    try {
      final url = '${ApiConstants.baseUrl}${ApiConstants.getUniversities}';
      print('=== Universities API Call ===');
      print('Trying URL: $url');
      
      final response = await _dio.get(url, options: Options(responseType: ResponseType.plain));
      
      print('Response Status: ${response.statusCode}');
      print('Response Type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        // Manual UTF-8 decoding
        final decodedData = jsonDecode(utf8.decode(response.data.toString().codeUnits));
        final List<UniversityModel> universities = (decodedData as List)
            .map((json) => UniversityModel.fromJson(json))
            .toList();
        print('✅ Success fetching universities');
        return {'success': true, 'data': universities};
      }

      return {
        'success': false,
        'error': 'فشل في تحميل الجامعات',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
    }
  }



  /// Fetch case requests by category.
  Future<Map<String, dynamic>> getCaseRequestsByCategory(int categoryId) async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}${ApiConstants.getCaseRequestsByCategories}',
        queryParameters: {'categoryId': categoryId},
      );

      if (response.statusCode == 200) {
        final List<CaseRequestModel> requests = (response.data as List)
            .map((json) => CaseRequestModel.fromJson(json))
            .toList();
        return {'success': true, 'data': requests};
      }

      return {
        'success': false,
        'error': 'فشل في تحميل الطلبات',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
    }
  }

  /// Create a new case request.
  /// Needs auth (handled by interceptor).
  Future<Map<String, dynamic>> createCaseRequest(Map<String, dynamic> body) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.createCaseRequest}',
        data: body,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': 'تم إنشاء الطلب بنجاح',
          'data': response.data,
        };
      }

      return {
        'success': false,
        'error': 'فشل في إنشاء الطلب',
        'statusCode': response.statusCode,
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
    }
  }

  String _handleDioError(DioException e) {

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت';
    } else {
      return 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى';
    }
  }
}
