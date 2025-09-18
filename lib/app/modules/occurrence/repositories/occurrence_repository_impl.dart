import 'dart:convert';
import 'dart:developer';

import 'package:hello_multlan/app/core/config/constants.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/auth/models/user_model.dart';
import 'package:hello_multlan/app/modules/occurrence/exceptions/ocurrence_repository.exception.dart';
import 'package:hello_multlan/app/modules/occurrence/gateway/occurrence_gateway.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';
import 'package:hello_multlan/app/modules/pagination/models/pagination_model.dart';

class OccurrenceRepositoryImpl implements OccurrenceRepository {
  final OccurrenceGateway _gateway;
  final ILocalStorageService _localStorageService;
  OccurrenceRepositoryImpl({
    required OccurrenceGateway gateway,
    required ILocalStorageService localStorageService,
  }) : _localStorageService = localStorageService,
       _gateway = gateway;

  @override
  AsyncResult<AppException, PageModel<OccurrenceModel>> getUserOccurrences({
    int page = 1,
    int take = 10,
  }) async {
    try {
      final userModelResult = await _localStorageService.get(Constants.userKey);

      final userModelString = userModelResult.getOrThrow();
      final userModel = UserModel.fromJson(jsonDecode(userModelString));
      final userId = userModel.id;

      final pageOccurrenceLit = await _gateway.getAllOccurences(
        take,
        page,
        userId,
      );

      return Success(pageOccurrenceLit);
    } catch (e, s) {
      log("Error in get all occurrences", error: e, stackTrace: s);
      throw OccurrenceRepositoryException("unknownError", e.toString(), s);
    }
  }
}
