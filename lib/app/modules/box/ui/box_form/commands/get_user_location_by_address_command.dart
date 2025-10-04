import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/models/latitude_longitude_model.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository.dart';

class GetUserLocationByAddressCommand
    extends BaseCommand<LatitudeLongitudeModel?, AppException> {
  final GeoLocatorRepository _geoLocatorRepository;

  GetUserLocationByAddressCommand({
    required GeoLocatorRepository geoLocatorRepository,
  }) : _geoLocatorRepository = geoLocatorRepository,
       super(CommandInitial(null));

  Future<void> execute(String address) async {
    setState(CommandLoading());
    final location = await _geoLocatorRepository.getLocationByAddress(address);
    location.when(
      onSuccess: (location) {
        setState(CommandSuccess(location));
      },
      onFailure: (error) {
        setState(CommandFailure(error));
      },
    );
  }

  @override
  void reset() {
    setState(CommandInitial(null));
  }
}
