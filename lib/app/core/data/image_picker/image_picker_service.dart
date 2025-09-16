import 'dart:io';

import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';

abstract interface class ImagePickerService {
  AsyncResult<AppException, File> pickFromGallery();
  AsyncResult<AppException, File> pickFromCamera();
}
