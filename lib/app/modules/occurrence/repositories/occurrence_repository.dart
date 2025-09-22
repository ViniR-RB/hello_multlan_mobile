import 'package:hello_multlan/app/core/either/unit.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/pagination/models/pagination_model.dart';

abstract interface class OccurrenceRepository {
  AsyncResult<AppException, PageModel<OccurrenceModel>> getUserOccurrences({
    int page = 1,
    int take = 10,
  });
  AsyncResult<AppException, Unit> cancelOccurrence({
    required String occurenceId,
    required String cancelReason,
  });
  AsyncResult<AppException, Unit> resolveOccurrence({
    required String occurrenceId,
  });
}
