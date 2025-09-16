import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_modular/flutter_modular.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hello_multlan/app/core/data/image_picker/image_picker_service.dart';
import 'package:hello_multlan/app/core/data/image_picker/image_picker_service_impl.dart';
import 'package:hello_multlan/app/core/data/local_notifications/local_notification.dart';
import 'package:hello_multlan/app/core/data/local_notifications/local_notification_impl.dart';
import 'package:hello_multlan/app/core/data/local_storage/i_local_storage.service.dart';
import 'package:hello_multlan/app/core/data/local_storage/local_storage_service_impl.dart';
import 'package:hello_multlan/app/core/data/push_notification/push_notification.dart';
import 'package:hello_multlan/app/core/data/push_notification/push_notification_impl.dart';
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
    i.addLazySingleton<ImagePickerService>(ImagePickerServiceImpl.new);
    i.addInstance<FirebaseMessaging>(FirebaseMessaging.instance);
    i.addLazySingleton<PushNotification>(PushNotificationImpl.new);
    i.addLazySingleton<LocalNotification>(LocalNotificationImpl.new);
  }

  @override
  void routes(RouteManager r) {}
}
