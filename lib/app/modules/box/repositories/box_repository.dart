import 'dart:io';

import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_lite_model.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';

abstract interface class BoxRepository {
  AsyncResult<AppException, List<BoxLiteModel>> getAllBoxesByFilters({
    required double latMin,
    required double lngMin,
    required double latMax,
    required double lngMax,
  });
  AsyncResult<AppException, File> getImageFromGallery();
  AsyncResult<AppException, File> getImageFromCamera();
  AsyncResult<AppException, Unit> createBox(CreateBoxDto box);
  AsyncResult<AppException, BoxModel> getBoxById(String id);
}
