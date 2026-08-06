import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';

abstract class CategoryLocalDataSource {
  Stream<List<CategoryModel>> watchCategories();
  Future<void> saveCategory(CategoryModel category);
  Future<void> deleteCategoryWithDescendants(String uuid);
  Future<CategoryModel?> getCategoryByUuid(String uuid);
}

@LazySingleton(as: CategoryLocalDataSource)
class IsarCategoryLocalDataSource implements CategoryLocalDataSource {
  IsarCategoryLocalDataSource(this._isar) {
    _seedPillarsIfNeeded();
  }

  final Isar _isar;

  Future<void> _seedPillarsIfNeeded() async {
    final count = await _isar.categoryModels.count();
    if (count == 0) {
      await _isar.writeTxn(() async {
        final defaultPillars = [
          // Expense Pillars
          CategoryModel()
            ..uuid = 'essential'
            ..name = 'Essential'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.expense
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
          CategoryModel()
            ..uuid = 'lifestyle'
            ..name = 'Lifestyle'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.expense
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
          CategoryModel()
            ..uuid = 'growth'
            ..name = 'Financial Growth'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.expense
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
          // Income Pillars
          CategoryModel()
            ..uuid = 'primary_revenue'
            ..name = 'Primary Revenue'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.income
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
          CategoryModel()
            ..uuid = 'secondary_income'
            ..name = 'Secondary Income'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.income
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
          CategoryModel()
            ..uuid = 'portfolio_growth'
            ..name = 'Portfolio Growth'
            ..isSynced = false
            ..updatedAt = DateTime.now()
            ..parentId = null
            ..type = CategoryType.income
            ..expectedMonthlyBudget = 0.0
            ..behavioralModifier = BehavioralModifier.active,
        ];
        await _isar.categoryModels.putAll(defaultPillars);
      });
    }
  }

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

      // Find all descendants recursively (or just by parentId since it's
      // hierarchical)
      final uuidsToDelete = <String>{uuid};
      final toProcess = <String>[uuid];

      while (toProcess.isNotEmpty) {
        final currentUuid = toProcess.removeAt(0);
        final children = await _isar.categoryModels
            .filter()
            .parentIdEqualTo(currentUuid)
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
