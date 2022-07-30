import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/entities/value_object.dart';
import 'package:expense_tracker/core/domain/entities/value_validators.dart';
import 'package:expense_tracker/core/domain/failures/value_failure.dart';

class StringSingleLine extends ValueObject<String> {
  factory StringSingleLine(String input) {
    return StringSingleLine._(
      validateSingleLine(input),
    );
  }
  const StringSingleLine._(this.value);

  @override
  final Either<ValueFailure<String>, String> value;
}
