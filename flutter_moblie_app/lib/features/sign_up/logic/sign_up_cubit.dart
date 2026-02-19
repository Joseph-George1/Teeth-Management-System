import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';
import 'package:thotha_mobile_app/core/networking/otp_service.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final Dio _dio = DioFactory.getDio();
  static const String _baseUrl = 'https://thoutha.page';

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
    String? category, // Add this
  }) async {
    try {
      emit(SignUpLoading());

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        emit(SignUpError('البريد الإلكتروني وكلمة المرور مطلوبان'));
        return;
      }

      /* if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(email)) {
        emit(SignUpError('الرجاء إدخال بريد إلكتروني صالح'));
        return;
      }*/

      if (password.length < 6) {
        emit(SignUpError('يجب أن تكون كلمة المرور 6 أحرف على الأقل'));
        return;
      }

      // Call the registration API
      print('Sending sign-up request with email: ${email.trim()} and password: $password');

      // Prepare the request data with new field names
      final requestData = {
        'email': email.trim().toLowerCase(),
        'password': password,
        if (firstName != null && firstName.isNotEmpty) 'firstName': firstName,
        if (lastName != null && lastName.isNotEmpty) 'lastName': lastName,
        if (phone != null && phone.isNotEmpty) 'phoneNumber': phone,
        if (college != null && college.isNotEmpty) 'universtyName': college,
        if (studyYear != null && studyYear.isNotEmpty) 'studyYear': studyYear,
        if (governorate != null && governorate.isNotEmpty) 'cityName': governorate,
        if (category != null && category.isNotEmpty) 'categoryName': category,
      };

      print('Request data: $requestData');

      final response = await _dio.post(
        '$_baseUrl/api/auth/signup',
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');

      print('API Response Status: ${response.statusCode}');
      print('API Response Data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Signup successful, now send OTP to phone number
        print('Signup successful, sending OTP to phone: $phone');
        
        // Format phone number with country code
        String formattedPhone = phone ?? '';
        if (formattedPhone.isNotEmpty && !formattedPhone.startsWith('+')) {
          formattedPhone = '+20$formattedPhone'; // Assuming Egypt +20
        }
        
        // Send OTP
        final otpResult = await _otpService.sendOtp(formattedPhone);
        
        if (otpResult['success']) {
          // OTP sent successfully, navigate to OTP verification
          emit(SignUpOtpSent(
            phoneNumber: formattedPhone,
            email: email.trim(),
            message: otpResult['message'] ?? 'تم إرسال رمز التحقق',
          ));
        } else {
          // OTP send failed, but signup was successful
          // You can either emit an error or navigate to login
          emit(SignUpError(
            'تم إنشاء الحساب لكن فشل إرسال رمز التحقق. يرجى تسجيل الدخول.',
          ));
        }
      } else {
        // Handle different error status codes
        String errorMessage = 'حدث خطأ في التسجيل';
        if (response.data != null) {
          if (response.data is Map) {
            errorMessage = response.data['message'] ??
                response.data['error'] ??
                'حدث خطأ في التسجيل';
          } else if (response.data is String) {
            errorMessage = response.data;
          }
        }

        // Common error messages
        if (response.statusCode == 400) {
          errorMessage = 'بيانات غير صالحة: $errorMessage';
        } else if (response.statusCode == 409) {
          errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً';
        } else if (response.statusCode == 422) {
          errorMessage = 'بيانات غير صالحة: $errorMessage';
        }

        emit(SignUpError(errorMessage));
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      String errorMessage = 'حدث خطأ في الاتصال بالخادم';
      if (e.response?.statusCode == 400) {
        errorMessage = e.response?.data?['message'] ?? 'بيانات غير صالحة';
      } else if (e.response?.statusCode == 409) {
        errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً';
      } else if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        errorMessage = 'انتهت مهلة الاتصال بالخادم';
      } else if (e.type == DioExceptionType.unknown) {
        errorMessage = 'لا يوجد اتصال بالإنترنت';
      }
      emit(SignUpError(errorMessage));
    } catch (e) {
      emit(SignUpError('حدث خطأ غير متوقع'));
    }
  }}

