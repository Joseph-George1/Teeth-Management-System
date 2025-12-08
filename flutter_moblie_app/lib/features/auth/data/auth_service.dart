import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

class AuthService {
  static const String _baseUrl = 'http://13.49.221.187:5000';
  final Dio _dio = DioFactory.getDio();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // Validate input
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'error': 'البريد الإلكتروني وكلمة المرور مطلوبان',
          'statusCode': 400,
        };
      }

      // Make the API request
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500, // Handle 4xx errors manually
        ),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        // Assuming the API returns a token in the response
        final token = response.data['token'];
        if (token != null) {
          // TODO: Save the token to secure storage
          // await _saveToken(token);
        }
        
        return {
          'success': true,
          'data': response.data,
          'token': token,
        };
      }

      // Handle error responses
      return {
        'success': false,
        'error': _getErrorMessage(response.statusCode, response.data),
        'statusCode': response.statusCode,
      };
      
    } on DioException catch (e) {
      // Handle Dio errors (network errors, etc.)
      return {
        'success': false,
        'error': _handleDioError(e),
        'statusCode': e.response?.statusCode ?? 500,
      };
    } catch (e) {
      // Handle any other errors
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى',
        'statusCode': 500,
      };
    }
  }
  
  String _getErrorMessage(int? statusCode, dynamic responseData) {
    switch (statusCode) {
      case 400:
        return 'بيانات الدخول غير صحيحة';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 403:
        return 'غير مصرح لك بالدخول';
      case 404:
        return 'الحساب غير موجود';
      case 422:
        // Handle validation errors from the server
        if (responseData is Map && responseData['errors'] != null) {
          return responseData['errors'].values.first[0] ?? 'بيانات غير صالحة';
        }
        return 'بيانات غير صالحة';
      default:
        return 'حدث خطأ في الخادم. الرجاء المحاولة مرة أخرى';
    }
  }
  
  String _handleDioError(DioException e) {
    print('Dio Error: ${e.message}');
    print('Error Type: ${e.type}');
    if (e.response != null) {
      print('Response Status: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');
    }
    
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم. الرجاء التحقق من اتصالك بالإنترنت';
    } else if (e.response != null) {
      return _getErrorMessage(e.response?.statusCode, e.response?.data);
    } else {
      return 'حدث خطأ غير متوقع. الرجاء المحاولة مرة أخرى';
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String confirmPassword,
    required String firstName,
    required String last_name,
    required String phone,
    required String faculty,
    required String year,
    required String governorate,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty
          ||firstName.isEmpty || last_name.isEmpty
          || phone.isEmpty    || faculty.isEmpty
          || year.isEmpty     || governorate.isEmpty
      )
      {
        return {
          'success': false,
          'error': 'البريد الإلكتروني وكلمة المرور مطلوبان',
          'statusCode': 400,
        };
      }

      if (password.length <= 6) {
        return {
          'success': false,
          'error': 'يجب أن تكون كلمة المرور 6 أحرف على الأقل',
          'statusCode': 400,
        };
      }

      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': email.trim(),
          'password': password,
          'faculty' : faculty,
              'first_name': firstName,
          'last_name' :last_name,
          'governorate':governorate,
              'year' : year,
          'phone' : phone,
          'confirm_password': confirmPassword,


        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'data': response.data,
          'message': 'تم إنشاء الحساب بنجاح',
        };
      } else {
        // Handle different error status codes
        String errorMessage = 'حدث خطأ في التسجيل';
        if (response.statusCode == 400) {
          errorMessage = response.data?['message'] ?? 'بيانات غير صالحة';
        } else if (response.statusCode == 409) {
          errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً';
        }
        
        return {
          'success': false,
          'error': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } on DioException catch (e) {
      return {
        'success': false,
        'error': e.response?.data?['message'] ?? 'تعذر الاتصال بالخادم. يرجى المحاولة مرة أخرى',
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع: ${e.toString()}',
      };
    }
  }
}
