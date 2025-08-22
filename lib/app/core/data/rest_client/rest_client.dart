import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hello_multlan/app/core/config/env.dart';

class RestClient extends DioForNative {
  RestClient()
    : super(
        BaseOptions(
          baseUrl: Env.apiUrl,
          connectTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
        ),
      ) {
    interceptors.addAll([
      LogInterceptor(
        request: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        requestHeader: false,
      ),
    ]);
  }
}
