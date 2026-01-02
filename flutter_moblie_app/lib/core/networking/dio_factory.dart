import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../helpers/constants.dart';
import '../helpers/shared_pref_helper.dart';

class DioFactory {
  /// private constructor as I don't want to allow creating an instance of this class
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    Duration timeOut = const Duration(seconds: 60);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut
        ..options.sendTimeout = timeOut
        ..options.baseUrl = 'http://13.49.221.187:5000';
      addDioInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  static void addDioHeaders() async {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    final headers = <String, dynamic>{
      'Accept': 'application/json',
    };
    if (token != null && token is String && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    dio?.options.headers = headers;
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    final existing = dio?.options.headers ?? {};
    dio?.options.headers = {
      // حافظ على Accept لو كان متضبط قبل كده
      'Accept': existing['Accept'] ?? 'application/json',
      ...existing,
      // وحط التوكن
      'Authorization': 'Bearer $token',
    };
  }

  static void addDioInterceptor() {
    dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Get token from secure storage
          final token =
              await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
          print('DEBUG: Interceptor running. Token found: ${token != null}');
          if (token != null && token is String && token.isNotEmpty) {
            print(
                'DEBUG: Injecting token into header: Bearer ${token.substring(0, 5)}...');
            options.headers['Authorization'] = 'Bearer $token';
          } else {
            print('DEBUG: No token found or token is empty');
          }
          return handler.next(options);
        },
      ),
    );
  }
}




