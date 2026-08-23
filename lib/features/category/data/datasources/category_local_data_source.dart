import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:injectable/injectable.dart';
import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

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

  CategoryModel _createCategory({
    required String name,
    required CategoryType type,
    String? parentId,
    BehavioralModifier modifier = BehavioralModifier.active,
    double budget = 0.0,
  }) {
    return CategoryModel()
      ..uuid = const Uuid().v4()
      ..name = name
      ..isSynced = false
      ..updatedAt = DateTime.now()
      ..parentId = parentId
      ..type = type
      ..expectedMonthlyBudget = budget
      ..behavioralModifier = modifier;
  }

  Future<void> _seedPillarsIfNeeded() async {
    try {
      final totalCount = await _isar.categoryModels.count();
      final nonRootCount =
          await _isar.categoryModels.filter().parentIdIsNotNull().count();

      // Definition of the default hierarchy
      final defaultHierarchy = <({
        String pillarName,
        CategoryType type,
        Map<String, List<({String name, BehavioralModifier modifier})>> subParents,
      })>[
        // ─── EXPENSE PILLARS ───
        (
          pillarName: 'Essential',
          type: CategoryType.expense,
          subParents: {
            'Groceries & Household': [
              (name: 'Groceries', modifier: BehavioralModifier.active),
              (name: 'Household Supplies', modifier: BehavioralModifier.active),
              (name: 'Electricity & Water', modifier: BehavioralModifier.recurring),
              (name: 'Internet & Mobile', modifier: BehavioralModifier.recurring),
            ],
            'Transportation': [
              (name: 'Fuel & Gas', modifier: BehavioralModifier.active),
              (name: 'Public Transit & Tolls', modifier: BehavioralModifier.active),
              (name: 'Vehicle Maintenance', modifier: BehavioralModifier.active),
            ],
            'Healthcare': [
              (name: 'Medical & Pharmacy', modifier: BehavioralModifier.active),
              (name: 'Health Insurance', modifier: BehavioralModifier.recurring),
            ],
            'Education': [
              (name: 'Tuition & School Fees', modifier: BehavioralModifier.recurring),
              (name: 'Books & Courses', modifier: BehavioralModifier.active),
            ],
          },
        ),
        (
          pillarName: 'Lifestyle',
          type: CategoryType.expense,
          subParents: {
            'Shopping': [
              (name: 'Clothing & Apparel', modifier: BehavioralModifier.active),
              (name: 'Online Shopping', modifier: BehavioralModifier.active),
              (name: 'Gadgets & Electronics', modifier: BehavioralModifier.active),
            ],
            'Dining & Leisure': [
              (name: 'Restaurants & Dining Out', modifier: BehavioralModifier.active),
              (name: 'Coffee & Snacks', modifier: BehavioralModifier.active),
            ],
            'Entertainment': [
              (name: 'Streaming & Subscriptions', modifier: BehavioralModifier.recurring),
              (name: 'Hobbies & Gaming', modifier: BehavioralModifier.active),
              (name: 'Travel & Vacations', modifier: BehavioralModifier.active),
            ],
            'Donations & Charity': [
              (name: 'Charity & Tithe', modifier: BehavioralModifier.recurring),
              (name: 'Donations & Contributions', modifier: BehavioralModifier.active),
            ],
            'Work & Career': [
              (name: 'Work & Office Supplies', modifier: BehavioralModifier.active),
            ],
          },
        ),
        (
          pillarName: 'Financial Growth',
          type: CategoryType.expense,
          subParents: {
            'Investments': [
              (name: 'Stocks', modifier: BehavioralModifier.active),
              (name: 'Mutual Funds', modifier: BehavioralModifier.active),
              (name: 'Gold & Precious Metals', modifier: BehavioralModifier.active),
              (name: 'Crypto & Other Assets', modifier: BehavioralModifier.active),
            ],
            'Savings': [
              (name: 'Emergency Fund', modifier: BehavioralModifier.passive),
              (name: 'High-Yield Savings', modifier: BehavioralModifier.passive),
            ],
          },
        ),
        // ─── INCOME PILLARS ───
        (
          pillarName: 'Primary Revenue',
          type: CategoryType.income,
          subParents: {
            'Salary': [
              (name: 'Base Salary', modifier: BehavioralModifier.recurring),
              (name: 'Allowances & Benefits', modifier: BehavioralModifier.recurring),
            ],
            'Business': [
              (name: 'Business Revenue & Sales', modifier: BehavioralModifier.active),
            ],
          },
        ),
        (
          pillarName: 'Secondary Income',
          type: CategoryType.income,
          subParents: {
            'Bonus & Incentives': [
              (name: 'Performance Bonus', modifier: BehavioralModifier.passive),
              (name: 'Holiday Bonus', modifier: BehavioralModifier.passive),
            ],
            'Side Hustle & Sales': [
              (name: 'Freelance & Consulting', modifier: BehavioralModifier.active),
              (name: 'Item Resale', modifier: BehavioralModifier.active),
            ],
            'Gifts & Grants': [
              (name: 'Gifts & Financial Support', modifier: BehavioralModifier.passive),
            ],
          },
        ),
        (
          pillarName: 'Portfolio Growth',
          type: CategoryType.income,
          subParents: {
            'Investment Returns': [
              (name: 'Stock Dividends & Gains', modifier: BehavioralModifier.passive),
              (name: 'Deposit Interest & Yields', modifier: BehavioralModifier.passive),
              (name: 'Rental & Property Income', modifier: BehavioralModifier.passive),
            ],
          },
        ),
      ];

      if (totalCount == 0) {
        await _isar.writeTxn(() async {
          final allModels = <CategoryModel>[];

          for (final group in defaultHierarchy) {
            final pillar = _createCategory(
              name: group.pillarName,
              type: group.type,
              parentId: null,
            );
            allModels.add(pillar);

            for (final entry in group.subParents.entries) {
              final subParent = _createCategory(
                name: entry.key,
                type: group.type,
                parentId: pillar.uuid,
              );
              allModels.add(subParent);

              for (final child in entry.value) {
                final childModel = _createCategory(
                  name: child.name,
                  type: group.type,
                  parentId: subParent.uuid,
                  modifier: child.modifier,
                );
                allModels.add(childModel);
              }
            }
          }

          await _isar.categoryModels.putAll(allModels);
        });
      } else if (nonRootCount == 0) {
        // If only pillars were seeded previously, seed default sub-categories under existing pillars
        final existingPillars =
            await _isar.categoryModels.filter().parentIdIsNull().findAll();

        await _isar.writeTxn(() async {
          final newModels = <CategoryModel>[];

          for (final group in defaultHierarchy) {
            final pillar = existingPillars.firstWhere(
              (p) => p.name.toLowerCase() == group.pillarName.toLowerCase(),
              orElse: () => _createCategory(
                name: group.pillarName,
                type: group.type,
              ),
            );

            if (pillar.id == Isar.autoIncrement) {
              newModels.add(pillar);
            }

            for (final entry in group.subParents.entries) {
              final subParent = _createCategory(
                name: entry.key,
                type: group.type,
                parentId: pillar.uuid,
              );
              newModels.add(subParent);

              for (final child in entry.value) {
                final childModel = _createCategory(
                  name: child.name,
                  type: group.type,
                  parentId: subParent.uuid,
                  modifier: child.modifier,
                );
                newModels.add(childModel);
              }
            }
          }

          await _isar.categoryModels.putAll(newModels);
        });
      } else {
        // Migration check for legacy non-UUID seeded pillars
        final legacyPillars = await _isar.categoryModels
            .filter()
            .uuidEqualTo('essential')
            .or()
            .uuidEqualTo('lifestyle')
            .or()
            .uuidEqualTo('growth')
            .or()
            .uuidEqualTo('primary_revenue')
            .or()
            .uuidEqualTo('secondary_income')
            .or()
            .uuidEqualTo('portfolio_growth')
            .findAll();

        if (legacyPillars.isNotEmpty) {
          await _isar.writeTxn(() async {
            for (final cat in legacyPillars) {
              final oldUuid = cat.uuid;
              final newUuid = const Uuid().v4();
              cat.uuid = newUuid;
              await _isar.categoryModels.put(cat);

              final children = await _isar.categoryModels
                  .filter()
                  .parentIdEqualTo(oldUuid)
                  .findAll();
              for (final child in children) {
                child.parentId = newUuid;
                await _isar.categoryModels.put(child);
              }
            }
          });
        }
      }
    } catch (_) {
      // Ignore in tests or if Isar collection is not available
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
