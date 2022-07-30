import 'package:expense_tracker/core/domain/failures/value_failure.dart';
import 'package:expense_tracker/core/utils/extensions/dartz_extensions.dart';
import 'package:expense_tracker/shared/categories/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StringSingleLine', () {
    test(
      'should contains ValueFailure when inputted with multi line string',
      () async {
        // arrange
        const input = 'this is \n multi line text';
        // act
        final singleLine = StringSingleLine(input);
        final output = singleLine.value.getRight();
        final failure = singleLine.value.getLeft();

        // assert
        expect(singleLine.isValid(), isFalse);
        expect(output, isNull);
        expect(failure, isA<ValueMultiline<String>>());
      },
    );

    test(
      'should contains String when valid ',
      () async {
        // arrange
        const input = 'this is single line';
        // act
        final singleLine = StringSingleLine(input);
        final output = singleLine.value.getRight();
        final failure = singleLine.value.getLeft();
        // assert
        expect(singleLine.isValid(), isTrue);
        expect(output, isA<String>());
        expect(output, equals(input));
        expect(failure, isNull);
      },
    );
  });
}
