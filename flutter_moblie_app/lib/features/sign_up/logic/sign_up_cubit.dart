import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final Dio _dio = DioFactory.getDio();
  static const String _baseUrl = 'http://13.53.131.167:5000';

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

      // Prepare the request data
      final requestData = {
        'email': email.trim().toLowerCase(),
        'password': password,
        'confirm_password': password,
        if (firstName != null && firstName.isNotEmpty) 'first_name': firstName,
        if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (college != null && college.isNotEmpty) 'faculty': college,
        if (studyYear != null && studyYear.isNotEmpty) 'year': studyYear,
        if (governorate != null && governorate.isNotEmpty) 'governorate': governorate,
        if (category != null && category.isNotEmpty) 'category': category, // Add this
      };

      print('Request data: $requestData');

      final response = await _dio.post(
        '$_baseUrl/register',
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
        emit(SignUpSuccess('تم إنشاء الحساب بنجاح'));
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

