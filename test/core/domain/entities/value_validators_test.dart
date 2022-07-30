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
  });
}
