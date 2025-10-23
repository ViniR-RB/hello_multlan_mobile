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
        signal: 2,
        note: 'Valid note',
        zone: 'SAFE',
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
        signal: 2,
        note: 'Valid note',
        zone: 'SAFE',
        listUser: [],
        image: File("path"),
      );

      final result = validator.validate(dto);
      expect(result.isValid, isTrue);
      expect(result.exceptions, isEmpty);
    });
    test(
      'should fail when any user in listUser has less than 4 characters',
      () {
        final dto = CreateBoxDto(
          label: 'Label',
          latitude: '10.0',
          longitude: '20.0',
          freeSpace: 5,
          signal: 2,
          note: 'Valid note',
          zone: 'SAFE',
          listUser: [
            'abc',
            'user2',
          ], // 'abc' tem apenas 3 caracteres (menos que 4)
          image: File("path"),
        );

        final result = validator.validate(dto);
        expect(result.isValid, isFalse);
        expect(result.exceptions.any((e) => e.key == 'simpleUser'), isTrue);
      },
    );

    test(
      'should pass when all users in listUser have at least 4 characters',
      () {
        final dto = CreateBoxDto(
          label: 'Label',
          latitude: '10.0',
          longitude: '20.0',
          freeSpace: 5,
          signal: 2,
          note: 'Valid note',
          zone: 'SAFE',
          listUser: ['user1', 'user2'], // ambos têm 5 caracteres (>= 4)
          image: File("path"),
        );

        final result = validator.validate(dto);
        expect(result.isValid, isTrue);
        expect(result.exceptions, isEmpty);
      },
    );
  });
}
