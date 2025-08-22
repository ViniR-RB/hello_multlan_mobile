import 'package:dio/dio.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';

final class AuthInterceptor extends Interceptor {
  final RestClient _restClient;
  final ILocalStorageService _localStorageService;
  AuthInterceptor({
    required final ILocalStorageService localStorageService,
    required final RestClient restClient,
  }) : _localStorageService = localStorageService,
       _restClient = restClient;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final RequestOptions(:headers, :extra) = options;
    const authHeaderKey = "Authorization";
    headers.remove(authHeaderKey);

    if (headers case {"DIO_AUTH_KEY": true}) {
      final acessTokenResult = await _localStorageService.get(
        Constants.accessToken,
      );

      acessTokenResult.onSuccess((accessToken) {
        headers.addAll({authHeaderKey: 'Bearer $accessToken'});
      });
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    handler.next(err);
  }
}
