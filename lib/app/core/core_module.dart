import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/local_storage/local_storage_service_impl.dart';
import 'package:hello_multlan/app/core/data/rest_client/rest_client.dart';

class CoreModule extends Module {
  @override
  List<Module> get imports =>  [
  ];

  @override
  void binds(Injector i) {}
  @override
  void exportedBinds(Injector i) {
    i.addLazySingleton(RestClient.new);
    i.addLazySingleton<ILocalStorageService>(
      () => LocalStorageServiceImpl(
        storage: FlutterSecureStorage(
          aOptions: AndroidOptions(
            encryptedSharedPreferences: true,
          ),
        ),
      ),
    );
  }

  @override
  void routes(RouteManager r) {}
}
