import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/value_failure.dart';

Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (input.contains('\n')) {
    return left(ValueFailure.multiline(failedValue: input));
  } else {
    return right(input);
  }
}
