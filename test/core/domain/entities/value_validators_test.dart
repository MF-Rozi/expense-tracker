import 'package:expense_tracker/core/domain/entities/value_validators.dart';
import 'package:expense_tracker/core/domain/failures/value_failure.dart';
import 'package:expense_tracker/core/utils/extensions/dartz_extensions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Value Validator', () {
    group('Validate Single Line', () {
      test(
        'should return failure when multiline text.',
        () async {
          // arrange
          const input = 'this is the first line \n and this is the second one.';
          // act
          final validation = validateSingleLine(input);
          final output = validation.getRight();
          final failure = validation.getLeft();

          // assert
          expect(validation.isLeft(), isTrue);
          expect(output, isNull);
          expect(failure, isA<ValueMultiline<String>>());
        },
      );

      test(
        'should return String when validated',
        () async {
          // arrange
          const input = 'this is only single line';
          // act
          final validation = validateSingleLine(input);
          final output = validation.getRight();
          final failure = validation.getLeft();
          // assert
          expect(validation.isRight(), isTrue);
          expect(output, isA<String>());
          expect(output, equals(input));
          expect(failure, isNull);
        },
      );
    });

    group('Validate Unique Id', () {
      test(
        'should return Value Failure when invalid UUID',
        () async {
          // arrange
          const input = '10492';
          // act
          final validated = validateUniqueId(input);
          final output = validated.getRight();
          final failure = validated.getLeft();
          // assert
          expect(validated.isLeft(), isTrue);
          expect(failure, isA<ValueInvalidUniqueId<String>>());
          expect(output, isNull);
        },
      );

      test(
        'should return valid UUID String',
        () async {
          // arrange
          const input = 'f398a930-77b3-4395-be13-4bc5b53cb2f9';
          // act
          final validated = validateUniqueId(input);
          final output = validated.getRight();
          final failure = validated.getLeft();
          // assert
          expect(validated.isRight(), isTrue);
          expect(output, isA<String>());
          expect(output, equals(input));
          expect(failure, isNull);
        },
      );
    });
  });
}
