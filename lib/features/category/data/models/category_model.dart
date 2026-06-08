import 'package:isar_community/isar.dart';
import 'package:template/features/category/domain/entities/category.dart';
import 'package:template/shared/domain/entities/value_objects.dart';

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
      ..parentUuid = entity.parentUuid?.getOrCrash();
  }

  Id id = Isar.autoIncrement;

  @Index(unique: true, replace: true)
  late String uuid;

  @Index()
  String? parentUuid;

  late String name;

  late bool isSynced;

  late DateTime updatedAt;

  Category toEntity() {
    return Category(
      uuid: UniqueId(uuid),
      name: StringSingleLine(name),
      isSynced: isSynced,
      updatedAt: updatedAt,
      parentUuid: parentUuid != null ? UniqueId(parentUuid!) : null,
    );
  }
}
