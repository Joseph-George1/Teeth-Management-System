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

  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // In-memory cache
  List<CategoryModel>? _cachedCategories;
  List<CityModel>? _cachedCities;
  List<UniversityModel>? _cachedUniversities;

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
      if (_cachedCategories != null && _cachedCategories!.isNotEmpty) {
        print('✅ Returning cached categories: ${_cachedCategories!.length} items');
        return {'success': true, 'data': _cachedCategories};
      }
      try {
        final url = '${ApiConstants.baseUrl}${ApiConstants.getCategories}';
        print('=== getCategories API Call ===');
        print('URL: $url');
        
        final response = await _dio.get(url);
        
        print('Response Status: ${response.statusCode}');
        print('Response Data Type: ${response.data.runtimeType}');
        print('Response Data: ${response.data}');

        if (response.statusCode == 200) {
          final List<CategoryModel> categories = (response.data as List)
              .map((json) => CategoryModel.fromJson(json))
              .toList();
          _cachedCategories = categories; // Cache the result
          print('✅ Categories parsed successfully: ${categories.length} items');
          return {'success': true, 'data': categories};
        }
        
        return {
          'success': false,
          'error': 'فشل في تحميل التخصصات',
          'statusCode': response.statusCode,
        };

      } on DioException catch (e) {
        print('❌ DioException in getCategories: ${e.message}');
        print('Response: ${e.response?.data}');
        return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
      } catch (e) {
        print('❌ Exception in getCategories: $e');
        return {
        'success': false,
        'error': 'حدث خطأ غير متوقع',
      };
      }
  }

  /// Fetch all cities.
  /// Public endpoint — no auth required.
  Future<Map<String, dynamic>> getCities() async {
      if (_cachedCities != null && _cachedCities!.isNotEmpty) {
        return {'success': true, 'data': _cachedCities};
      }
      try {
        final url = '${ApiConstants.baseUrl}${ApiConstants.getAllCities}';
        print('=== API Call ===');
        print('Trying URL: $url');
        
        final response = await _dio.get(url);
        
        print('Response Status: ${response.statusCode}');
        print('Response Data: ${response.data}');
        print('Response Type: ${response.data.runtimeType}');

        if (response.statusCode == 200) {
          final List<CityModel> cities = (response.data as List)
              .map((json) => CityModel.fromJson(json))
              .toList();
          _cachedCities = cities; // Cache the result
          print('✅ Success with endpoint: ${ApiConstants.getAllCities}');
          return {'success': true, 'data': cities};
        }
        
        return {
          'success': false,
          'error': 'فشل في تحميل المدن',
          'statusCode': response.statusCode,
        };

      } on DioException catch (e) {
        print('❌ Failed with endpoint ${ApiConstants.getAllCities}: ${e.response?.statusCode}');
        return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
      } catch (e) {
        print('❌ Exception with endpoint ${ApiConstants.getAllCities}: $e');
        return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
      };
      }
  }

  /// Fetch all universities.
  Future<Map<String, dynamic>> getUniversities() async {
      if (_cachedUniversities != null && _cachedUniversities!.isNotEmpty) {
        return {'success': true, 'data': _cachedUniversities};
      }
      try {
        final url = '${ApiConstants.baseUrl}${ApiConstants.getAllUniversities}';
        final response = await _dio.get(url);

        if (response.statusCode == 200) {
          final List<UniversityModel> universities = (response.data as List)
              .map((json) => UniversityModel.fromJson(json))
              .toList();
          _cachedUniversities = universities; // Cache result
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
        'error': 'حدث خطأ غير متوقع',
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
