import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';

abstract interface class OccurrenceRepository {
  AsyncResult<AppException, List<OccurrenceModel>> getAllOccurrences();
}
