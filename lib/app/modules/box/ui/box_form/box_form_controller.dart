import 'package:flutter/widgets.dart';
import 'package:hello_multlan/app/core/enums/image_source_type.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/create_box_data_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_image_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_user_location_send_form_command.dart';

class BoxFormController {
  final CreateBoxDataCommand _createBoxCommand;
  final GetImageCommand _getImageCommand;
  final GetUserLocationSendFormCommand _getUserLocationSendFormCommand;
  final ValueNotifier<List<bool>> selectedGps = ValueNotifier([true, false]);

  BoxFormController({
    required GetImageCommand getImageCommand,
    required CreateBoxDataCommand createBoxCommand,
    required GetUserLocationSendFormCommand getUserLocationSendFormCommand,
  }) : _getImageCommand = getImageCommand,
       _getUserLocationSendFormCommand = getUserLocationSendFormCommand,
       _createBoxCommand = createBoxCommand;

  Future<void> getImageFromGallery() async =>
      await _getImageCommand.execute(ImageSourceType.gallery);

  Future<void> getImageFromCamera() async =>
      await _getImageCommand.execute(ImageSourceType.camera);

  Future<void> getUserLocation() => _getUserLocationSendFormCommand.execute();

  void resetImageSelected() {
    _getImageCommand.reset();
  }

  Future<void> createBox(CreateBoxDto box) => _createBoxCommand.execute(box);

  void dispose() {
    selectedGps.dispose();
    _createBoxCommand.dispose();
    _getImageCommand.dispose();
    _getUserLocationSendFormCommand.dispose();
  }
}
