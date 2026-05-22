import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thoutha_mobile_app/core/helpers/phone_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:thoutha_mobile_app/core/networking/dio_factory.dart';
import 'package:thoutha_mobile_app/core/networking/connectivity_service.dart';
import 'dart:async';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

class OtpService {
  final Dio _dio = DioFactory.getDio();
  final ConnectivityService _connectivityService = ConnectivityService();
  static const int _maxRetries = 3;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _requestTimeout = Duration(seconds: 30);
  bool _isInitialized = false;

  /// Initialize the OTP service
  Future<void> initialize() async {
    if (!_isInitialized) {
      await _connectivityService.initialize();
      _isInitialized = true;
    }
  }

  /// Send OTP to the provided phone number with retry mechanism
  ///
  /// [phoneNumber] should be in international format: +20XXXXXXXXXX
  /// [retryCount] current retry attempt (used internally)
  ///
  /// Returns a Map with:
  /// - 'success': true/false
  /// - 'message': success/error message
  /// - 'retryable': true if request can be retried
  Future<Map<String, dynamic>> sendOtp(String phoneNumber,
      {int retryCount = 0}) async {
    try {
      // Ensure service is initialized
      await initialize();

      // Check connectivity first
      if (!_connectivityService.isConnected) {
        final hasConnection = await _connectivityService.waitForConnectivity();
        if (!hasConnection) {
          return {
            'success': false,
            'error':
                L10nCore.noInternetConnectionPlease.tr(),
            'retryable': true,
          };
        }
      }

      // Validate phone number format before sending
      final validationResult = _validatePhoneNumber(phoneNumber);
      if (!validationResult['valid']) {
        return {
          'success': false,
          'error': validationResult['error'],
          'retryable': false,
        };
      }

      // Ensure phone number doesn't start with + for the API
      final String formattedPhone =
          PhoneHelper.normalizeEgyptPhone(phoneNumber);

      debugPrint('Sending OTP to: $formattedPhone');

      final response = await _dio.post(
        '${ApiConstants.otpBaseUrl}${ApiConstants.sendOtp}',
        data: {
          'phone_number': formattedPhone,
          'otp': '',
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
          sendTimeout: _requestTimeout,
          receiveTimeout: _requestTimeout,
        ),
      );

      debugPrint('Send OTP Response Status: ${response.statusCode}');
      debugPrint('Send OTP Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? L10nCore.verificationCodeSentSuccessfully.tr(),
          'retryable': false,
        };
      } else {
        String errorMessage = L10nCore.failedToSendVerification.tr();
        bool retryable = true;

        if (response.data != null) {
          if (response.data is Map) {
            errorMessage = response.data['message'] ??
                response.data['error'] ??
                errorMessage;
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }

        // Determine if error is retryable
        if (response.statusCode == 400) {
          retryable = false; // Bad request - don't retry
        } else if (response.statusCode == 429) {
          retryable = true; // Rate limit - can retry with delay
        }

        // Retry logic
        if (retryable && retryCount < _maxRetries) {
          debugPrint('Retrying OTP send... Attempt ${retryCount + 1}/$_maxRetries');
          await Future.delayed(_calculateBackoff(retryCount));
          return sendOtp(phoneNumber, retryCount: retryCount + 1);
        }

        return {
          'success': false,
          'error': errorMessage,
          'retryable': retryable && retryCount < _maxRetries,
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in sendOtp: ${e.message}');

      // Retry logic for network errors
      if (retryCount < _maxRetries && _isRetryableError(e)) {
        debugPrint(
            'Retrying OTP send due to network error... Attempt ${retryCount + 1}/$_maxRetries');
        await Future.delayed(_calculateBackoff(retryCount));
        return sendOtp(phoneNumber, retryCount: retryCount + 1);
      }

      return {
        'success': false,
        'error': _handleDioError(e),
        'retryable': false,
      };
    } catch (e) {
      debugPrint('Exception in sendOtp: ${e.toString()}');
      return {
        'success': false,
        'error': L10nCore.anUnexpectedErrorOccurred.tr(),
        'retryable': false,
      };
    }
  }

  /// Verify the OTP code with retry mechanism
  ///
  /// [phoneNumber] should be in international format: +20XXXXXXXXXX
  /// [otp] is the 6-digit code received via SMS
  /// [retryCount] current retry attempt (used internally)
  ///
  /// Returns a Map with:
  /// - 'success': true/false
  /// - 'message': success/error message
  /// - 'retryable': true if request can be retried
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp,
      {int retryCount = 0}) async {
    try {
      // Ensure service is initialized
      await initialize();

      // Check connectivity first
      if (!_connectivityService.isConnected) {
        final hasConnection = await _connectivityService.waitForConnectivity();
        if (!hasConnection) {
          return {
            'success': false,
            'error':
                L10nCore.noInternetConnectionPlease.tr(),
            'retryable': true,
          };
        }
      }

      // Validate inputs
      final validationResult = _validateOtpInputs(phoneNumber, otp);
      if (!validationResult['valid']) {
        return {
          'success': false,
          'error': validationResult['error'],
          'retryable': false,
        };
      }

      // Ensure phone number doesn't start with + for the API
      final String formattedPhone =
          PhoneHelper.normalizeEgyptPhone(phoneNumber);

      debugPrint('Verifying OTP: $otp for phone: $formattedPhone');

      final response = await _dio.post(
        '${ApiConstants.otpBaseUrl}${ApiConstants.verifyOtp}',
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
          sendTimeout: _requestTimeout,
          receiveTimeout: _requestTimeout,
        ),
      );

      debugPrint('Verify OTP Response Status: ${response.statusCode}');
      debugPrint('Verify OTP Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': response.data['message'] ?? L10nCore.verifiedSuccessfully.tr(),
          'data': response.data,
          'retryable': false,
        };
      } else {
        String errorMessage = L10nCore.theVerificationCodeIs.tr();
        bool retryable = false;

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
          errorMessage = L10nCore.theVerificationCodeIs.tr();
          retryable = false;
        } else if (response.statusCode == 404) {
          errorMessage = L10nCore.verificationCodeNotFound.tr();
          retryable = false;
        } else if (response.statusCode == 410 || response.statusCode == 408) {
          errorMessage = L10nCore.theVerificationCodeHas.tr();
          retryable = false;
        }

        // Retry logic for server errors
        if (retryable && retryCount < _maxRetries) {
          debugPrint(
              'Retrying OTP verify... Attempt ${retryCount + 1}/$_maxRetries');
          await Future.delayed(_calculateBackoff(retryCount));
          return verifyOtp(phoneNumber, otp, retryCount: retryCount + 1);
        }

        return {
          'success': false,
          'error': errorMessage,
          'retryable': retryable && retryCount < _maxRetries,
        };
      }
    } on DioException catch (e) {
      debugPrint('DioException in verifyOtp: ${e.message}');

      // Retry logic for network errors
      if (retryCount < _maxRetries && _isRetryableError(e)) {
        debugPrint(
            'Retrying OTP verify due to network error... Attempt ${retryCount + 1}/$_maxRetries');
        await Future.delayed(_calculateBackoff(retryCount));
        return verifyOtp(phoneNumber, otp, retryCount: retryCount + 1);
      }

      return {
        'success': false,
        'error': _handleDioError(e),
        'retryable': false,
      };
    } catch (e) {
      debugPrint('Exception in verifyOtp: ${e.toString()}');
      return {
        'success': false,
        'error': L10nCore.anUnexpectedErrorOccurred.tr(),
        'retryable': false,
      };
    }
  }

  /// Validate phone number format
  Map<String, dynamic> _validatePhoneNumber(String phoneNumber) {
    if (phoneNumber.isEmpty) {
      return {
        'valid': false,
        'error': L10nCore.phoneNumberRequired.tr(),
      };
    }

    // Extract only digits
    final digitsOnly = phoneNumber.trim().replaceAll(RegExp(r'[^0-9]'), '');

    // Accept 10-12 digit numbers (all valid Egyptian phone formats)
    // - 10 digits: base Egyptian number (1001234567)
    // - 11 digits: Egyptian with leading 0 (01001234567)
    // - 12 digits: International format (201001234567)
    if (digitsOnly.length >= 10 && digitsOnly.length <= 12) {
      // Must start with 0, 1, or 2 (Egyptian prefix patterns)
      if (digitsOnly.startsWith('0') ||
          digitsOnly.startsWith('1') ||
          digitsOnly.startsWith('2')) {
        return {'valid': true};
      }
    }

    return {
      'valid': false,
      'error': L10nCore.invalidPhoneNumberIt.tr(),
    };
  }

  /// Validate OTP inputs
  Map<String, dynamic> _validateOtpInputs(String phoneNumber, String otp) {
    if (phoneNumber.isEmpty) {
      return {
        'valid': false,
        'error': L10nCore.phoneNumberRequired.tr(),
      };
    }

    if (otp.isEmpty) {
      return {
        'valid': false,
        'error': L10nCore.verificationCodeRequired.tr(),
      };
    }

    if (otp.length != 6) {
      return {
        'valid': false,
        'error': L10nCore.verificationCodeMustBe.tr(),
      };
    }

    if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
      return {
        'valid': false,
        'error': L10nCore.theVerificationCodeMust.tr(),
      };
    }

    return {'valid': true};
  }

  /// Calculate exponential backoff delay
  Duration _calculateBackoff(int retryCount) {
    return Duration(
        milliseconds: _baseDelay.inMilliseconds * (1 << retryCount));
  }

  /// Check if error is retryable
  bool _isRetryableError(DioException e) {
    return e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError ||
        (e.response?.statusCode != null && e.response!.statusCode! >= 500);
  }

  String _handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return L10nCore.theConnectionTimedOut1.tr();
    } else if (e.type == DioExceptionType.connectionError) {
      return L10nCore.failedToConnectTo.tr();
    } else if (e.response?.statusCode == 400) {
      return e.response?.data?['message'] ?? L10nCore.incorrectData.tr();
    } else if (e.response?.statusCode == 401) {
      return L10nCore.unauthorized.tr();
    } else if (e.response?.statusCode == 404) {
      return L10nCore.theServiceIsNot.tr();
    } else if (e.response?.statusCode == 500) {
      return L10nCore.serverError.tr();
    }
    return L10nCore.anUnexpectedErrorOccurred.tr();
  }
}
