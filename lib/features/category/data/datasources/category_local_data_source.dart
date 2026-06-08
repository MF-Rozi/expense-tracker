import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:template/features/category/data/models/category_model.dart';

abstract class CategoryLocalDataSource {
  Stream<List<CategoryModel>> watchCategories();
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategoryWithDescendants(String uuid);
  Future<CategoryModel?> getCategoryByUuid(String uuid);
}

@LazySingleton(as: CategoryLocalDataSource)
class IsarCategoryLocalDataSource implements CategoryLocalDataSource {
  IsarCategoryLocalDataSource(this._isar);

  final Isar _isar;

  @override
  Stream<List<CategoryModel>> watchCategories() {
    return _isar.categoryModels.where().watch(fireImmediately: true);
  }

  @override
  Future<void> saveCategory(CategoryModel category) async {
    await _isar.writeTxn(() async {
      await _isar.categoryModels.put(category);
    });
  }

  @override
  Future<void> deleteCategoryWithDescendants(String uuid) async {
    await _isar.writeTxn(() async {
      // Find the category to delete
      final category =
          await _isar.categoryModels.filter().uuidEqualTo(uuid).findFirst();
      if (category == null) return;

      // Find all descendants recursively (or just by parentUuid since it's
      // hierarchical)
      // Note: If we have multiple levels, we need a recursive delete or a loop.
      // For now, let's assume we might have multiple levels.

      final uuidsToDelete = <String>{uuid};
      final toProcess = <String>[uuid];

      while (toProcess.isNotEmpty) {
        final currentUuid = toProcess.removeAt(0);
        final children = await _isar.categoryModels
            .filter()
            .parentUuidEqualTo(currentUuid)
            .findAll();
        for (final child in children) {
          if (!uuidsToDelete.contains(child.uuid)) {
            uuidsToDelete.add(child.uuid);
            toProcess.add(child.uuid);
          }
        }
      }

      for (final uuidToDelete in uuidsToDelete) {
        await _isar.categoryModels
            .filter()
            .uuidEqualTo(uuidToDelete)
            .deleteAll();
      }
    });
  }

  @override
  Future<CategoryModel?> getCategoryByUuid(String uuid) {
    return _isar.categoryModels.filter().uuidEqualTo(uuid).findFirst();
  }
}
