import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/auth/dtos/credentials.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';

abstract interface class AuthRepository {
  AsyncResult<AppException, bool> isLogged();

  AsyncResult<AppException, UserModel> whoIAm();

  AsyncResult<AppException, Unit> login(Credentials credentials);

  AsyncResult<AppException, Unit> logout();
}
