import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:hello_multlan/app/core/config/env.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/rest_client/interceptors/auth_interceptor.dart';

class RestClient extends DioForNative {
  RestClient({required ILocalStorageService localStorageService})
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
      AuthInterceptor(
        localStorageService: localStorageService,
        restClient: this,
      ),
    ]);
  }
}
