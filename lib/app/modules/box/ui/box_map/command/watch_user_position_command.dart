import 'dart:async';

import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository.dart';

class WatchUserPositionCommand
    extends BaseCommand<LatitudeLongitudeModel?, AppException> {
  final GeoLocatorRepository _geoLocatorRepository;
  StreamSubscription? _subscription;

  WatchUserPositionCommand({required GeoLocatorRepository geoLocatorRepository})
    : _geoLocatorRepository = geoLocatorRepository,
      super(CommandInitial(null));

  Future<void> execute() async {
    _subscription?.cancel();
    _subscription = _geoLocatorRepository.watchPosition().listen((result) {
      result.when(
        onSuccess: (LatitudeLongitudeModel latLong) {
          setState(CommandSuccess(latLong));
        },
        onFailure: (AppException error) {
          setState(CommandFailure(error));
        },
      );
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
