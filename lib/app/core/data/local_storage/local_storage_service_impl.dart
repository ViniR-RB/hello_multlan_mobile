import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_multlan/app/core/data/exceptions/local_storage_exception.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';

class LocalStorageServiceImpl implements ILocalStorageService {
  final FlutterSecureStorage _storage;

  LocalStorageServiceImpl({required FlutterSecureStorage storage})
    : _storage = storage;

  @override
  AsyncResult<AppException, String> get(String key) async {
    try {
      final value = await _storage.read(key: key);
      if (value == null) {
        return Failure(LocalStorageNotFoundException());
      }
      return Success(value);
    } catch (e, s) {
      log("Error on get local storage", error: e, stackTrace: s);
      throw LocalStorageException("unkownError", e.toString(), s);
    }
  }

  @override
  AsyncResult<AppException, Unit> set(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);

      return Success(unit);
    } catch (e, s) {
      log("Error on set local storage", error: e, stackTrace: s);
      throw LocalStorageException("unkownError", e.toString(), s);
    }
  }
}
