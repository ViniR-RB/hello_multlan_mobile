import 'dart:io';

import 'package:flutter/services.dart';
import 'package:hello_multlan/app/core/data/exceptions/image_picker_exception.dart';
import 'package:hello_multlan/app/core/data/image_picker/image_picker_service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerServiceImpl implements ImagePickerService {
  final ImagePicker _picker = ImagePicker();

  @override
  AsyncResult<AppException, File> pickFromCamera() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.camera);
      if (file == null) {
        Failure(ImagePickerNotFoundException());
      }
      return Success(File(file!.path));
    } on PlatformException catch (e, s) {
      return switch (e.code) {
        "camera_access_denied" => Failure(
          ImagePickerNotHasAccessException("cameraAccessDenied"),
        ),

        "photo_access_denied" => Failure(
          ImagePickerNotHasAccessException("photoAccessDenied"),
        ),
        _ => throw ImagePickerException("unkownError", e.message, s),
      };
    }
  }

  @override
  AsyncResult<AppException, File> pickFromGallery() async {
    try {
      final file = await _picker.pickImage(source: ImageSource.gallery);
      if (file == null || file.path.isEmpty) {
        return Failure(ImagePickerNotFoundException());
      }
      return Success(File(file.path));
    } on PlatformException catch (e, s) {
      return switch (e.code) {
        "camera_access_denied" => Failure(
          ImagePickerNotHasAccessException("cameraAccessDenied"),
        ),

        "photo_access_denied" => Failure(
          ImagePickerNotHasAccessException("photoAccessDenied"),
        ),
        _ => throw ImagePickerException("unkownError", e.message, s),
      };
    }
  }
}
