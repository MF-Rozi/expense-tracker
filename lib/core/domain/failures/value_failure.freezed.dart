// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'value_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$ValueFailure<T> {
  T get failedValue => throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $ValueFailureCopyWith<T, ValueFailure<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValueFailureCopyWith<T, $Res> {
  factory $ValueFailureCopyWith(
          ValueFailure<T> value, $Res Function(ValueFailure<T>) then) =
      _$ValueFailureCopyWithImpl<T, $Res>;
  $Res call({T failedValue});
}

/// @nodoc
class _$ValueFailureCopyWithImpl<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  _$ValueFailureCopyWithImpl(this._value, this._then);

  final ValueFailure<T> _value;
  // ignore: unused_field
  final $Res Function(ValueFailure<T>) _then;

  @override
  $Res call({
    Object? failedValue = freezed,
  }) {
    return _then(_value.copyWith(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc
abstract class _$$ValueExceedingLengthCopyWith<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  factory _$$ValueExceedingLengthCopyWith(_$ValueExceedingLength<T> value,
          $Res Function(_$ValueExceedingLength<T>) then) =
      __$$ValueExceedingLengthCopyWithImpl<T, $Res>;
  @override
  $Res call({T failedValue, int max});
}

/// @nodoc
class __$$ValueExceedingLengthCopyWithImpl<T, $Res>
    extends _$ValueFailureCopyWithImpl<T, $Res>
    implements _$$ValueExceedingLengthCopyWith<T, $Res> {
  __$$ValueExceedingLengthCopyWithImpl(_$ValueExceedingLength<T> _value,
      $Res Function(_$ValueExceedingLength<T>) _then)
      : super(_value, (v) => _then(v as _$ValueExceedingLength<T>));

  @override
  _$ValueExceedingLength<T> get _value =>
      super._value as _$ValueExceedingLength<T>;

  @override
  $Res call({
    Object? failedValue = freezed,
    Object? max = freezed,
  }) {
    return _then(_$ValueExceedingLength<T>(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
      max: max == freezed
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ValueExceedingLength<T> implements ValueExceedingLength<T> {
  const _$ValueExceedingLength({required this.failedValue, required this.max});

  @override
  final T failedValue;
  @override
  final int max;

  @override
  String toString() {
    return 'ValueFailure<$T>.exceedingLength(failedValue: $failedValue, max: $max)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValueExceedingLength<T> &&
            const DeepCollectionEquality()
                .equals(other.failedValue, failedValue) &&
            const DeepCollectionEquality().equals(other.max, max));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(failedValue),
      const DeepCollectionEquality().hash(max));

  @JsonKey(ignore: true)
  @override
  _$$ValueExceedingLengthCopyWith<T, _$ValueExceedingLength<T>> get copyWith =>
      __$$ValueExceedingLengthCopyWithImpl<T, _$ValueExceedingLength<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) {
    return exceedingLength(failedValue, max);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) {
    return exceedingLength?.call(failedValue, max);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (exceedingLength != null) {
      return exceedingLength(failedValue, max);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) {
    return exceedingLength(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) {
    return exceedingLength?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (exceedingLength != null) {
      return exceedingLength(this);
    }
    return orElse();
  }
}

abstract class ValueExceedingLength<T> implements ValueFailure<T> {
  const factory ValueExceedingLength(
      {required final T failedValue,
      required final int max}) = _$ValueExceedingLength<T>;

  @override
  T get failedValue;
  int get max;
  @override
  @JsonKey(ignore: true)
  _$$ValueExceedingLengthCopyWith<T, _$ValueExceedingLength<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValueSubsceedingLengthCopyWith<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  factory _$$ValueSubsceedingLengthCopyWith(_$ValueSubsceedingLength<T> value,
          $Res Function(_$ValueSubsceedingLength<T>) then) =
      __$$ValueSubsceedingLengthCopyWithImpl<T, $Res>;
  @override
  $Res call({T failedValue, int min});
}

/// @nodoc
class __$$ValueSubsceedingLengthCopyWithImpl<T, $Res>
    extends _$ValueFailureCopyWithImpl<T, $Res>
    implements _$$ValueSubsceedingLengthCopyWith<T, $Res> {
  __$$ValueSubsceedingLengthCopyWithImpl(_$ValueSubsceedingLength<T> _value,
      $Res Function(_$ValueSubsceedingLength<T>) _then)
      : super(_value, (v) => _then(v as _$ValueSubsceedingLength<T>));

  @override
  _$ValueSubsceedingLength<T> get _value =>
      super._value as _$ValueSubsceedingLength<T>;

  @override
  $Res call({
    Object? failedValue = freezed,
    Object? min = freezed,
  }) {
    return _then(_$ValueSubsceedingLength<T>(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
      min: min == freezed
          ? _value.min
          : min // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$ValueSubsceedingLength<T> implements ValueSubsceedingLength<T> {
  const _$ValueSubsceedingLength(
      {required this.failedValue, required this.min});

  @override
  final T failedValue;
  @override
  final int min;

  @override
  String toString() {
    return 'ValueFailure<$T>.subceedingLength(failedValue: $failedValue, min: $min)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValueSubsceedingLength<T> &&
            const DeepCollectionEquality()
                .equals(other.failedValue, failedValue) &&
            const DeepCollectionEquality().equals(other.min, min));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(failedValue),
      const DeepCollectionEquality().hash(min));

  @JsonKey(ignore: true)
  @override
  _$$ValueSubsceedingLengthCopyWith<T, _$ValueSubsceedingLength<T>>
      get copyWith => __$$ValueSubsceedingLengthCopyWithImpl<T,
          _$ValueSubsceedingLength<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) {
    return subceedingLength(failedValue, min);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) {
    return subceedingLength?.call(failedValue, min);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (subceedingLength != null) {
      return subceedingLength(failedValue, min);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) {
    return subceedingLength(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) {
    return subceedingLength?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (subceedingLength != null) {
      return subceedingLength(this);
    }
    return orElse();
  }
}

abstract class ValueSubsceedingLength<T> implements ValueFailure<T> {
  const factory ValueSubsceedingLength(
      {required final T failedValue,
      required final int min}) = _$ValueSubsceedingLength<T>;

  @override
  T get failedValue;
  int get min;
  @override
  @JsonKey(ignore: true)
  _$$ValueSubsceedingLengthCopyWith<T, _$ValueSubsceedingLength<T>>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValueEmptyCopyWith<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  factory _$$ValueEmptyCopyWith(
          _$ValueEmpty<T> value, $Res Function(_$ValueEmpty<T>) then) =
      __$$ValueEmptyCopyWithImpl<T, $Res>;
  @override
  $Res call({T failedValue});
}

/// @nodoc
class __$$ValueEmptyCopyWithImpl<T, $Res>
    extends _$ValueFailureCopyWithImpl<T, $Res>
    implements _$$ValueEmptyCopyWith<T, $Res> {
  __$$ValueEmptyCopyWithImpl(
      _$ValueEmpty<T> _value, $Res Function(_$ValueEmpty<T>) _then)
      : super(_value, (v) => _then(v as _$ValueEmpty<T>));

  @override
  _$ValueEmpty<T> get _value => super._value as _$ValueEmpty<T>;

  @override
  $Res call({
    Object? failedValue = freezed,
  }) {
    return _then(_$ValueEmpty<T>(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$ValueEmpty<T> implements ValueEmpty<T> {
  const _$ValueEmpty({required this.failedValue});

  @override
  final T failedValue;

  @override
  String toString() {
    return 'ValueFailure<$T>.empty(failedValue: $failedValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValueEmpty<T> &&
            const DeepCollectionEquality()
                .equals(other.failedValue, failedValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(failedValue));

  @JsonKey(ignore: true)
  @override
  _$$ValueEmptyCopyWith<T, _$ValueEmpty<T>> get copyWith =>
      __$$ValueEmptyCopyWithImpl<T, _$ValueEmpty<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) {
    return empty(failedValue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) {
    return empty?.call(failedValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(failedValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) {
    return empty(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) {
    return empty?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (empty != null) {
      return empty(this);
    }
    return orElse();
  }
}

abstract class ValueEmpty<T> implements ValueFailure<T> {
  const factory ValueEmpty({required final T failedValue}) = _$ValueEmpty<T>;

  @override
  T get failedValue;
  @override
  @JsonKey(ignore: true)
  _$$ValueEmptyCopyWith<T, _$ValueEmpty<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValueMultilineCopyWith<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  factory _$$ValueMultilineCopyWith(
          _$ValueMultiline<T> value, $Res Function(_$ValueMultiline<T>) then) =
      __$$ValueMultilineCopyWithImpl<T, $Res>;
  @override
  $Res call({T failedValue});
}

/// @nodoc
class __$$ValueMultilineCopyWithImpl<T, $Res>
    extends _$ValueFailureCopyWithImpl<T, $Res>
    implements _$$ValueMultilineCopyWith<T, $Res> {
  __$$ValueMultilineCopyWithImpl(
      _$ValueMultiline<T> _value, $Res Function(_$ValueMultiline<T>) _then)
      : super(_value, (v) => _then(v as _$ValueMultiline<T>));

  @override
  _$ValueMultiline<T> get _value => super._value as _$ValueMultiline<T>;

  @override
  $Res call({
    Object? failedValue = freezed,
  }) {
    return _then(_$ValueMultiline<T>(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
    ));
  }
}

/// @nodoc

class _$ValueMultiline<T> implements ValueMultiline<T> {
  const _$ValueMultiline({required this.failedValue});

  @override
  final T failedValue;

  @override
  String toString() {
    return 'ValueFailure<$T>.multiline(failedValue: $failedValue)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValueMultiline<T> &&
            const DeepCollectionEquality()
                .equals(other.failedValue, failedValue));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType, const DeepCollectionEquality().hash(failedValue));

  @JsonKey(ignore: true)
  @override
  _$$ValueMultilineCopyWith<T, _$ValueMultiline<T>> get copyWith =>
      __$$ValueMultilineCopyWithImpl<T, _$ValueMultiline<T>>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) {
    return multiline(failedValue);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) {
    return multiline?.call(failedValue);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (multiline != null) {
      return multiline(failedValue);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) {
    return multiline(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) {
    return multiline?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (multiline != null) {
      return multiline(this);
    }
    return orElse();
  }
}

abstract class ValueMultiline<T> implements ValueFailure<T> {
  const factory ValueMultiline({required final T failedValue}) =
      _$ValueMultiline<T>;

  @override
  T get failedValue;
  @override
  @JsonKey(ignore: true)
  _$$ValueMultilineCopyWith<T, _$ValueMultiline<T>> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$ValueNumberTooLargeCopyWith<T, $Res>
    implements $ValueFailureCopyWith<T, $Res> {
  factory _$$ValueNumberTooLargeCopyWith(_$ValueNumberTooLarge<T> value,
          $Res Function(_$ValueNumberTooLarge<T>) then) =
      __$$ValueNumberTooLargeCopyWithImpl<T, $Res>;
  @override
  $Res call({T failedValue, num max});
}

/// @nodoc
class __$$ValueNumberTooLargeCopyWithImpl<T, $Res>
    extends _$ValueFailureCopyWithImpl<T, $Res>
    implements _$$ValueNumberTooLargeCopyWith<T, $Res> {
  __$$ValueNumberTooLargeCopyWithImpl(_$ValueNumberTooLarge<T> _value,
      $Res Function(_$ValueNumberTooLarge<T>) _then)
      : super(_value, (v) => _then(v as _$ValueNumberTooLarge<T>));

  @override
  _$ValueNumberTooLarge<T> get _value =>
      super._value as _$ValueNumberTooLarge<T>;

  @override
  $Res call({
    Object? failedValue = freezed,
    Object? max = freezed,
  }) {
    return _then(_$ValueNumberTooLarge<T>(
      failedValue: failedValue == freezed
          ? _value.failedValue
          : failedValue // ignore: cast_nullable_to_non_nullable
              as T,
      max: max == freezed
          ? _value.max
          : max // ignore: cast_nullable_to_non_nullable
              as num,
    ));
  }
}

/// @nodoc

class _$ValueNumberTooLarge<T> implements ValueNumberTooLarge<T> {
  const _$ValueNumberTooLarge({required this.failedValue, required this.max});

  @override
  final T failedValue;
  @override
  final num max;

  @override
  String toString() {
    return 'ValueFailure<$T>.numberTooLarge(failedValue: $failedValue, max: $max)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValueNumberTooLarge<T> &&
            const DeepCollectionEquality()
                .equals(other.failedValue, failedValue) &&
            const DeepCollectionEquality().equals(other.max, max));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(failedValue),
      const DeepCollectionEquality().hash(max));

  @JsonKey(ignore: true)
  @override
  _$$ValueNumberTooLargeCopyWith<T, _$ValueNumberTooLarge<T>> get copyWith =>
      __$$ValueNumberTooLargeCopyWithImpl<T, _$ValueNumberTooLarge<T>>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(T failedValue, int max) exceedingLength,
    required TResult Function(T failedValue, int min) subceedingLength,
    required TResult Function(T failedValue) empty,
    required TResult Function(T failedValue) multiline,
    required TResult Function(T failedValue, num max) numberTooLarge,
  }) {
    return numberTooLarge(failedValue, max);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
  }) {
    return numberTooLarge?.call(failedValue, max);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(T failedValue, int max)? exceedingLength,
    TResult Function(T failedValue, int min)? subceedingLength,
    TResult Function(T failedValue)? empty,
    TResult Function(T failedValue)? multiline,
    TResult Function(T failedValue, num max)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (numberTooLarge != null) {
      return numberTooLarge(failedValue, max);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(ValueExceedingLength<T> value) exceedingLength,
    required TResult Function(ValueSubsceedingLength<T> value) subceedingLength,
    required TResult Function(ValueEmpty<T> value) empty,
    required TResult Function(ValueMultiline<T> value) multiline,
    required TResult Function(ValueNumberTooLarge<T> value) numberTooLarge,
  }) {
    return numberTooLarge(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
  }) {
    return numberTooLarge?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(ValueExceedingLength<T> value)? exceedingLength,
    TResult Function(ValueSubsceedingLength<T> value)? subceedingLength,
    TResult Function(ValueEmpty<T> value)? empty,
    TResult Function(ValueMultiline<T> value)? multiline,
    TResult Function(ValueNumberTooLarge<T> value)? numberTooLarge,
    required TResult orElse(),
  }) {
    if (numberTooLarge != null) {
      return numberTooLarge(this);
    }
    return orElse();
  }
}

abstract class ValueNumberTooLarge<T> implements ValueFailure<T> {
  const factory ValueNumberTooLarge(
      {required final T failedValue,
      required final num max}) = _$ValueNumberTooLarge<T>;

  @override
  T get failedValue;
  num get max;
  @override
  @JsonKey(ignore: true)
  _$$ValueNumberTooLargeCopyWith<T, _$ValueNumberTooLarge<T>> get copyWith =>
      throw _privateConstructorUsedError;
}
