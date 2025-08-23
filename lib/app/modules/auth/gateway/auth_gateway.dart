import 'package:dio/dio.dart' hide Headers;
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
}
