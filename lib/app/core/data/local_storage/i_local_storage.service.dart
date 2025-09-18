import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';

abstract interface class ILocalStorageService {
  AsyncResult<AppException, String> get(String key);
  AsyncResult<AppException, Unit> set(String key, String value);
  AsyncResult<AppException, Unit> remove(String key);
}
