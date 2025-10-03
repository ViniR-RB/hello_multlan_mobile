import 'dart:developer';

import 'package:geolocator/geolocator.dart';
import 'package:hello_multlan/app/core/either/either.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/extensions/async_result_extension.dart';
import 'package:hello_multlan/app/core/extensions/stream_result_extension.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';
import 'package:hello_multlan/app/modules/geo_locator/exceptions/geo_locator_exception.dart';
import 'package:hello_multlan/app/modules/geo_locator/services/geo_locator.dart';

class GeoLocatorServiceImpl implements GeoLocatorService {
  @override
  AsyncResult<AppException, LatitudeLongitudeModel> getCurrentLocation() async {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Failure(GeoLocatorException('locationServiceDisabled'));
      }
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Failure(
            GeoLocatorException('locationPermissionDenied'),
          );
        }
      }
      if (permission == LocationPermission.deniedForever) {
        return Failure(
          GeoLocatorException('locationPermissionDeniedForever'),
        );
      }
      Position position = await Geolocator.getCurrentPosition();

      return Success(
        LatitudeLongitudeModel.fromData(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
      );
    } catch (e, s) {
      log('Error getting current location: $e', error: e, stackTrace: s);
      throw GeoLocatorException('unknownError', e.toString(), s);
    }
  }

  @override
  AsyncResult<AppException, LatitudeLongitudeModel> getLocationByAddress(
    String address,
  ) {
    // TODO: implement getLocationByAddress
    throw UnimplementedError();
  }

  @override
  StreamResult<AppException, LatitudeLongitudeModel> watchPosition() async* {
    try {
      bool serviceEnabled;
      LocationPermission permission;

      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        yield Failure(GeoLocatorException('locationServiceDisabled'));
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          yield Failure(GeoLocatorException('locationPermissionDenied'));
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        yield Failure(
          GeoLocatorException('locationPermissionDeniedForever'),
        );
        return;
      }

      yield* Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 2,
              timeLimit: Duration(seconds: 5),
            ),
          )
          .map((position) {
            return Success(
              LatitudeLongitudeModel.fromData(
                latitude: position.latitude,
                longitude: position.longitude,
              ),
            );
          })
          .handleError((e, s) {
            return Failure(
              GeoLocatorException(
                'unknownError',
                e.toString(),
                s,
              ),
            );
          });
    } catch (e, s) {
      log('Error watching location: $e', error: e, stackTrace: s);
      yield Failure(
        GeoLocatorException('unknownError', e.toString(), s),
      );
    }
  }
}
