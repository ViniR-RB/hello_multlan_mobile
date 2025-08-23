import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class AuthRepositoryException extends AppException {
  AuthRepositoryException(super.code, [super.message, super.stackTrace]);
}
