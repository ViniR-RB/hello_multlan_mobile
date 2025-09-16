import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/data/exceptions/image_picker_exception.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/success_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_app_bar_sliver.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/box_form_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/create_box_data_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_image_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/commands/get_user_location_send_form_command.dart';
import 'package:hello_multlan/app/modules/box/ui/box_form/widgets/image_source_bottom_sheet.dart';

class BoxFormPage extends StatefulWidget {
  final BoxFormController controller;
  final GetImageCommand getImageCommand;
  final GetUserLocationSendFormCommand getUserLocationSendFormCommand;
  final CreateBoxDataCommand createBoxDataCommand;
  const BoxFormPage({
    super.key,
    required this.controller,
    required this.getImageCommand,
    required this.getUserLocationSendFormCommand,
    required this.createBoxDataCommand,
  });

  @override
  State<BoxFormPage> createState() => _BoxFormPageState();
}

class _BoxFormPageState extends State<BoxFormPage>
    with LoaderMessageMixin, ErrorTranslator, SuccessTranslator {
  final CreateBoxDto _boxDto = CreateBoxDto();
  final _validator = CreateBoxDtoValidator();
  final _formKey = GlobalKey<FormState>();

  List<Widget> icons = <Widget>[
    const Icon(Icons.location_on),
    const Icon(Icons.location_off),
  ];

  _addUser() {
    _boxDto.addUserForListByIndex("", _boxDto.listUser.length);
  }

  @override
  void initState() {
    super.initState();
    widget.getImageCommand.addListener(_listernetGetImage);
    widget.getUserLocationSendFormCommand.addListener(_listenerGetUserLocation);
    widget.createBoxDataCommand.addListener(_listernetCreateBox);
  }

  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ImageSourceBottomSheet(
        onCameraPressed: () => widget.controller.getImageFromCamera(),
        onGalleryPressed: () => widget.controller.getImageFromGallery(),
      ),
    );
  }

  void _showImageDialog(File imageFile) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Imagem
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  imageFile,
                  width: MediaQuery.of(context).size.width * 0.8,
                  height: MediaQuery.of(context).size.height * 0.6,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Botão fechar
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close, color: Colors.white),
              label: const Text(
                'Fechar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    widget.controller.resetImageSelected();
    _boxDto.resetImage();
  }

  void _listernetGetImage() {
    if (widget.getImageCommand.state is CommandSuccess) {
      _boxDto.setImageFile =
          (widget.getImageCommand.state as CommandSuccess).value;
    }
    if (widget.getImageCommand.state is CommandFailure) {
      final state = widget.getImageCommand.state as CommandFailure;

      if (state.exception is ImagePickerNotFoundException) {
        final message = translateError(
          context,
          (state.exception as ImagePickerNotFoundException).code,
        );
        notifier.showMessage(message, SnackType.info);
      }
      if (state.exception is ImagePickerNotHasAccessException) {
        final message = translateError(
          context,
          (state.exception as ImagePickerNotHasAccessException).code,
        );
        notifier.showMessage(message, SnackType.error);
      }
    }
  }

  void _listenerGetUserLocation() {
    final state = widget.getUserLocationSendFormCommand.state;

    switch (state) {
      case CommandSuccess(value: final latLng):
        notifier.hideLoader();

        _boxDto.setLatitude = latLng!.latitude.toString();
        _boxDto.setLongitude = latLng.longitude.toString();
        final isValid = _validator.validate(_boxDto);

        if (isValid.isValid) {
          widget.controller.createBox(_boxDto);
        }

      case CommandFailure(:final exception):
        notifier.hideLoader();

        final message = translateError(
          context,
          exception.code,
        );
        notifier.showMessage(message, SnackType.error);
      case CommandLoading():
        notifier.showLoader();
      case _:
        null;
    }
  }

  void _listernetCreateBox() {
    final state = widget.createBoxDataCommand.state;

    if (state is CommandLoading) {
      notifier.showLoader();
    }
    if (state is CommandSuccess) {
      notifier.hideLoader();
      notifier.showMessage(
        translateSuccess(context, "successInCreateBox"),
        SnackType.success,
      );
      _formKey.currentState?.reset();
      _boxDto.clear();
      widget.controller.resetImageSelected();
    }
    if (state case CommandFailure(exception: final exception)) {
      notifier.hideLoader();

      final message = translateError(
        context,
        exception.code,
      );

      notifier.showMessage(message, SnackType.error);
      _boxDto.removePosition();
    }
  }

  @override
  void dispose() {
    widget.getImageCommand.removeListener(_listernetGetImage);
    widget.getUserLocationSendFormCommand.removeListener(
      _listenerGetUserLocation,
    );
    widget.createBoxDataCommand.removeListener(_listernetCreateBox);
    widget.controller.dispose();
    super.dispose();
  }

  bool _parcialFormIsValid() {
    final formException = _validator.validate(_boxDto);
    final invalidFields = Set.from(formException.exceptions.map((e) => e.key));
    log("$invalidFields");
    if (invalidFields.length == 2 &&
        invalidFields.containsAll(["latitude", "longitude"])) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffoldForegroud(
      child: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: CustomScrollView(
            slivers: [
              CustomSliverAppBar(title: "Criar Caixa", actions: []),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(
                    height: 16,
                  ),
                  ListenableBuilder(
                    listenable: widget.getImageCommand,
                    builder: (context, child) {
                      // Verifica se o comando está carregando
                      if (widget.getImageCommand.state is CommandLoading) {
                        return CircleAvatar(
                          child: CircularProgressIndicator(),
                        );
                      }

                      // Verifica se o comando tem sucesso
                      final file =
                          widget.getImageCommand.state is CommandSuccess
                          ? (widget.getImageCommand.state as CommandSuccess)
                                .value
                          : null;

                      if (file != null) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: FileImage(file),
                              child: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            // Botão para visualizar imagem
                            Positioned(
                              right: 150,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: () => _showImageDialog(file),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.visibility,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                            // Botão para remover imagem
                            Positioned(
                              left: 150,
                              bottom: 0,
                              child: GestureDetector(
                                onTap: _removeImage,
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          Text("Adicionar Foto"),
                          InkWell(
                            onTap: _showImageSourceBottomSheet,
                            child: CircleAvatar(
                              child: const Icon(Icons.add_a_photo),
                            ),
                          ),
                          ListenableBuilder(
                            listenable: _boxDto,
                            builder: (context, child) {
                              return Visibility(
                                visible: Set.from(
                                  _validator
                                      .getExceptions(_boxDto)
                                      .map((e) => e.key),
                                ).contains("image"),
                                child: Text("Selecione uma foto ou imagem"),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                    ),
                    child: Column(
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Rótulo',
                          ),
                          onChanged: (value) => _boxDto.setLabel = value,
                          validator: _validator.byField(_boxDto, "label"),
                        ),

                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Total de Clientes',
                          ),
                          validator: _validator.byField(_boxDto, "freeSpace"),
                          onChanged: (value) =>
                              _boxDto.setFreeSpace = int.tryParse(value) ?? 0,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Clientes Ativos',
                          ),
                          validator: (String? value) {
                            final getExceptionTranslate = _validator
                                .getExceptions(_boxDto)
                                .any(
                                  (exception) =>
                                      exception.message ==
                                      "filledSpaceGreaterThanFreeSpace",
                                );

                            if (getExceptionTranslate == true) {
                              return translateError(
                                context,
                                "filledSpaceGreaterThanFreeSpace",
                              );
                            } else {
                              return _validator.byField(_boxDto, "filledSpace")(
                                value,
                              );
                            }
                          },
                          onChanged: (value) =>
                              _boxDto.setFilledSpace = int.tryParse(value) ?? 0,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Sinal'),
                          validator: _validator.byField(_boxDto, "signal"),
                          onChanged: (value) =>
                              _boxDto.setSignal = num.tryParse(value) ?? 0,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Nota'),
                          validator: (String? value) {
                            final getExceptionTranslate = _validator
                                .getExceptions(_boxDto)
                                .where(
                                  (exception) =>
                                      exception.message == "noteMinLength",
                                )
                                .toList();

                            if (getExceptionTranslate.isNotEmpty) {
                              return translateError(
                                context,
                                getExceptionTranslate.first.code,
                              );
                            } else {
                              return _validator.byField(_boxDto, "note")(value);
                            }
                          },
                          onChanged: (value) => _boxDto.setNote = value,
                        ),
                        TextFormField(
                          decoration: const InputDecoration(labelText: 'Zona'),
                          validator: _validator.byField(_boxDto, "zone"),
                          onChanged: (value) => _boxDto.setZone = value,
                        ),
                        ValueListenableBuilder(
                          valueListenable: widget.controller.selectedGps,
                          builder: (context, value, child) {
                            return Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width * .6,
                                  child: TextFormField(
                                    enabled:
                                        widget
                                            .controller
                                            .selectedGps
                                            .value[1] ==
                                        true,
                                    validator:
                                        widget
                                                .controller
                                                .selectedGps
                                                .value[1] ==
                                            true
                                        ? (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Campo obrigatório';
                                            }
                                          }
                                        : null,
                                    decoration: const InputDecoration(
                                      labelText: 'Insira um endereço com cep',
                                    ),
                                  ),
                                ),
                                ToggleButtons(
                                  direction: Axis.horizontal,
                                  onPressed: (int index) {
                                    widget.controller.selectedGps.value =
                                        List<bool>.generate(
                                          widget
                                              .controller
                                              .selectedGps
                                              .value
                                              .length,
                                          (i) => i == index,
                                        );
                                  },
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(8),
                                  ),
                                  selectedBorderColor: Colors.blue[700],
                                  isSelected:
                                      widget.controller.selectedGps.value,
                                  children: icons,
                                ),
                              ],
                            );
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Clientes"),
                            TextButton(
                              onPressed: () => _addUser(),
                              child: Text("Adicionar Cliente"),
                            ),
                          ],
                        ),
                        ListenableBuilder(
                          listenable: _boxDto,
                          builder: (context, child) {
                            return ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: _boxDto.listUser.length,
                              itemBuilder: (context, index) {
                                return TextFormField(
                                  decoration: InputDecoration(
                                    labelText: 'Cliente',
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        Icons.remove_circle,
                                        color: Colors.red,
                                      ),
                                      onPressed: () {
                                        _boxDto.removeUserForListByIndex(index);
                                      },
                                    ),
                                  ),
                                  onChanged: (value) {
                                    _boxDto.addUserForListValue(value, index);
                                  },
                                  validator: (String? value) {
                                    final message = _validator.byField(
                                      _boxDto,
                                      "listUser",
                                    )(value);
                                    if (message == null) return null;
                                    if (message == "fieldRequired") {
                                      return translateError(
                                        context,
                                        "fieldRequired",
                                      );
                                    }
                                    return message;
                                  },
                                );
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: ListenableBuilder(
                      listenable: _boxDto,
                      builder: (context, child) {
                        return ElevatedButton(
                          onPressed: _parcialFormIsValid()
                              ? () {
                                  widget.controller.getUserLocation();
                                }
                              : null,
                          child: Text("Salvar"),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
