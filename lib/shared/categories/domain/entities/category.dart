import 'package:expense_tracker/shared/enitites/value_objects.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
class Category with _$Category {
  const factory Category({
    required UniqueId id,
    required StringSingleLine name,
    required String icon,
    Category? parent,
  }) = _Category;
}
