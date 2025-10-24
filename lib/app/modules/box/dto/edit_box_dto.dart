import 'package:flutter/material.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_zone_enum.dart';
import 'package:lucid_validation/lucid_validation.dart';

class EditBoxDto extends ChangeNotifier {
  String id;
  String label;
  int freeSpace;
  num signal;
  List<String> listUser;
  String note;
  String zone;

  int get filledSpace => listUser.length;

  EditBoxDto({
    required this.id,
    this.label = "",
    this.freeSpace = 0,
    this.signal = 0.0,
    this.note = "",
    this.zone = "SAFE",
    List<String>? listUser,
  }) : listUser = List<String>.from(listUser ?? []);

  set setLabel(String value) {
    label = value;
    notifyListeners();
  }

  set setFreeSpace(int value) {
    freeSpace = value;
    notifyListeners();
  }

  set setSignal(num value) {
    signal = value;
    notifyListeners();
  }

  set setListUser(List<String> value) {
    listUser = value;
    notifyListeners();
  }

  set setNote(String value) {
    note = value;
    notifyListeners();
  }

  set setZone(String value) {
    zone = value;
    notifyListeners();
  }

  void addUserForListByIndex(String value, int index) {
    listUser.insert(index, value);
    notifyListeners();
  }

  void addUserForListValue(String value, int index) {
    listUser[index] = value;
    notifyListeners();
  }

  void removeUserForListByIndex(int index) {
    listUser.removeAt(index);
    notifyListeners();
  }

  void clear() {
    label = "";
    freeSpace = 0;
    signal = 0.0;
    note = "";
    zone = "";
    listUser = [];
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'freeSpace': freeSpace,
      'filledSpace': filledSpace,
      'signal': signal,
      'note': note,
      'zone': zone,
      'listUser': listUser,
    };
  }

  factory EditBoxDto.fromJson(Map<String, dynamic> json) {
    return EditBoxDto(
      id: json['id'] ?? "",
      label: json['label'] ?? "",
      freeSpace: json['freeSpace'] ?? 0,
      signal: json['signal'] ?? 0.0,
      note: json['note'] ?? "",
      zone: json['zone'] ?? "",
      listUser: List<String>.from(json['listUser'] ?? []),
    );
  }
}

class EditBoxDtoValidator extends LucidValidator<EditBoxDto> {
  EditBoxDtoValidator() {
    ruleFor((box) => box.label, key: "label").notEmpty().minLength(3);
    ruleFor((box) => box.freeSpace, key: "freeSpace").greaterThan(1);
    ruleFor((box) => box.filledSpace, key: "filledSpace").mustWith(
      (filled, box) => filled <= box.freeSpace,
      "filledSpaceGreaterThanFreeSpace",
      "filledSpaceGreaterThanFreeSpace",
    );

    ruleFor((box) => box.note, key: "note").mustWith(
      (note, box) => note.isEmpty || note.length > 3,
      "noteMinLength",
      "noteMinLength",
    );
    ruleFor((box) => box.signal, key: "signal").greaterThan(1);
    ruleFor(
          (box) => box.zone,
          key: 'zone',
        )
        .must(
          (zoneDto) => BoxZoneEnum.values.any((zone) => zone.value == zoneDto),
          "Zona invalida",
          "invalidZone",
        )
        .notEmpty();

    ruleFor(
      (box) => box.listUser,
      key: "listUser",
    ).setEach(SimpleUserValidator());
  }
}

class SimpleUserValidator extends LucidValidator<String> {
  SimpleUserValidator() {
    ruleFor(
      (value) => value,
      key: "simpleUser",
    ).notEmpty().minLength(4); // maior que 3 caracteres significa mínimo de 4
  }
}
