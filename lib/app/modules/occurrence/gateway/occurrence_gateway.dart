import 'package:dio/dio.dart' hide Headers;
import 'package:hello_multlan/app/modules/occurrence/repositories/models/occurence_model.dart';
import 'package:retrofit/retrofit.dart';

part 'occurrence_gateway.g.dart';

@RestApi()
abstract class OccurrenceGateway {
  factory OccurrenceGateway(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _OccurrenceGateway;

  @GET("/api/box/")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<List<OccurrenceModel>> getAllOccurences();
}
