import 'package:dartz/dartz.dart';
import 'package:expense_tracker/core/domain/entities/common_interfaces.dart';
import 'package:expense_tracker/core/domain/errors/errors.dart';
import 'package:expense_tracker/core/domain/failures/value_failure.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

@immutable
abstract class ValueObject<T> implements Validatable {
  const ValueObject();
  Either<ValueFailure<T>, T> get value;

  /// Throws [UnexpectedValueError] containing the [ValueFailure]
  T getOrCrash() {
    return value.fold((f) => throw UnexpectedValueError(f), id);
  }

  T getOrElse(T dflt) {
    return value.getOrElse(() => dflt);
  }

  Either<ValueFailure<dynamic>, Unit> get failureOrUnit {
    return value.fold(left, (r) => right(unit));
  }

  @override
  bool isValid() {
    return value.isRight();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValueObject<T> && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Value($value)';
}
