import 'dart:developer';

import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/occurrence/exceptions/ocurrence_repository.exception.dart';
import 'package:hello_multlan/app/modules/occurrence/gateway/occurrence_gateway.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/occurrence_repository.dart';

class OccurrenceRepositoryImpl implements OccurrenceRepository {
  final OccurrenceGateway _gateway;
  OccurrenceRepositoryImpl({required OccurrenceGateway gateway})
    : _gateway = gateway;

  @override
  AsyncResult<AppException, List<OccurrenceModel>> getAllOccurrences() async {
    try {
      final occurrenceResponseList = await _gateway.getAllOccurences();

      return Success(occurrenceResponseList);
    } catch (e, s) {
      log("Error in get all occurrences", error: e, stackTrace: s);
      throw OccurrenceRepositoryException("unknownError", e.toString(), s);
    }
  }
}
