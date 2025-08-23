import 'package:dio/dio.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/auth/exceptions/auth_repository_exception.dart';
import 'package:hello_multlan/app/modules/auth/gateway/auth_gateway.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';

import './auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final ILocalStorageService _localStorageService;
  final AuthGateway _authGateway;
  AuthRepositoryImpl({
    required ILocalStorageService localStorageService,
    required AuthGateway authGateway,
  }) : _localStorageService = localStorageService,
       _authGateway = authGateway;

  @override
  AsyncResult<AppException, bool> isLogged() async {
    final accessTokenResult = await _localStorageService.get(
      Constants.accessToken,
    );

    return accessTokenResult.when(
      onSuccess: (_) => Success(true),
      onFailure: (_) => Success(false),
    );
  }

  @override
  AsyncResult<AppException, UserModel> whoIAm() async {
    try {
      final userResultResponse = await _authGateway.getMe();

      await _localStorageService.set(
        Constants.userKey,
        userResultResponse.toJson(),
      );

      return Success(userResultResponse);
    } on DioException catch (e, s) {
      return switch (e) {
        DioException(
          response: Response(
            statusCode: 401,
            data: {
              "statusCode": 401,
              "message": "Unauthorized",
            },
          ),
        ) =>
          Failure(
            AuthRepositoryException("unauthorized", e.message, s),
          ),
        _ => throw AuthRepositoryException("unknownError", e.message, s),
      };
    }
  }
}
