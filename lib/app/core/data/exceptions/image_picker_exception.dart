import 'package:hello_multlan/app/core/exceptions/app_exception.dart';

class ImagePickerException extends AppException {
  ImagePickerException(super.code, [super.message, super.stackTrace]);
}

class ImagePickerNotFoundException extends ImagePickerException {
  ImagePickerNotFoundException({String? message, StackTrace? stackTrace})
    : super('imagePickerNotFound', message, stackTrace);
}

class ImagePickerNotHasAccessException extends ImagePickerException {
  ImagePickerNotHasAccessException(
    super.code, [
    super.message,
    super.stackTrace,
  ]);
}
