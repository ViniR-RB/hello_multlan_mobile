import 'package:dio/dio.dart';
import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/exceptions/local_storage_exception.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
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
        _ => Failure(AuthRepositoryException("unauthorized", e.message, s)),
      };
    }
  }

  @override
  AsyncResult<AppException, Unit> login(Credentials credentials) async {
    try {
      final loginResponse = await _authGateway.login(
        email: credentials.email,
        password: credentials.password,
      );

      await Future.wait([
        _localStorageService.set(
          Constants.accessToken,
          loginResponse.accessToken,
        ),
        _localStorageService.set(
          Constants.refreshToken,
          loginResponse.refreshToken,
        ),
      ]);
      final userResultResponse = await _authGateway.getMe();
      final fcmTokenResult = await _localStorageService.get(Constants.fcmToken);

      if (userResultResponse.fcmToken == null &&
          (fcmTokenResult.isSuccess &&
              userResultResponse.fcmToken != fcmTokenResult.getOrThrow())) {
        final userUpdated = await _authGateway.updateFcmToken(
          fcmToken: fcmTokenResult.getOrThrow(),
        );

        await _localStorageService.set(
          Constants.userKey,
          userUpdated.toJson(),
        );
      }

      await _localStorageService.set(
        Constants.userKey,
        userResultResponse.toJson(),
      );

      return Success(unit);
    } on DioException catch (e) {
      return switch (e) {
        DioException(
          response: Response(
            statusCode: 400,
            data: {"message": "User is not authorized"},
          ),
        ) =>
          Failure(
            AuthRepositoryException(
              "unauthorized",
              e.toString(),
              e.stackTrace,
            ),
          ),
        DioException(
          response: Response(
            statusCode: 400,
          ),
        ) =>
          Failure(
            AuthRepositoryException(
              "invalidCredentials",
              e.toString(),
              e.stackTrace,
            ),
          ),
        DioException(
          response: Response(
            statusCode: 404,
          ),
        ) =>
          Failure(
            AuthRepositoryException(
              "invalidCredentials",
              e.toString(),
              e.stackTrace,
            ),
          ),
        _ => throw AuthRepositoryException(
          "unkownError",
          e.toString(),
          e.stackTrace,
        ),
      };
    }
  }

  @override
  AsyncResult<AppException, Unit> logout() async {
    try {
      await Future.wait([
        _localStorageService.remove(Constants.accessToken),
        _localStorageService.remove(Constants.refreshToken),
        _localStorageService.remove(Constants.userKey),
      ]);
      return Success(unit);
    } on LocalStorageException catch (e) {
      throw AuthRepositoryException(e.code, e.message, e.stackTrace);
    }
  }
}
