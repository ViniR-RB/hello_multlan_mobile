import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/core/extensions/stream_result_extension.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';

abstract interface class GeoLocatorRepository {
  AsyncResult<AppException, LatitudeLongitudeModel> getUserLocation();
  AsyncResult<AppException, LatitudeLongitudeModel> getLocationByAddress(
    String address,
  );
  StreamResult<AppException, LatitudeLongitudeModel> watchPosition();
}
