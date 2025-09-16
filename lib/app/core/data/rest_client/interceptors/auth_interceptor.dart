import 'package:dio/dio.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';
import 'package:hello_multlan/app/modules/auth/models/auth_tokens.dart';

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
    if (err case DioException(
      response: Response(
        statusCode: 401,
        data: {
          "message": "Jwt Is invalid",
          "error": "Unauthorized",
          "statusCode": 401,
        },
      ),
    )) {
      try {
        final refreshTokenResult = await _localStorageService.get(
          Constants.refreshToken,
        );

        refreshTokenResult.onFailure((_) {
          return handler.next(err);
        });

        final refreshToken = refreshTokenResult.getOrThrow();

        final response = await _restClient.post(
          "/api/auth/refresh",
          data: {
            "refreshToken": refreshToken,
          },
        );
        final tokens = AuthTokens.fromJson(response.data);
        await Future.wait([
          _localStorageService.set(Constants.accessToken, tokens.accessToken),
          _localStorageService.set(Constants.refreshToken, tokens.refreshToken),
        ]);
        err.requestOptions.headers["Authorization"] =
            'Bearer ${tokens.accessToken}';
        final responseRetry = await _restClient.fetch(err.requestOptions);
        return handler.resolve(responseRetry);
      } catch (e) {
        return handler.next(err);
      }
    }
    return handler.next(err);
  }
}
