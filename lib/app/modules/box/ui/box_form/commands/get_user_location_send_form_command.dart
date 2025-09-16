import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository.dart';

class GetUserLocationSendFormCommand
    extends BaseCommand<LatitudeLongitudeModel?, AppException> {
  final GeoLocatorRepository _geoLocatorRepository;
  GetUserLocationSendFormCommand({
    required GeoLocatorRepository geoLocatorRepository,
  }) : _geoLocatorRepository = geoLocatorRepository,
       super(CommandInitial(null));

  Future<void> execute() async {
    setState(CommandLoading());

    final userLocationResult = await _geoLocatorRepository.getUserLocation();

    userLocationResult.when(
      onSuccess: (LatitudeLongitudeModel latLng) {
        setState(CommandSuccess(latLng));
      },
      onFailure: (AppException error) {
        setState(CommandFailure(error));
      },
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
