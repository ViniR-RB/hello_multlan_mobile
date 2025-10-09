import 'package:dio/dio.dart' hide Headers;
import 'package:hello_multlan/app/modules/box/repositories/models/box_lite_model.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_model.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'box_gateway.g.dart';

@RestApi()
abstract class BoxGateway {
  factory BoxGateway(
    Dio dio, {
    String baseUrl,
    ParseErrorLogger? errorLogger,
  }) = _BoxGateway;

  @GET("/api/box/")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<List<BoxLiteModel>> getAllBoxes();

  @GET("/api/box/")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<List<BoxLiteModel>> getAllBoxesByFilters(
    @Query("latMin") double latMin,
    @Query("lngMin") double lngMin,
    @Query("latMax") double latMax,
    @Query("lngMax") double lngMax,
    @Query("zone") String? zone,
  );

  @POST("/api/box")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  @MultiPart()
  Future<void> createBox(
    @Part() Map<String, dynamic> data,
  );

  @GET("/api/box/{id}")
  @Headers(<String, dynamic>{
    'DIO_AUTH_KEY': true,
  })
  Future<BoxModel> getBoxById(
    @Path("id") String id,
  );
}
