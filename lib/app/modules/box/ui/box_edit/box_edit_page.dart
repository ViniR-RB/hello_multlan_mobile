import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hello_multlan/app/core/extensions/error_translator.dart';
import 'package:hello_multlan/app/core/extensions/loader_message.dart';
import 'package:hello_multlan/app/core/extensions/success_translator.dart';
import 'package:hello_multlan/app/core/states/command_state.dart';
import 'package:hello_multlan/app/core/widgets/custom_app_bar_sliver.dart';
import 'package:hello_multlan/app/core/widgets/custom_scaffold_foreground.dart';
import 'package:hello_multlan/app/modules/box/commands/get_box_by_id_command.dart';
import 'package:hello_multlan/app/modules/box/dto/edit_box_dto.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_zone_enum.dart';
import 'package:hello_multlan/app/modules/box/ui/box_edit/box_edit_controller.dart';
import 'package:hello_multlan/app/modules/box/ui/box_edit/commands/update_box_data_command.dart';

class BoxEditPage extends StatefulWidget {
  final BoxEditController controller;
  final String boxId;
  final GetBoxByIdCommand getBoxByIdCommand;
  final UpdateBoxDataCommand updateBoxDataCommand;

  const BoxEditPage({
    super.key,
    required this.controller,
    required this.boxId,
    required this.getBoxByIdCommand,
    required this.updateBoxDataCommand,
  });

  @override
  State<BoxEditPage> createState() => _BoxEditPageState();
}

class _BoxEditPageState extends State<BoxEditPage>
    with LoaderMessageMixin, ErrorTranslator, SuccessTranslator {
  late EditBoxDto _boxDto;

  final EditBoxDtoValidator _validator = EditBoxDtoValidator();
  final _formKey = GlobalKey<FormState>();
  Key _formDataKey = UniqueKey();

  _addUser() {
    _boxDto.addUserForListByIndex("", _boxDto.listUser.length);
  }

  @override
  void initState() {
    super.initState();
    _boxDto = EditBoxDto(id: widget.boxId);
    widget.getBoxByIdCommand.addListener(_listenerGetBoxById);
    widget.updateBoxDataCommand.addListener(_listenerUpdateBox);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.controller.loadBox(widget.boxId);
    });
  }

  void _listenerGetBoxById() {
    final state = widget.getBoxByIdCommand.state;

    switch (state) {
      case CommandSuccess(value: final box):
        setState(() {
          _boxDto = EditBoxDto.fromJson(box!.toJson());
          _formDataKey = UniqueKey(); // Força recriação dos campos
          log("Box updated $_boxDto");
        });

        notifier.hideLoader();

      case CommandFailure(:final exception):
        notifier.hideLoader();
        final message = translateError(context, exception.code);
        notifier.showMessage(message, SnackType.error);

      case CommandLoading():
        notifier.showLoader();
        break;
      case _:
        break;
    }
  }

  void _listenerUpdateBox() {
    final state = widget.updateBoxDataCommand.state;

    if (state is CommandLoading) {
      notifier.showLoader();
    }
    if (state is CommandSuccess) {
      notifier.hideLoader();
      notifier.showMessage(
        translateSuccess(context, "successInUpdateBox"),
        SnackType.success,
      );
    }
    if (state case CommandFailure(exception: final exception)) {
      notifier.hideLoader();

      final message = translateError(
        context,
        exception.code,
      );

      notifier.showMessage(message, SnackType.error);
    }
  }

  @override
  void dispose() {
    widget.updateBoxDataCommand.removeListener(_listenerUpdateBox);
    widget.getBoxByIdCommand.removeListener(_listenerGetBoxById);
    widget.controller.dispose();
    super.dispose();
  }

  bool _parcialFormIsValid() {
    final formException = _validator.validate(_boxDto);
    final invalidFields = Set.from(formException.exceptions.map((e) => e.key));

    log("$invalidFields");

    final simpleUserExceptions = _validator.getExceptionsByKey(
      _boxDto,
      "listUser",
    );

    log("simpleUserExceptions: $simpleUserExceptions");

    if (simpleUserExceptions.isNotEmpty) {
      return false;
    }
    if (invalidFields.isNotEmpty) {
      return false;
    }

    return true;
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
              CustomSliverAppBar(
                title: "Editar Caixa",
                actions: [
                  ListenableBuilder(
                    listenable: _boxDto,
                    builder: (context, child) {
                      return IconButton(
                        onPressed: _parcialFormIsValid()
                            ? () {
                                widget.controller.updateBox(_boxDto);
                              }
                            : null,
                        icon: Icon(
                          Icons.save,
                          color: _parcialFormIsValid()
                              ? Colors.white
                              : Colors.grey,
                        ),
                        tooltip: "Salvar",
                      );
                    },
                  ),
                ],
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                    ),
                    child: Column(
                      key: _formDataKey,
                      spacing: 12,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          initialValue: _boxDto.label,
                          decoration: const InputDecoration(
                            labelText: 'Rótulo',
                            prefixIcon: Icon(Icons.label),
                          ),
                          onChanged: (value) => _boxDto.setLabel = value,
                          validator: _validator.byField(_boxDto, "label"),
                        ),

                        TextFormField(
                          initialValue: _boxDto.freeSpace.toString(),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total de Clientes',
                            prefixIcon: Icon(Icons.space_bar),
                          ),
                          validator: _validator.byField(
                            _boxDto,
                            "freeSpace",
                          ),
                          onChanged: (value) =>
                              _boxDto.setFreeSpace = int.tryParse(value) ?? 0,
                        ),

                        TextFormField(
                          initialValue: _boxDto.signal.toString(),
                          decoration: const InputDecoration(
                            labelText: 'Sinal',
                            prefixIcon: Icon(Icons.network_cell),
                          ),
                          validator: _validator.byField(_boxDto, "signal"),
                          onChanged: (value) =>
                              _boxDto.setSignal = num.tryParse(value) ?? 0,
                        ),
                        TextFormField(
                          initialValue: _boxDto.note,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Nota',
                            prefixIcon: Icon(Icons.note_alt),
                          ),
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
                              return _validator.byField(_boxDto, "note")(
                                value,
                              );
                            }
                          },
                          onChanged: (value) => _boxDto.setNote = value,
                        ),

                        DropdownButtonFormField<BoxZoneEnum>(
                          decoration: const InputDecoration(
                            labelText: 'Zona da Caixa',
                            border: OutlineInputBorder(),
                          ),
                          value: BoxZoneEnum.values.firstWhere(
                            (zone) => zone.value == _boxDto.zone,
                            orElse: () => BoxZoneEnum.safe,
                          ),
                          items: BoxZoneEnum.values.map((zone) {
                            return DropdownMenuItem<BoxZoneEnum>(
                              value: zone,
                              child: Row(
                                spacing: 8,
                                children: [
                                  switch (zone) {
                                    BoxZoneEnum.safe => const Icon(
                                      Icons.shield,
                                      color: Colors.green,
                                    ),
                                    BoxZoneEnum.moderate => const Icon(
                                      Icons.warning,
                                      color: Colors.orange,
                                    ),
                                    BoxZoneEnum.danger => const Icon(
                                      Icons.error,
                                      color: Colors.red,
                                    ),
                                  },
                                  Text(switch (zone) {
                                    BoxZoneEnum.safe => "Segura",
                                    BoxZoneEnum.moderate => "Moderada",
                                    BoxZoneEnum.danger => "Perigosa",
                                  }),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (zone) {
                            _boxDto.setZone = zone?.value ?? "SAFE";
                          },
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ListenableBuilder(
                              listenable: _boxDto,
                              builder: (context, child) {
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text("Clientes"),
                                    if (_boxDto.freeSpace > 0)
                                      Text(
                                        "${_boxDto.filledSpace} / ${_boxDto.freeSpace}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            ListenableBuilder(
                              listenable: _boxDto,
                              builder: (context, child) {
                                final canAddUser =
                                    _boxDto.listUser.length < _boxDto.freeSpace;

                                return TextButton(
                                  onPressed: canAddUser
                                      ? () => _addUser()
                                      : null,
                                  child: Text(
                                    "Adicionar Cliente",
                                    style: TextStyle(
                                      color: canAddUser ? null : Colors.grey,
                                    ),
                                  ),
                                );
                              },
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
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: TextFormField(
                                    initialValue: _boxDto.listUser[index],
                                    decoration: InputDecoration(
                                      labelText: 'Cliente',
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          Icons.remove_circle,
                                          color: Colors.red,
                                        ),
                                        onPressed: () {
                                          _boxDto.removeUserForListByIndex(
                                            index,
                                          );
                                        },
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _boxDto.addUserForListValue(
                                        value,
                                        index,
                                      );
                                    },
                                    validator: (String? value) {
                                      final message = _validator.byField(
                                        _boxDto,
                                        "listUser.simpleUser",
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
                                  ),
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
                                  widget.controller.updateBox(_boxDto);
                                }
                              : null,
                          child: Text("Atualizar"),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom + 16,
                  ),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
