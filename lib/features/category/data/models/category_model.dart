import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:isar_community/isar.dart';

part 'category_model.g.dart';

@collection
class CategoryModel {
  CategoryModel();

  factory CategoryModel.fromEntity(Category entity) {
    return CategoryModel()
      ..uuid = entity.uuid.getOrCrash()
      ..name = entity.name.getOrCrash()
      ..isSynced = entity.isSynced
      ..updatedAt = entity.updatedAt
      ..parentId = entity.parentId?.getOrCrash()
      ..type = entity.type
      ..expectedMonthlyBudget = entity.expectedMonthlyBudget
      ..behavioralModifier = entity.behavioralModifier;
  }

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  String? parentId;

  late String name;

  late bool isSynced;

  late DateTime updatedAt;

  @enumerated
  late CategoryType type;

  late double expectedMonthlyBudget;

  @enumerated
  late BehavioralModifier behavioralModifier;

  Category toEntity() {
    return Category(
      uuid: UniqueId(uuid),
      name: StringSingleLine(name),
      isSynced: isSynced,
      updatedAt: updatedAt,
      parentId: parentId != null ? UniqueId(parentId!) : null,
      type: type,
      expectedMonthlyBudget: expectedMonthlyBudget,
      behavioralModifier: behavioralModifier,
    );
  }
}
