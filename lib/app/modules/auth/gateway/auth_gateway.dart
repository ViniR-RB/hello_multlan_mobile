import 'package:dio/dio.dart' hide Headers;
import 'package:hello_multlan/app/modules/auth/models/auth_tokens.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'auth_gateway.g.dart';

@RestApi()
abstract class AuthGateway {
  factory AuthGateway(
    Dio dio, {
    String? baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _AuthGateway;

  @GET("/api/auth/me")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<UserModel> getMe();

  @POST("/api/auth/login")
  Future<AuthTokens> login({
    @Field('email') required String email,
    @Field('password') required String password,
  });

  @POST("/api/auth/update-user/")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<UserModel> updateFcmToken({
    @Field('fcmToken') required String fcmToken,
    @Field('id') required int id,
  });

  @POST("/api/users/reset-password")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<void> resetPassword({
    @Field('oldPassword') required String oldPassword,
    @Field('newPassword') required String newPassword,
  });
}
