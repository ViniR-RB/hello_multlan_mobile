import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class LocalStorageException extends AppException {
  LocalStorageException(super.code, [super.message, super.stackTrace]);
}

class LocalStorageNotFoundException extends LocalStorageException {
  LocalStorageNotFoundException()
    : super(
        'localStorageNotFoundKey',
        'Local storage item not found',
        StackTrace.current,
      );
}
