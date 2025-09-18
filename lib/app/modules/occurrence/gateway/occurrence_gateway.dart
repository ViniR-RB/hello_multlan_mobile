import 'package:dio/dio.dart' hide Headers;
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:hello_multlan/app/modules/pagination/models/pagination_model.dart';
import 'package:retrofit/retrofit.dart';

part 'occurrence_gateway.g.dart';

@RestApi()
abstract class OccurrenceGateway {
  factory OccurrenceGateway(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _OccurrenceGateway;

  @GET("/api/occurrences/")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<PageModel<OccurrenceModel>> getAllOccurences(
    @Query("take") int take,
    @Query("page") int page,
    @Query("userId") int userId,
  );
}
