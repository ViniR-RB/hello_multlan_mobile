import 'dart:async';
import 'dart:io';

import 'package:hello_multlan/app/core/base_command.dart';
import 'package:hello_multlan/app/core/exceptions/app_exception.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/modules/box/repositories/box_repository.dart';

class GetImageInGalleryCommand extends BaseCommand<File?, AppException> {
  final BoxRepository _boxRepository;

  GetImageInGalleryCommand({required BoxRepository boxRepository})
    : _boxRepository = boxRepository,
      super(CommandInitial(null));

  Future<void> execute() async {
    setState(CommandLoading());

    try {
      final imageBoxResult = await _boxRepository.getImageFromGallery().timeout(
        Duration(seconds: 20),
      );

      imageBoxResult.when(
        onSuccess: (File file) {
          setState(CommandSuccess(file));
        },
        onFailure: (AppException exception) {
          setState(CommandFailure(exception));
        },
      );
    } on TimeoutException catch (e) {
      setState(CommandFailure(AppException("timeout", e.toString())));
    } catch (e) {
      setState(CommandFailure(AppException("unknownError", e.toString())));
    }
  }

  @override
  void reset() => setState(CommandInitial(null));
}
