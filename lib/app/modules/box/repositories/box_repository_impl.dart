import 'dart:developer';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hello_multlan/app/core/data/image_picker/image_picker_service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';
import 'package:hello_multlan/app/modules/box/exceptions/box_repository_exception.dart';
import 'package:hello_multlan/app/modules/box/gateway/box_gateway.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_lite_model.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';

class BoxRepositoryImpl implements BoxRepository {
  final BoxGateway _gateway;
  final ImagePickerService _imagePickerService;
  BoxRepositoryImpl({
    required BoxGateway gateway,
    required ImagePickerService imagePickerService,
  }) : _gateway = gateway,
       _imagePickerService = imagePickerService;

  @override
  AsyncResult<AppException, List<BoxLiteModel>> getAllBoxesByFilters({
    required double latMin,
    required double lngMin,
    required double latMax,
    required double lngMax,
  }) async {
    try {
      final listBoxResult = await _gateway.getAllBoxesByFilters(
        latMin,
        lngMin,
        latMax,
        lngMax,
      );

      return Success(listBoxResult);
    } catch (e, s) {
      throw BoxRepositoryException("unkownError", e.toString(), s);
    }
  }

  @override
  AsyncResult<AppException, File> getImageFromGallery() async {
    return await _imagePickerService.pickFromGallery();
  }

  @override
  AsyncResult<AppException, File> getImageFromCamera() async {
    return await _imagePickerService.pickFromCamera();
  }

  @override
  AsyncResult<AppException, Unit> createBox(CreateBoxDto box) async {
    try {
      await _gateway.createBox(
        box.toJson(),
      );

      return Success(unit);
    } on DioException catch (e, s) {
      log("Erro em criar box", error: e, stackTrace: s);
      return Failure(BoxRepositoryException("unkownError", e.toString(), s));
    }
  }

  @override
  AsyncResult<AppException, BoxModel> getBoxById(String id) async {
    try {
      final boxResponse = await _gateway.getBoxById(id);
      return Success(boxResponse);
    } on DioException catch (e, s) {
      throw BoxRepositoryException("unkownError", e.toString(), s);
    }
  }
}
