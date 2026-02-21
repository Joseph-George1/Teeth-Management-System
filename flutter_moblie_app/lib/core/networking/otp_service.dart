import 'package:dio/dio.dart';
import 'package:thotha_mobile_app/core/networking/api_constants.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

class OtpService {
  final Dio _dio = DioFactory.getDio();

  /// Send OTP to the provided phone number
  /// 
  /// [phoneNumber] should be in international format: +20XXXXXXXXXX
  /// 
  /// Returns a Map with:
  /// - 'success': true/false
  /// - 'message': success/error message
  Future<Map<String, dynamic>> sendOtp(String phoneNumber) async {
    try {
      // Validate phone number format
      if (phoneNumber.isEmpty) {
        return {
          'success': false,
          'error': 'رقم الهاتف مطلوب',
        };
      }

      // Ensure phone number starts with +
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }

      print('Sending OTP to: $formattedPhone');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.sendOtp}',
        data: {
          'phone_number': formattedPhone,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Send OTP Response Status: ${response.statusCode}');
      print('Send OTP Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'تم إرسال رمز التحقق بنجاح',
        };
      } else {
        String errorMessage = 'فشل إرسال رمز التحقق';

        if (response.data != null) {
          if (response.data is Map) {
            errorMessage = response.data['message'] ??
                response.data['error'] ??
                errorMessage;
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } on DioException catch (e) {
      print('DioException in sendOtp: ${e.message}');
      return {
        'success': false,
        'error': _handleDioError(e),
      };
    } catch (e) {
      print('Exception in sendOtp: ${e.toString()}');
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع',
      };
    }
  }

  /// Verify the OTP code for the provided phone number
  ///
  /// [phoneNumber] should be in international format: +20XXXXXXXXXX
  /// [otp] is the 6-digit code received via SMS
  ///
  /// Returns a Map with:
  /// - 'success': true/false
  /// - 'message': success/error message
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    try {
      // Validate inputs
      if (phoneNumber.isEmpty) {
        return {
          'success': false,
          'error': 'رقم الهاتف مطلوب',
        };
      }

      if (otp.isEmpty) {
        return {
          'success': false,
          'error': 'رمز التحقق مطلوب',
        };
      }

      if (otp.length != 6) {
        return {
          'success': false,
          'error': 'رمز التحقق يجب أن يكون 6 أرقام',
        };
      }

      // Ensure phone number starts with +
      String formattedPhone = phoneNumber.trim();
      if (!formattedPhone.startsWith('+')) {
        formattedPhone = '+$formattedPhone';
      }

      print('Verifying OTP: $otp for phone: $formattedPhone');

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.verifyOtp}',
        data: {
          'phone_number': formattedPhone,
          'otp': otp,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Verify OTP Response Status: ${response.statusCode}');
      print('Verify OTP Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? 'تم التحقق بنجاح',
          'data': response.data,
        };
      } else {
        String errorMessage = 'رمز التحقق غير صحيح';

        if (response.data != null) {
          if (response.data is Map) {
            errorMessage = response.data['message'] ??
                response.data['error'] ??
                errorMessage;
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }

        // More specific error messages
        if (response.statusCode == 400) {
          errorMessage = 'رمز التحقق غير صحيح';
        } else if (response.statusCode == 404) {
          errorMessage = 'لم يتم العثور على رمز التحقق';
        } else if (response.statusCode == 410 || response.statusCode == 408) {
          errorMessage = 'انتهت صلاحية رمز التحقق. يرجى طلب رمز جديد';
        }

        return {
          'success': false,
          'error': errorMessage,
        };
      }
    } on DioException catch (e) {
      print('DioException in verifyOtp: ${e.message}');
      return {
        'success': false,
        'error': _handleDioError(e),
      };
    } catch (e) {
      print('Exception in verifyOtp: ${e.toString()}');
      return {
        'success': false,
        'error': 'حدث خطأ غير متوقع',
      };
    }
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return 'انتهت مهلة الاتصال. تحقق من الإنترنت.';
    } else if (e.type == DioExceptionType.connectionError) {
      return 'فشل الاتصال بالخادم. تحقق من الإنترنت.';
    } else if (e.response?.statusCode == 400) {
      return e.response?.data?['message'] ?? 'بيانات غير صحيحة';
    } else if (e.response?.statusCode == 401) {
      return 'غير مصرح';
    } else if (e.response?.statusCode == 404) {
      return 'الخدمة غير متوفرة';
    } else if (e.response?.statusCode == 500) {
      return 'خطأ في الخادم';
    }
    return 'حدث خطأ غير متوقع';
  }
}
