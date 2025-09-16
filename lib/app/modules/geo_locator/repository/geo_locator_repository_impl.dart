import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/core/extensions/stream_result_extension.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository.dart';
import 'package:hello_multlan/app/modules/geo_locator/services/geo_locator.dart';

class GeoLocatorRepositoryImpl implements GeoLocatorRepository {
  final GeoLocatorService _geoLocatorService;

  GeoLocatorRepositoryImpl({required GeoLocatorService geoLocatorService})
    : _geoLocatorService = geoLocatorService;

  @override
  StreamResult<AppException, LatitudeLongitudeModel> watchPosition() {
    return _geoLocatorService.watchPosition();
  }

  @override
  AsyncResult<AppException, LatitudeLongitudeModel> getUserLocation() {
    return _geoLocatorService.getCurrentLocation();
  }
}
