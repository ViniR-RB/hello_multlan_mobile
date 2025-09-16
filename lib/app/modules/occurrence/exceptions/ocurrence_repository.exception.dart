import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class OccurrenceRepositoryException extends AppException {
  OccurrenceRepositoryException(super.code, [super.message, super.stackTrace]);
}
