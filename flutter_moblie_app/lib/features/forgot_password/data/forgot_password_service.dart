import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

class ForgotPasswordService {
  final Dio _dio = DioFactory.getDio();
  static const String _baseUrl = 'http://13.49.221.187:5000';

  // Send OTP to email for password reset
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/send-otp',
        data: {'email': email},
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم إرسال رمز التحقق بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'فشل إرسال رمز التحقق',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في الاتصال بالخادم',
      };
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl/api/auth/verify-otp',
        data: {
          'email': email,
          'otp': otp,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم التحقق من الرمز بنجاح',
          'resetToken': response.data['resetToken'],
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'رمز التحقق غير صالح',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في التحقق من الرمز',
      };
    }
  }

  // Reset password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      if (newPassword != confirmPassword) {
        return {
          'success': false,
          'message': 'كلمات المرور غير متطابقة',
        };
      }

      final response = await _dio.post(
        '$_baseUrl/api/auth/reset-password',
        data: {
          'email': email,
          'otp': otp,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
        options: Options(
          headers: {'Content-Type': 'application/json'},
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم إعادة تعيين كلمة المرور بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': response.data?['message'] ?? 'فشل إعادة تعيين كلمة المرور',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ في إعادة تعيين كلمة المرور',
      };
    }
  }
}
