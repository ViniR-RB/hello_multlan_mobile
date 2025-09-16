import 'package:flutter_modular/flutter_modular.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository.dart';
import 'package:hello_multlan/app/modules/geo_locator/repository/geo_locator_repository_impl.dart';
import 'package:hello_multlan/app/modules/geo_locator/services/geo_locator.dart';
import 'package:hello_multlan/app/modules/geo_locator/services/geo_locator_impl.dart';

class GeoLocatorModule extends Module {
  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton<GeoLocatorService>(GeoLocatorServiceImpl.new);
    i.addLazySingleton<GeoLocatorRepository>(GeoLocatorRepositoryImpl.new);
  }
}
