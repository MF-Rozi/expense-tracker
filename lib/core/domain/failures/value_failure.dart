import 'package:freezed_annotation/freezed_annotation.dart';

part 'value_failure.freezed.dart';

@freezed
class ValueFailure<T> with _$ValueFailure<T> {
  const factory ValueFailure.exceedingLength({
    required T failedValue,
    required int max,
  }) = ValueExceedingLength<T>;
  const factory ValueFailure.subceedingLength({
    required T failedValue,
    required int min,
  }) = ValueSubsceedingLength<T>;
  const factory ValueFailure.empty({
    required T failedValue,
  }) = ValueEmpty<T>;
  const factory ValueFailure.multiline({
    required T failedValue,
  }) = ValueMultiline<T>;
  const factory ValueFailure.numberTooLarge({
    required T failedValue,
    required num max,
  }) = ValueNumberTooLarge<T>;
  const factory ValueFailure.invalidUniqueId({
    required T failedValue,
  }) = ValueInvalidUniqueId;
}
