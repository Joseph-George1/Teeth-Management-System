import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/api_constants.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

class ForgotPasswordService {
  final Dio _dio = DioFactory.getDio();

  // Send OTP to email for password reset
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.otpBaseUrl}/api/auth/send-otp',
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
        String msg = 'فشل إرسال رمز التحقق';
        if (response.data is Map<String, dynamic>) {
          msg = response.data['message'] ?? msg;
        } else if (response.data is String) {
          msg = response.data;
        }
        return {
          'success': false,
          'message': msg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
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
        '${ApiConstants.otpBaseUrl}/api/auth/verify-otp',
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
        String msg = 'رمز التحقق غير صالح';
        if (response.data is Map<String, dynamic>) {
          msg = response.data['message'] ?? msg;
        } else if (response.data is String) {
          msg = response.data;
        }
        return {
          'success': false,
          'message': msg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
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
        '${ApiConstants.otpBaseUrl}/api/auth/reset-password',
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
        String msg = 'فشل إعادة تعيين كلمة المرور';
        if (response.data is Map<String, dynamic>) {
          msg = response.data['message'] ?? msg;
        } else if (response.data is String) {
          msg = response.data;
        }
        return {
          'success': false,
          'message': msg,
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'حدث خطأ: ${e.toString()}',
      };
    }
  }
}
