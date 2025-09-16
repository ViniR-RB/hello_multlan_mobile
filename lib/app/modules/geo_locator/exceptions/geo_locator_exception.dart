import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class GeoLocatorException extends AppException {
  GeoLocatorException(super.code, [super.message, super.stackTrace]);
}
