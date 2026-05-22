import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:thoutha_mobile_app/core/networking/api_constants.dart';

import '../helpers/constants.dart';
import '../helpers/shared_pref_helper.dart';

class DioFactory {
  /// private constructor as I don't want to allow creating an instance of this class
  DioFactory._();

  static Dio? dio;

  static Dio getDio() {
    Duration timeOut = Duration(seconds: 10);

    if (dio == null) {
      dio = Dio();
      dio!
        ..options.connectTimeout = timeOut
        ..options.receiveTimeout = timeOut
        ..options.sendTimeout = timeOut
        ..options.baseUrl = ApiConstants.baseUrl
        ..options.headers = {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        };
      addDioInterceptor();
      return dio!;
    } else {
      return dio!;
    }
  }

  static Future<void> addDioHeaders() async {
    final token =
        await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
    final headers = <String, dynamic>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (token != null && token is String && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    dio?.options.headers = headers;
  }

  static void setTokenIntoHeaderAfterLogin(String token) {
    final existing = dio?.options.headers ?? {};
    dio?.options.headers = {
      'Accept': existing['Accept'] ?? 'application/json',
      'Content-Type': existing['Content-Type'] ?? 'application/json',
      ...existing,
      'Authorization': 'Bearer $token',
    };
  }

  static void addDioInterceptor() {
    dio?.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await SharedPrefHelper.getSecuredString(SharedPrefKeys.userToken);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
    dio?.interceptors.add(
      PrettyDioLogger(
        requestBody: true,
        requestHeader: true,
        responseHeader: true,
      ),
    );
  }
}
