import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hello_multlan/app/modules/box/dto/create_box_dto.dart';

void main() {
  group('CreateBoxDtoValidator', () {
    late CreateBoxDtoValidator validator;

    setUp(() {
      validator = CreateBoxDtoValidator();
    });

    test('should fail when required fields are empty', () {
      final dto = CreateBoxDto();
      final result = validator.validate(dto);

      expect(result.isValid, isFalse);
      expect(result.exceptions.any((e) => e.key == 'label'), isTrue);
      expect(result.exceptions.any((e) => e.key == 'latitude'), isTrue);
      expect(result.exceptions.any((e) => e.key == 'longitude'), isTrue);
      expect(result.exceptions.any((e) => e.key == 'freeSpace'), isTrue);
      expect(result.exceptions.any((e) => e.key == 'signal'), isTrue);
      expect(result.exceptions.any((e) => e.key == 'image'), isTrue);
    });

    test('should fail when note is too short', () {
      final dto = CreateBoxDto(note: 'ab');
      final result = validator.validate(dto);

      expect(result.exceptions.any((e) => e.key == 'note'), isTrue);
    });

    test('should pass with valid data', () {
      final dto = CreateBoxDto(
        label: 'Label',
        latitude: '10.0',
        longitude: '20.0',
        freeSpace: 5,
        filledSpace: 2,
        signal: 2,
        note: 'Valid note',
        zone: 'A',
        listUser: ['user1'],
        image: File("path"),
      );

      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
      expect(result.exceptions, isEmpty);
    });
    test('should pass with valid data without list user', () {
      final dto = CreateBoxDto(
        label: 'Label',
        latitude: '10.0',
        longitude: '20.0',
        freeSpace: 5,
        filledSpace: 2,
        signal: 2,
        note: 'Valid note',
        zone: 'A',
        listUser: [],
        image: File("path"),
      );

      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
      expect(result.exceptions, isEmpty);
    });
    test(
      'should fail when any user in listUser has less than 3 characters',
      () {
        final dto = CreateBoxDto(
          label: 'Label',
          latitude: '10.0',
          longitude: '20.0',
          freeSpace: 5,
          filledSpace: 2,
          signal: 2,
          note: 'Valid note',
          zone: 'A',
          listUser: ['ab', 'user2'], // 'ab' tem menos de 3 caracteres
          image: File("path"),
        );

        final result = validator.validate(dto);
        expect(result.isValid, isFalse);
        expect(result.exceptions.any((e) => e.code == 'fieldRequired'), isTrue);
      },
    );

    test(
      'should pass when all users in listUser have at least 3 characters',
      () {
        final dto = CreateBoxDto(
          label: 'Label',
          latitude: '10.0',
          longitude: '20.0',
          freeSpace: 5,
          filledSpace: 2,
          signal: 2,
          note: 'Valid note',
          zone: 'A',
          listUser: ['abc', 'user2'],
          image: File("path"),
        );

        final result = validator.validate(dto);
        expect(result.isValid, isTrue);
        expect(result.exceptions, isEmpty);
      },
    );
  });
}
