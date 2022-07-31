import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/failures/value_failure.dart';

Either<ValueFailure<String>, String> validateSingleLine(String input) {
  if (input.contains('\n')) {
    return left(ValueFailure.multiline(failedValue: input));
  } else {
    return right(input);
  }
}

Either<ValueFailure<String>, String> validateUniqueId(String input) {
  final regex = RegExp(
    '^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}',
  );
  if (regex.hasMatch(input)) {
    return right(input);
  }
  return left(ValueFailure.invalidUniqueId(failedValue: input));
}
