import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class BoxRepositoryException extends AppException {
  BoxRepositoryException(super.code, [super.message, super.stackTrace]);
}
