import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:thoutha_mobile_app/core/helpers/phone_helper.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';
import 'package:thoutha_mobile_app/core/networking/otp_service.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:thoutha_mobile_app/core/localization/l10n_keys.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final OtpService _otpService = OtpService();

  SignUpCubit() : super(SignUpInitial());

  Future<void> signUp({
    required String email,
    required String password,
    String? firstName,
    String? lastName,
    String? phone,
    String? college,
    String? studyYear,
    String? governorate,
    String? category,
    String? confirmPassword,
  }) async {
    try {
      emit(SignUpLoading());

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        emit(SignUpError(L10nSignUp.emailAndPasswordAre.tr()));
        return;
      }

      if (password.length < 6) {
        emit(SignUpError(L10nLogin.passwordMustBeAt.tr()));
        return;
      }

      // Normalize phone number using PhoneHelper (no + prefix)
      String? formattedPhone =
          phone != null ? PhoneHelper.normalizeEgyptPhone(phone) : null;

      // Create a fresh Dio instance WITHOUT Authorization header
      // This ensures NO Bearer token is sent for signup
      final authDio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
          connectTimeout: Duration(seconds: 15),
          receiveTimeout: Duration(seconds: 15),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      // Prepare the request data with correct field names matching backend
      // IMPORTANT: Send NAMES (strings), NOT IDs (integers)
      final requestData = {
        'email': email.trim().toLowerCase(),
        'password': password.trim(),
        if (firstName != null && firstName.trim().isNotEmpty)
          'firstName': firstName.trim(),
        if (lastName != null && lastName.trim().isNotEmpty)
          'lastName': lastName.trim(),
        if (formattedPhone != null) 'phoneNumber': formattedPhone,
        if (college != null && college.trim().isNotEmpty)
          'universityName': college.trim(),
        if (studyYear != null && studyYear.trim().isNotEmpty)
          'studyYear': studyYear.trim(),
        if (governorate != null && governorate.trim().isNotEmpty)
          'cityName': governorate.trim(),
        if (category != null && category.trim().isNotEmpty)
          'categoryName': category.trim(),
        if (confirmPassword != null && confirmPassword.trim().isNotEmpty) ...{
          'confirmPassword': confirmPassword.trim(),
          'confirm_password': confirmPassword.trim(),
        }
      };

      debugPrint('✅ SignUp Request URL: ${ApiConstants.baseUrl}/api/auth/signup');
      debugPrint('✅ SignUp Request Data: $requestData');
      debugPrint(
          '✅ SignUp Headers: Content-Type=application/json (NO Authorization)');

      // Send POST request WITHOUT Authorization header
      final response = await authDio.post(
        '/api/auth/signup',
        data: requestData,
      );

      debugPrint('✅ SignUp Response Status: ${response.statusCode}');
      debugPrint('✅ SignUp Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Extract token from response
        String? token;
        if (response.data is Map) {
          token = response.data['token'] ?? response.data['accessToken'];
        }

        // Signup successful, now send OTP to phone number
        if (formattedPhone != null) {
          final otpResult = await _otpService.sendOtp(formattedPhone);

          if (otpResult['success']) {
            emit(SignUpOtpSent(
              phoneNumber: formattedPhone,
              email: email.trim(),
              message: otpResult['message'] ?? L10nSignUp.verificationCodeHasBeen.tr(),
            ));
          } else {
            emit(SignUpError(
              L10nSignUp.theAccountWasCreated.tr(),
            ));
          }
        } else {
          // No phone number, just emit success
          emit(SignUpSuccess(token ?? '', message: L10nSignUp.registrationCompletedSuccessfully.tr()));
        }
      } else {
        // Handle error responses
        String errorMessage = L10nSignUp.anErrorOccurredIn.tr();

        if (response.data != null) {
          if (response.data is List) {
            // Backend returns array of errors
            final errors = response.data as List;
            if (errors.isNotEmpty) {
              // Check if error is about email or phone
              String errorText = errors
                  .map((e) => e['messageAr'] ?? e['messageEn'] ?? '')
                  .where((msg) => msg.isNotEmpty)
                  .join('\n');

              // Detect email duplicate
              if (errorText.contains('email') ||
                  errorText.contains(L10nSignUp.mail.tr()) ||
                  errorText.contains('Email') ||
                  errorText.contains(L10nSignUp.mail1.tr()) ||
                  errorText.contains(L10nSignUp.existing.tr()) ||
                  errorText.contains(L10nSignUp.user.tr()) ||
                  errorText.contains(L10nSignUp.registered.tr()) ||
                  errorText.contains(L10nSignUp.repetition.tr())) {
                errorMessage = L10nSignUp.thisEmailIsAlready.tr();
              }
              // Detect phone duplicate
              else if (errorText.contains('phone') ||
                  errorText.contains(L10nSignUp.telephone.tr()) ||
                  errorText.contains('Phone') ||
                  errorText.contains(L10nSignUp.phone.tr()) ||
                  errorText.contains(L10nSignUp.number.tr()) ||
                  errorText.contains(L10nDoctor.phoneNumber.tr()) ||
                  errorText.contains('phoneNumber')) {
                errorMessage = L10nSignUp.thePhoneNumberIs.tr();
              } else {
                errorMessage = errorText;
              }
            }
          } else if (response.data is Map) {
            final responseMap = response.data as Map;
            String rawMessage = responseMap['messageAr'] ??
                responseMap['messageEn'] ??
                responseMap['message'] ??
                responseMap['error'] ??
                L10nSignUp.anErrorOccurredIn.tr();

            // Detect email duplicate
            if (rawMessage.contains('email') ||
                rawMessage.contains(L10nSignUp.mail.tr()) ||
                rawMessage.contains('Email') ||
                rawMessage.contains(L10nSignUp.mail1.tr()) ||
                rawMessage.contains(L10nSignUp.user.tr()) ||
                rawMessage.contains(L10nSignUp.existing.tr()) ||
                rawMessage.contains(L10nSignUp.registered.tr()) ||
                rawMessage.contains(L10nSignUp.repetition.tr()) ||
                rawMessage.contains(L10nSignUp.find.tr()) ||
                rawMessage.contains(L10nSignUp.supplier.tr())) {
              errorMessage = L10nSignUp.thisEmailIsAlready.tr();
            }
            // Detect phone duplicate
            else if (rawMessage.contains('phone') ||
                rawMessage.contains(L10nSignUp.telephone.tr()) ||
                rawMessage.contains('Phone') ||
                rawMessage.contains(L10nSignUp.phone.tr()) ||
                rawMessage.contains(L10nSignUp.number.tr()) ||
                rawMessage.contains(L10nDoctor.phoneNumber.tr()) ||
                rawMessage.contains('phoneNumber')) {
              errorMessage = L10nSignUp.thePhoneNumberIs.tr();
            } else {
              errorMessage = rawMessage;
            }
          }
        }

        // Status code 409 also means conflict (duplicate)
        if (response.statusCode == 409) {
          // Try to determine if it's email or phone from previous attempts
          // Default to email since it's more common
          errorMessage = L10nSignUp.thisEmailIsAlready.tr();
        }

        // If message contains "No static resource found" or similar, it's likely a duplicate email
        if (errorMessage.contains(L10nSignUp.staticResourceNotFound.tr()) ||
            errorMessage.contains('No static resource found') ||
            errorMessage.contains(L10nDoctor.fixedResource.tr())) {
          errorMessage = L10nSignUp.thisEmailIsAlready.tr();
        }

        emit(SignUpError(errorMessage));
      }
    } on DioException catch (e) {
      String errorMessage = L10nSignUp.anErrorOccurredConnecting.tr();

      if (e.response != null) {
        if (e.response!.data is List) {
          final errors = e.response!.data as List;
          if (errors.isNotEmpty) {
            // Check if error is about email or phone
            String errorText = errors
                .map((e) => e['messageAr'] ?? e['messageEn'] ?? '')
                .where((msg) => msg.isNotEmpty)
                .join('\n');

            // Detect email duplicate
            if (errorText.contains('email') ||
                errorText.contains(L10nSignUp.mail.tr()) ||
                errorText.contains('Email') ||
                errorText.contains(L10nSignUp.mail1.tr()) ||
                errorText.contains(L10nSignUp.existing.tr()) ||
                errorText.contains(L10nSignUp.user.tr()) ||
                errorText.contains(L10nSignUp.registered.tr()) ||
                errorText.contains(L10nSignUp.repetition.tr())) {
              errorMessage = L10nSignUp.thisEmailIsAlready.tr();
            }
            // Detect phone duplicate
            else if (errorText.contains('phone') ||
                errorText.contains(L10nSignUp.telephone.tr()) ||
                errorText.contains('Phone') ||
                errorText.contains(L10nSignUp.phone.tr()) ||
                errorText.contains(L10nSignUp.number.tr()) ||
                errorText.contains(L10nDoctor.phoneNumber.tr()) ||
                errorText.contains('phoneNumber')) {
              errorMessage = L10nSignUp.thePhoneNumberIs.tr();
            } else {
              errorMessage = errorText;
            }
          }
        } else if (e.response!.data is Map) {
          final responseMap = e.response!.data as Map;
          String rawMessage = responseMap['messageAr'] ??
              responseMap['messageEn'] ??
              responseMap['message'] ??
              L10nSignUp.invalidData.tr();

          // Detect email duplicate
          if (rawMessage.contains('email') ||
              rawMessage.contains(L10nSignUp.mail.tr()) ||
              rawMessage.contains('Email') ||
              rawMessage.contains(L10nSignUp.mail1.tr()) ||
              rawMessage.contains(L10nSignUp.user.tr()) ||
              rawMessage.contains(L10nSignUp.existing.tr()) ||
              rawMessage.contains(L10nSignUp.registered.tr()) ||
              rawMessage.contains(L10nSignUp.repetition.tr()) ||
              rawMessage.contains(L10nSignUp.find.tr()) ||
              rawMessage.contains(L10nSignUp.supplier.tr())) {
            errorMessage = L10nSignUp.thisEmailIsAlready.tr();
          }
          // Detect phone duplicate
          else if (rawMessage.contains('phone') ||
              rawMessage.contains(L10nSignUp.telephone.tr()) ||
              rawMessage.contains('Phone') ||
              rawMessage.contains(L10nSignUp.phone.tr()) ||
              rawMessage.contains(L10nSignUp.number.tr()) ||
              rawMessage.contains(L10nDoctor.phoneNumber.tr()) ||
              rawMessage.contains('phoneNumber')) {
            errorMessage = L10nSignUp.thePhoneNumberIs.tr();
          } else {
            errorMessage = rawMessage;
          }
        }

        // Status code 409 also means conflict (duplicate)
        if (e.response!.statusCode == 409) {
          errorMessage = L10nSignUp.thisEmailIsAlready.tr();
        }

        // If message contains "No static resource found" or similar, it's likely a duplicate email
        if (errorMessage.contains(L10nSignUp.staticResourceNotFound.tr()) ||
            errorMessage.contains('No static resource found') ||
            errorMessage.contains(L10nDoctor.fixedResource.tr())) {
          errorMessage = L10nSignUp.thisEmailIsAlready.tr();
        }
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = L10nSignUp.theConnectionToThe.tr();
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = L10nSignUp.noInternetConnection.tr();
      }

      emit(SignUpError(errorMessage));
    } catch (e) {
      emit(SignUpError('حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }
}
