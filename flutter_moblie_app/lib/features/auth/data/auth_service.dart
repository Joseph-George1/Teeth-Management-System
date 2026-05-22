import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:thoutha_mobile_app/core/helpers/constants.dart';
import 'package:thoutha_mobile_app/core/helpers/shared_pref_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:thoutha_mobile_app/core/networking/api_service.dart';
import 'package:thoutha_mobile_app/core/networking/dio_factory.dart';
import 'package:thoutha_mobile_app/core/services/firebase_messaging_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';
import 'package:flutter/foundation.dart';
class AuthService {
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
          'error': L10nAuth.emailAndPasswordAre.tr(),
          'statusCode': 400,
        };
      }

      // Get FCM token to send with login request
      final fcmToken = await SharedPrefHelper.getString(SharedPrefKeys.fcmToken);

      // Make the API request
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/api/auth/login/doctor',
        data: {
          'email': email.trim(),
          'password': password,
          if (fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) =>
              status! < 500, // Handle 4xx errors manually
        ),
      );

      // Handle successful response
      if (response.statusCode == 200) {
        // Prefer token from API when available, otherwise generate
        // one compatible with the Flask backend (base64(email)).
        String? token = response.data['token'];
        if (token == null || token.isEmpty) {
          token = base64Encode(utf8.encode(email.trim()));
        }

        // Save token securely and set header for subsequent requests
        await SharedPrefHelper.setSecuredString(
            SharedPrefKeys.userToken, token);
        DioFactory.setTokenIntoHeaderAfterLogin(token);

        // Always save the email used for login to support fallback
        await SharedPrefHelper.setData('email', email);

        int? doctorId;

        // Try to persist user's name/email from the login response if available
        try {
          final data = response.data;

          // ── DIAGNOSTIC LOG ────────────────────────────────────────────────
          // Print the FULL login response so we can see the exact JSON keys.
          // Check your logcat/debug console for this line after logging in.
          log('🔍 LOGIN RESPONSE FULL DATA: ${jsonEncode(data)}',
              name: 'AuthService');
          // ─────────────────────────────────────────────────────────────────

          String? f;
          String? l;
          String? e;
          String? p;
          String? y;
          String? g;
          String? fa;
          String? c;

          if (data is Map) {
            // Common shapes: top-level or nested under 'user' / 'doctor' / 'data'
            Map? userMap;
            if (data['user'] is Map) {
              userMap = data['user'] as Map;
            } else if (data['doctor'] is Map) {
              userMap = data['doctor'] as Map;
            } else if (data['data'] is Map) {
              userMap = data['data'] as Map;
            } else {
              userMap = data;
            }

            log('🗺️ userMap keys: ${userMap.keys.toList()}',
                name: 'AuthService');

            f = (userMap['first_name'] ?? userMap['firstName']) as String?;
            l = (userMap['last_name'] ?? userMap['lastName']) as String?;
            e = (userMap['email']) as String?;
            p = (userMap['phone'] ?? userMap['tel'])?.toString();
            y = (userMap['year'] ?? userMap['study_year']) as String?;
            g = (userMap['governorate'] ?? userMap['city']) as String?;
            fa = (userMap['faculty'] ?? userMap['college']) as String?;
            c = (userMap['category'] ?? userMap['specialization'])?.toString();

            // Try ALL common id key names
            final id = userMap['id'] ??
                userMap['doctor_id'] ??
                userMap['doctorId'] ??
                userMap['userId'] ??
                userMap['user_id'];

            log('🪪 Raw id value from response: $id (type: ${id.runtimeType})',
                name: 'AuthService');

            // احفظ التوكن في الـ cache أيضاً (بالإضافة للـ secure storage)
            await SharedPrefHelper.setData('auth_token', token);

            if (id != null) {
              doctorId = int.tryParse(id.toString());
              log('✅ doctorId resolved to: $doctorId', name: 'AuthService');
              await SharedPrefHelper.setData('doctor_id', doctorId ?? (id is int ? id : int.tryParse(id.toString()) ?? 0));
            } else {
              log('❌ No id field found in userMap! FCM token will be registered WITHOUT user_id.',
                  name: 'AuthService');
            }

            if (f != null && f.isNotEmpty) {
              await SharedPrefHelper.setData('first_name', f);
              await SharedPrefHelper.setData('last_name', l ?? '');
              if (e != null && e.isNotEmpty) {
                await SharedPrefHelper.setData('email', e);
              }
              if (p != null && p.isNotEmpty) {
                await SharedPrefHelper.setData('phone', p);
              }
              if (y != null && y.isNotEmpty) {
                await SharedPrefHelper.setData('year', y);
              }
              if (g != null && g.isNotEmpty) {
                await SharedPrefHelper.setData('governorate', g);
              }
              if (fa != null && fa.isNotEmpty) {
                await SharedPrefHelper.setData('faculty', fa);
              }
              if (c != null && c.isNotEmpty) {
                await SharedPrefHelper.setData('category', c);
              }
            }
          } else {
            log('⚠️ Login response.data is NOT a Map! Type: ${data.runtimeType}',
                name: 'AuthService');
          }
        } catch (e, st) {
          // Log persistence failures — do NOT silently ignore them
          log('❌ Error parsing login response: $e\n$st', name: 'AuthService');
        }

        // Register FCM token with backend asynchronously (non-blocking)
        log('📲 Calling _registerFcmTokenAsync with doctorId=$doctorId',
            name: 'AuthService');
        _registerFcmTokenAsync(doctorId);

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
        'error': L10nAuth.anUnexpectedErrorOccurred.tr(),
        'statusCode': 500,
      };
    }
  }

  String _getErrorMessage(int? statusCode, dynamic responseData) {
    // استخراج رسالة الخطأ من السيرفر
    final serverMsg = responseData is Map
        ? (responseData['messageAr'] ??
                responseData['messageEn'] ??
                responseData['message'] ??
                responseData['error'] ??
                '')
            .toString()
            .toLowerCase()
        : responseData?.toString().toLowerCase() ?? '';

    switch (statusCode) {
      case 400:
        return L10nAuth.loginDataIsIncorrect.tr();
      case 401:
        // فحص رسالة السيرفر لتحديد هل الخطأ في الباسورد أم الإيميل
        if (serverMsg.contains('password') ||
            serverMsg.contains('incorrect password') ||
            serverMsg.contains('wrong password') ||
            serverMsg.contains('كلمة المرور')) {
          return L10nLogin.incorrectEmailOrPassword.tr(); // كلمة المرور خطأ
        }
        if (serverMsg.contains('email') ||
            serverMsg.contains('user not found') ||
            serverMsg.contains('not found') ||
            serverMsg.contains('بريد') ||
            serverMsg.contains('مستخدم')) {
          return L10nLogin.wrongEmail.tr(); // البريد الإلكتروني غير صحيح
        }
        // افتراضي: خطأ في كلمة المرور
        return L10nLogin.incorrectEmailOrPassword.tr();
      case 403:
        return L10nLogin.incorrectEmailOrPassword.tr(); // كلمة المرور خطأ
      case 404:
        return L10nLogin.wrongEmail.tr(); // البريد الإلكتروني غير صحيح
      case 422:
        // Handle validation errors from the server
        if (responseData is Map && responseData['errors'] != null) {
          return responseData['errors'].values.first[0] ?? L10nAuth.invalidData.tr();
        }
        return L10nAuth.invalidData.tr();
      default:
        return L10nAuth.aServerErrorHas.tr();
    }
  }

  String _handleDioError(DioException e) {
    debugPrint('Dio Error: ${e.message}');
    debugPrint('Error Type: ${e.type}');
    if (e.response != null) {
      debugPrint('Response Status: ${e.response?.statusCode}');
      debugPrint('Response Data: ${e.response?.data}');
    }

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      return L10nAuth.theConnectionToThe.tr();
    } else if (e.type == DioExceptionType.connectionError) {
      return L10nAuth.unableToConnectTo.tr();
    } else if (e.response != null) {
      return _getErrorMessage(e.response?.statusCode, e.response?.data);
    } else {
      return L10nAuth.anUnexpectedErrorOccurred.tr();
    }
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? confirm,
    String? first_name,
    String? last_name,
    String? phone,
    String? faculty,
    String? year,
    String? governorate,
  }) async {
    try {
      final fcmToken = await SharedPrefHelper.getString(SharedPrefKeys.fcmToken);
      
      if (email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'error': L10nAuth.emailAndPasswordAre.tr(),
          'statusCode': 400,
        };
      }

      if (password.length < 6) {
        return {
          'success': false,
          'error': L10nAuth.passwordMustBeAt.tr(),
          'statusCode': 400,
        };
      }

      final response = await _dio.post(
        '${ApiConstants.baseUrl}${ApiConstants.signup}',
        data: {
          'email': email.trim(),
          'password': password,
          if (faculty != null) 'universityName': faculty,
          if (first_name != null) 'firstName': first_name,
          if (last_name != null) 'lastName': last_name,
          if (governorate != null) 'cityName': governorate,
          if (year != null) 'studyYear': year,
          if (phone != null) 'phoneNumber': phone,
          if (confirm != null) 'confirm_password': confirm,
          if (fcmToken.isNotEmpty) 'fcmToken': fcmToken,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Persist provided user info so UI can greet correctly after signup
        try {
          final data = response.data;
          final userMap =
              (data is Map && data['user'] is Map) ? data['user'] : data;
          final id =
              userMap['id'] ?? userMap['doctor_id'] ?? userMap['doctorId'];

          if (id != null) {
            final intId = id is int ? id : int.tryParse(id.toString());
            if (intId != null) {
              await SharedPrefHelper.setData('doctor_id', intId);
            }
          }

          if (first_name != null && first_name.isNotEmpty) {
            await SharedPrefHelper.setData('first_name', first_name);
            if (last_name != null) {
              await SharedPrefHelper.setData('last_name', last_name);
            }
            await SharedPrefHelper.setData('email', email.trim());
            if (phone != null) await SharedPrefHelper.setData('phone', phone);
            if (faculty != null) {
              await SharedPrefHelper.setData('faculty', faculty);
            }
            if (year != null) await SharedPrefHelper.setData('year', year);
            if (governorate != null) {
              await SharedPrefHelper.setData('governorate', governorate);
            }
          }
        } catch (_) {}

        return {
          'success': true,
          'data': response.data,
          'message': L10nAuth.theAccountHasBeen.tr(),
        };
      } else {
        // Handle different error status codes
        String errorMessage = L10nAuth.anErrorOccurredIn.tr();
        if (response.statusCode == 400) {
          errorMessage = response.data?['message'] ?? L10nAuth.invalidData.tr();
        } else if (response.statusCode == 409) {
          errorMessage = L10nAuth.thisEmailIsAlready.tr();
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
        'error': e.response?.data?['message'] ??
            L10nAuth.unableToConnectTo1.tr(),
        'statusCode': e.response?.statusCode,
      };
    } catch (e) {
      return {
        'success': false,
        'error': L10nAuth.anUnexpectedErrorOccurred1.tr(namedArgs: {'var_0': e.toString().toString()}),
      };
    }
  }

  /// Register FCM token with the backend asynchronously.
  /// Does NOT block login flow - runs in background.
  void _registerFcmTokenAsync(int? loginHintId) {
    Future.microtask(() async {
      try {
        int? resolvedId = loginHintId;

        // If the login response didn't give us an ID, fall back to profile API.
        // Use getIt singleton — it has _notificationRepo properly injected.
        if (resolvedId == null) {
          log('ℹ️ No ID from login response — fetching from profile API',
              name: 'AuthService');
          final result = await GetIt.I<ApiService>().getDoctorById();
          if (result['success'] == true && result['data'] != null) {
            try {
              resolvedId = (result['data'] as dynamic).id as int?;
            } catch (_) {}
          }
        }

        if (resolvedId == null) {
          log('❌ Could not resolve user_id — skipping FCM registration (backend requires user_id)',
              name: 'AuthService');
          return;
        }

        log('📲 Registering FCM token with user_id=$resolvedId',
            name: 'AuthService');
        // Use getIt singleton — NOT FirebaseMessagingService() which has no _notificationRepo
        await GetIt.I<FirebaseMessagingService>()
            .registerTokenWithBackend(userId: resolvedId);
      } catch (e) {
        log('❌ Background FCM registration error: $e', name: 'AuthService');
      }
    });
  }
}
