import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/helpers/constants.dart';
import 'package:thotha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

/// =====================
/// Auth Result Model
/// =====================
class AuthResult {
  final bool success;
  final String? message;
  final String? token;
  final int? statusCode;
  final dynamic data;

  AuthResult({
    required this.success,
    this.message,
    this.token,
    this.statusCode,
    this.data,
  });
}

/// =====================
/// User Model
/// =====================
class UserModel {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String faculty;
  final String year;
  final String governorate;

  UserModel({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.faculty,
    required this.year,
    required this.governorate,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? json;

    return UserModel(
      firstName: user['first_name'] ?? '',
      lastName: user['last_name'] ?? '',
      email: user['email'] ?? '',
      phone: user['phone']?.toString() ?? '',
      faculty: user['faculty'] ?? '',
      year: user['year']?.toString() ?? '',
      governorate: user['governorate'] ?? '',
    );
  }
}

/// =====================
/// Auth Service
/// =====================
class AuthService {
  static const String _baseUrl = 'http://13.53.131.167:5000';
  final Dio _dio = DioFactory.getDio();

  /* ================= LOGIN ================= */

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      return AuthResult(
        success: false,
        message: 'البريد الإلكتروني وكلمة المرور مطلوبان',
        statusCode: 400,
      );
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200) {
        final token = response.data['token'];
        final user = UserModel.fromJson(response.data);

        if (token != null && token is String && token.isNotEmpty) {
          await _persistLogin(token, user);
        }

        return AuthResult(
          success: true,
          token: token,
          data: response.data,
        );
      }

      return AuthResult(
        success: false,
        message: _mapError(response.statusCode, response.data),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    } catch (_) {
      return AuthResult(
        success: false,
        message: 'حدث خطأ غير متوقع',
        statusCode: 500,
      );
    }
  }

  /* ================= REGISTER ================= */

  Future<AuthResult> register({
    required UserModel user,
    required String password,
    required String confirmPassword,
  }) async {
    if (password.length < 6) {
      return AuthResult(
        success: false,
        message: 'كلمة المرور يجب ألا تقل عن 6 أحرف',
        statusCode: 400,
      );
    }

    try {
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': user.email,
          'password': password,
          'confirm_password': confirmPassword,
          'first_name': user.firstName,
          'last_name': user.lastName,
          'phone': user.phone,
          'faculty': user.faculty,
          'year': user.year,
          'governorate': user.governorate,
        },
        options: Options(validateStatus: (status) => status! < 500),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await _saveUser(user);

        return AuthResult(
          success: true,
          message: 'تم إنشاء الحساب بنجاح',
          data: response.data,
        );
      }

      return AuthResult(
        success: false,
        message: _mapError(response.statusCode, response.data),
        statusCode: response.statusCode,
      );
    } on DioException catch (e) {
      return AuthResult(
        success: false,
        message: _handleDioError(e),
        statusCode: e.response?.statusCode,
      );
    }
  }

  /* ================= HELPERS ================= */

  Future<void> _persistLogin(String token, UserModel user) async {
    await SharedPrefHelper.setSecuredString(
      SharedPrefKeys.userToken,
      token,
    );
    DioFactory.setTokenIntoHeaderAfterLogin(token);
    await _saveUser(user);
  }

  Future<void> _saveUser(UserModel user) async {
    await SharedPrefHelper.setData('first_name', user.firstName);
    await SharedPrefHelper.setData('last_name', user.lastName);
    await SharedPrefHelper.setData('email', user.email);
    await SharedPrefHelper.setData('phone', user.phone);
    await SharedPrefHelper.setData('faculty', user.faculty);
    await SharedPrefHelper.setData('year', user.year);
    await SharedPrefHelper.setData('governorate', user.governorate);
  }

  String _mapError(int? status, dynamic data) {
    switch (status) {
      case 400:
        return 'بيانات غير صحيحة';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 404:
        return 'الحساب غير موجود';
      case 409:
        return 'هذا البريد الإلكتروني مسجل مسبقًا';
      default:
        return 'حدث خطأ غير متوقع';
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال بالخادم';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'تعذر الاتصال بالخادم';
    }
    return 'حدث خطأ غير متوقع';
  }
}
