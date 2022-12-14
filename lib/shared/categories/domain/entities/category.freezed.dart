// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'category.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$Category {
  UniqueId get id => throw _privateConstructorUsedError;
  StringSingleLine get name => throw _privateConstructorUsedError;
  String get icon => throw _privateConstructorUsedError;
  Category? get parent => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $CategoryCopyWith<Category> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CategoryCopyWith<$Res> {
  factory $CategoryCopyWith(Category value, $Res Function(Category) then) =
      _$CategoryCopyWithImpl<$Res>;
  $Res call(
      {UniqueId id, StringSingleLine name, String icon, Category? parent});

  $CategoryCopyWith<$Res>? get parent;
}

/// @nodoc
class _$CategoryCopyWithImpl<$Res> implements $CategoryCopyWith<$Res> {
  _$CategoryCopyWithImpl(this._value, this._then);

  final Category _value;
  // ignore: unused_field
  final $Res Function(Category) _then;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? parent = freezed,
  }) {
    return _then(_value.copyWith(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as StringSingleLine,
      icon: icon == freezed
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      parent: parent == freezed
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as Category?,
    ));
  }

  @override
  $CategoryCopyWith<$Res>? get parent {
    if (_value.parent == null) {
      return null;
    }

    return $CategoryCopyWith<$Res>(_value.parent!, (value) {
      return _then(_value.copyWith(parent: value));
    });
  }
}

/// @nodoc
abstract class _$$_CategoryCopyWith<$Res> implements $CategoryCopyWith<$Res> {
  factory _$$_CategoryCopyWith(
          _$_Category value, $Res Function(_$_Category) then) =
      __$$_CategoryCopyWithImpl<$Res>;
  @override
  $Res call(
      {UniqueId id, StringSingleLine name, String icon, Category? parent});

  @override
  $CategoryCopyWith<$Res>? get parent;
}

/// @nodoc
class __$$_CategoryCopyWithImpl<$Res> extends _$CategoryCopyWithImpl<$Res>
    implements _$$_CategoryCopyWith<$Res> {
  __$$_CategoryCopyWithImpl(
      _$_Category _value, $Res Function(_$_Category) _then)
      : super(_value, (v) => _then(v as _$_Category));

  @override
  _$_Category get _value => super._value as _$_Category;

  @override
  $Res call({
    Object? id = freezed,
    Object? name = freezed,
    Object? icon = freezed,
    Object? parent = freezed,
  }) {
    return _then(_$_Category(
      id: id == freezed
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as UniqueId,
      name: name == freezed
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as StringSingleLine,
      icon: icon == freezed
          ? _value.icon
          : icon // ignore: cast_nullable_to_non_nullable
              as String,
      parent: parent == freezed
          ? _value.parent
          : parent // ignore: cast_nullable_to_non_nullable
              as Category?,
    ));
  }
}

/// @nodoc

class _$_Category implements _Category {
  const _$_Category(
      {required this.id, required this.name, required this.icon, this.parent});

  @override
  final UniqueId id;
  @override
  final StringSingleLine name;
  @override
  final String icon;
  @override
  final Category? parent;

  @override
  String toString() {
    return 'Category(id: $id, name: $name, icon: $icon, parent: $parent)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Category &&
            const DeepCollectionEquality().equals(other.id, id) &&
            const DeepCollectionEquality().equals(other.name, name) &&
            const DeepCollectionEquality().equals(other.icon, icon) &&
            const DeepCollectionEquality().equals(other.parent, parent));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(id),
      const DeepCollectionEquality().hash(name),
      const DeepCollectionEquality().hash(icon),
      const DeepCollectionEquality().hash(parent));

  @JsonKey(ignore: true)
  @override
  _$$_CategoryCopyWith<_$_Category> get copyWith =>
      __$$_CategoryCopyWithImpl<_$_Category>(this, _$identity);
}

abstract class _Category implements Category {
  const factory _Category(
      {required final UniqueId id,
      required final StringSingleLine name,
      required final String icon,
      final Category? parent}) = _$_Category;

  @override
  UniqueId get id;
  @override
  StringSingleLine get name;
  @override
  String get icon;
  @override
  Category? get parent;
  @override
  @JsonKey(ignore: true)
  _$$_CategoryCopyWith<_$_Category> get copyWith =>
      throw _privateConstructorUsedError;
}
