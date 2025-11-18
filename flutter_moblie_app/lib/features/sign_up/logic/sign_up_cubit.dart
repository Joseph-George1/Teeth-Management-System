import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:meta/meta.dart';
import 'package:thotha_mobile_app/core/networking/dio_factory.dart';

part 'sign_up_state.dart';

class SignUpCubit extends Cubit<SignUpState> {
  final Dio _dio = DioFactory.getDio();
  static const String _baseUrl = 'http://13.49.221.187:5000';

  SignUpCubit() : super(SignUpInitial());

  Future<void> signUp({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String userType,
  }) async {
    try {
      emit(SignUpLoading());

      // Basic validation
      if (email.isEmpty || password.isEmpty) {
        emit(SignUpError('البريد الإلكتروني وكلمة المرور مطلوبان'));
        return;
      }

      if (!RegExp(r'^[^@]+@[^\s]+\.[^\s]+$').hasMatch(email)) {
        emit(SignUpError('الرجاء إدخال بريد إلكتروني صالح'));
        return;
      }

      if (password.length < 6) {
        emit(SignUpError('يجب أن تكون كلمة المرور 6 أحرف على الأقل'));
        return;
      }

      // Call the registration API
      final response = await _dio.post(
        '$_baseUrl/register',
        data: {
          'email': email.trim(),
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        emit(SignUpSuccess('تم إنشاء الحساب بنجاح'));
      } else {
        // Handle different error status codes
        String errorMessage = 'حدث خطأ في التسجيل';
        if (response.statusCode == 400) {
          errorMessage = response.data?['message'] ?? 'بيانات غير صالحة';
        } else if (response.statusCode == 409) {
          errorMessage = 'هذا البريد الإلكتروني مسجل مسبقاً';
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
