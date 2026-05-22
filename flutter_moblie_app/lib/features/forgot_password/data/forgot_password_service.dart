import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:thoutha_mobile_app/core/helpers/phone_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

/// Handles all password-reset API calls.
///
/// Flow:
///   1. [requestReset]   → POST /api/password-reset/request   (sends OTP via WhatsApp)
///   2. [verifyOtp]      → POST /api/password-reset/verify-otp
///   3. [changePassword] → POST /api/password-reset/change-password
class PasswordResetService {
  PasswordResetService._() {
    _initDio();
  }
  static final PasswordResetService instance = PasswordResetService._();

  // Persistent Dio instance with cookie support for session management
  late final Dio _dio;
  late final CookieJar _cookieJar;

  void _initDio() {
    _cookieJar = CookieJar();
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Duration(seconds: 10),
      receiveTimeout: Duration(seconds: 10),
      contentType: 'application/json',
      responseType: ResponseType.json,
      headers: const {'Accept': 'application/json'},
      validateStatus: (status) => status != null,
    ))
      ..interceptors.add(CookieManager(_cookieJar));
  }

  /// Clear cookies (useful when starting a new password reset flow)
  void clearSession() {
    _cookieJar.deleteAll();
  }

  // ── Step 1: Request OTP ─────────────────────────────────────────────────

  /// Sends an OTP to the user's WhatsApp.
  /// [phone] is normalised to +2xxxxxxxxxx before sending.
  Future<Map<String, dynamic>> requestReset(String phone) async {
    // Clear any previous session
    clearSession();

    // Normalize to +20XXXXXXXXXX (same as React frontend)
    final normalised = PhoneHelper.normalizeEgyptPhone(phone);
    final bodyJson = '{"phone_number":"$normalised"}';
    final url = '${ApiConstants.baseUrl}${ApiConstants.passwordResetRequest}';

    debugPrint('🔑 Password Reset - Input: "$phone" → Sending: "$normalised"');
    debugPrint('🔑 Password Reset - URL: $url');
    debugPrint('🔑 Password Reset - Body: $bodyJson');

    try {
      // Use dart:io HttpClient directly (same as browser fetch)
      final httpClient = HttpClient();
      httpClient.connectionTimeout = const Duration(seconds: 10);

      final request = await httpClient.postUrl(Uri.parse(url));
      request.headers.set('Content-Type', 'application/json');
      request.write(bodyJson);

      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();

      debugPrint('🔑 Password Reset - Status: ${response.statusCode}');
      debugPrint('🔑 Password Reset - Response Headers: ${response.headers}');
      debugPrint('🔑 Password Reset - Response: $responseBody');

      httpClient.close();

      Map<String, dynamic> data = {};
      try {
        data = json.decode(responseBody) as Map<String, dynamic>;
      } catch (_) {}

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? L10nForgotPassword.aVerificationCodeHas.tr(),
          'expires_in': data['expires_in_seconds'] ?? 300,
          'user_email': data['user_email'],
          'phone': normalised,
        };
      }

      // Handle specific error codes (matching React frontend logic)
      switch (response.statusCode) {
        case 400:
          return {'success': false, 'message': L10nForgotPassword.invalidPhoneNumberFormat.tr()};
        case 404:
          return {'success': false, 'message': L10nForgotPassword.thereIsNoAccount.tr()};
        case 429:
          return {'success': false, 'message': L10nForgotPassword.tooManyRequestsWait.tr()};
        case 500:
          // Backend returns 500 instead of 404 for non-existent accounts
          return {'success': false, 'message': L10nForgotPassword.thereIsNoAccount.tr()};
        case 503:
          return {'success': false, 'message': L10nForgotPassword.whatsappServiceIsCurrently.tr()};
        default:
          return {'success': false, 'message': data['message'] ?? L10nForgotPassword.failedToSendVerification.tr()};
      }
    } catch (e) {
      debugPrint('🔑 Password Reset - Exception: $e');
      return {'success': false, 'message': L10nBooking.anUnexpectedErrorOccurred.tr()};
    }
  }

  // ── Step 2: Verify OTP ──────────────────────────────────────────────────

  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final normalised = PhoneHelper.normalizeEgyptPhone(phone);
    try {
      final res = await _dio.post(
        ApiConstants.passwordResetVerifyOtp,
        data: {
          'phone_number': normalised,
          'otp': otp,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data is Map ? res.data as Map : {};
        return {
          'success': true,
          'message': data['message'] ??
              L10nForgotPassword.verificationCompletedSuccessfullyYou.tr(),
          'session_expires_in': data['session_expires_in_minutes'] ?? 10,
        };
      }

      // Handle specific error codes from API docs
      switch (res.statusCode) {
        case 400:
          return {
            'success': false,
            'message': L10nForgotPassword.theVerificationCodeIs1.tr()
          };
        case 404:
          return {
            'success': false,
            'message': L10nForgotPassword.aVerificationCodeWas.tr()
          };
        case 410:
          return {
            'success': false,
            'message': L10nForgotPassword.theVerificationCodeHas.tr()
          };
        case 429:
          return {
            'success': false,
            'message':
                L10nForgotPassword.youHaveExceededThe.tr()
          };
        default:
          return _errorFromResponse(res, L10nForgotPassword.theVerificationCodeIs.tr());
      }
    } on DioException catch (e) {
      return _dioError(e);
    } catch (e) {
      return {'success': false, 'message': L10nBooking.anUnexpectedErrorOccurred.tr()};
    }
  }

  // ── Step 3: Change Password ─────────────────────────────────────────────

  Future<Map<String, dynamic>> changePassword({
    required String phone,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      return {'success': false, 'message': L10nForgotPassword.theTwoPasswordsDo.tr()};
    }
    if (newPassword.length < 6) {
      return {
        'success': false,
        'message': L10nForgotPassword.passwordMustBeAt.tr()
      };
    }

    final normalised = PhoneHelper.normalizeEgyptPhone(phone);
    try {
      final res = await _dio.post(
        ApiConstants.passwordResetChange,
        data: {
          'phone_number': normalised,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        },
      );

      if (res.statusCode == 200) {
        final data = res.data is Map ? res.data as Map : {};
        return {
          'success': true,
          'message': data['message'] ?? L10nForgotPassword.thePasswordHasBeen.tr(),
        };
      }

      // Handle specific error codes from API docs
      switch (res.statusCode) {
        case 400:
          return {
            'success': false,
            'message': L10nForgotPassword.invalidDataCheckInput.tr()
          };
        case 401:
          return {'success': false, 'message': L10nForgotPassword.youMustCheckThe.tr()};
        case 403:
          return {
            'success': false,
            'message': L10nForgotPassword.youMustVerifyThe.tr()
          };
        case 404:
          return {'success': false, 'message': L10nForgotPassword.thereIsNoAccount.tr()};
        case 410:
          return {
            'success': false,
            'message': L10nForgotPassword.theSessionHasExpired.tr()
          };
        case 429:
          return {
            'success': false,
            'message': L10nForgotPassword.tooManyRequestsWait.tr()
          };
        default:
          return _errorFromResponse(res, L10nForgotPassword.failedToChangePassword.tr());
      }
    } on DioException catch (e) {
      return _dioError(e);
    } catch (e) {
      return {'success': false, 'message': L10nBooking.anUnexpectedErrorOccurred.tr()};
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Map<String, dynamic> _errorFromResponse(Response res, String fallback) {
    // Try to read the server's own message first
    String? serverMsg;
    final data = res.data;
    if (data is Map) {
      serverMsg =
          (data['message'] ?? data['error'] ?? data['detail'])?.toString();
    } else if (data is String && data.isNotEmpty) {
      serverMsg = data;
    }

    // If server returns a generic internal error, we ignore it and use our Arabic message
    if (serverMsg != null &&
        (serverMsg.toLowerCase().contains('internal error') ||
            serverMsg.toLowerCase().contains('server error'))) {
      serverMsg = null;
    }

    // Only use hardcoded Arabic if the server returned nothing useful
    final bool hasServerMsg = serverMsg != null && serverMsg.isNotEmpty;
    String msg = hasServerMsg ? serverMsg : fallback;

    if (!hasServerMsg) {
      switch (res.statusCode) {
        case 400:
          msg = L10nForgotPassword.invalidDataPleaseCheck.tr();
          break;
        case 404:
          msg = L10nForgotPassword.thereIsNoAccount.tr();
          break;
        case 410:
          msg = L10nForgotPassword.theVerificationCodeHas1.tr();
          break;
        case 429:
          msg = L10nForgotPassword.tooManyRequestsWait.tr();
          break;
        case 403:
          msg = L10nForgotPassword.youMustCheckThe.tr();
          break;
        case 500:
          msg = L10nForgotPassword.thereIsNoAccount.tr();
          break;
        default:
          break;
      }
    }

    return {'success': false, 'message': msg, 'statusCode': res.statusCode};
  }

  Map<String, dynamic> _dioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return {
        'success': false,
        'message': L10nForgotPassword.connectionTimedOutCheck.tr()
      };
    }
    if (e.type == DioExceptionType.connectionError) {
      return {'success': false, 'message': L10nForgotPassword.unableToConnectTo.tr()};
    }
    return {'success': false, 'message': L10nForgotPassword.aNetworkErrorHas.tr()};
  }
}
