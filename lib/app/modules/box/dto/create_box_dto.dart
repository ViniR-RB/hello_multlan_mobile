import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:hello_multlan/app/modules/box/repositories/models/box_zone_enum.dart';
import 'package:lucid_validation/lucid_validation.dart';

class CreateBoxDto extends ChangeNotifier {
  String label;
  String latitude;
  String longitude;
  int freeSpace;
  num signal;
  List<String> listUser;
  String gpsMode;
  String address;
  String note;
  String zone;
  File? image;

  // filledSpace agora é um getter que retorna o tamanho de listUser
  int get filledSpace => listUser.length;

  CreateBoxDto({
    this.label = "",
    this.latitude = "",
    this.longitude = "",
    this.freeSpace = 0,
    this.signal = 0.0,
    this.gpsMode = "PHONE",
    this.address = "",
    this.note = "",
    this.zone = "SAFE",
    List<String>? listUser,
    this.image,
  }) : listUser = List<String>.from(listUser ?? []);

  set setLabel(String value) {
    label = value;
    notifyListeners();
  }

  set setLatitude(String value) {
    latitude = value;
    notifyListeners();
  }

  set setLongitude(String value) {
    longitude = value;
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

  set setImageFile(File file) {
    image = file;
    notifyListeners();
  }

  set setGpsMode(String value) {
    switch (value) {
      case "PHONE" || "ADDRESS":
        gpsMode = value;
      default:
        gpsMode = "PHONE";
    }
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

  void removePosition() {
    latitude = "";
    longitude = "";
  }

  void resetImage() {
    image = null;
    notifyListeners();
  }

  void clear() {
    label = "";
    latitude = "";
    longitude = "";
    freeSpace = 0;
    signal = 0.0;
    note = "";
    zone = "";
    listUser = [];
    image = null;
    notifyListeners();
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'latitude': latitude,
      'longitude': longitude,
      'freeSpace': freeSpace,
      'filledSpace': filledSpace,
      'signal': signal,
      'note': note,
      'zone': zone,
      'listUser': jsonEncode(listUser),
      'file': MultipartFile.fromFileSync(
        image!.path,
        filename: image!.uri.toString(),
      ),
    };
  }

  factory CreateBoxDto.fromJson(Map<String, dynamic> json) {
    return CreateBoxDto(
      label: json['label'] ?? "",
      latitude: json['latitude'] ?? "",
      longitude: json['longitude'] ?? "",
      freeSpace: json['freeSpace'] ?? 0,
      signal: json['signal'] ?? 0.0,
      note: json['note'] ?? "",
      zone: json['zone'] ?? "",
      listUser: List<String>.from(json['listUser'] ?? []),
    );
  }

  set setAddress(String value) {
    address = value;
    notifyListeners();
  }
}

class CreateBoxDtoValidator extends LucidValidator<CreateBoxDto> {
  CreateBoxDtoValidator() {
    ruleFor((box) => box.label, key: "label").notEmpty().minLength(3);
    ruleFor((box) => box.latitude, key: "latitude").notEmpty();
    ruleFor((box) => box.latitude, key: "longitude").notEmpty();
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
    ruleFor((box) => box.gpsMode, key: "gpsMode").notEmpty().must(
      (gpsMode) => gpsMode == "PHONE" || gpsMode == "ADDRESS",
      "invalidGpsMode",
      "invalidGpsMode",
    );
    ruleFor(
      (box) => box.address,
      key: "address",
    ).notEmpty().minLength(3).when((box) => box.gpsMode == "ADDRESS");
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

    ruleFor((box) => box.image, key: "image").isNotNull();
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
