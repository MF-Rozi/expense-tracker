import 'package:expense_tracker/features/category/data/models/category_model.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryModel', () {
    final tUuid = UniqueId('550e8400-e29b-41d4-a716-446655440000');
    final tParentId = UniqueId('550e8400-e29b-41d4-a716-446655440001');
    final tDate = DateTime(2026, 6, 3);

    final tCategory = Category(
      uuid: tUuid,
      name: StringSingleLine('Food'),
      isSynced: false,
      updatedAt: tDate,
      parentId: tParentId,
      type: CategoryType.expense,
      expectedMonthlyBudget: 1500,
      behavioralModifier: BehavioralModifier.active,
    );

    test('should map from entity correctly', () {
      final model = CategoryModel.fromEntity(tCategory);

      expect(model.uuid, tUuid.getOrCrash());
      expect(model.name, 'Food');
      expect(model.isSynced, false);
      expect(model.updatedAt, tDate);
      expect(model.parentId, tParentId.getOrCrash());
      expect(model.type, CategoryType.expense);
      expect(model.expectedMonthlyBudget, 1500);
      expect(model.behavioralModifier, BehavioralModifier.active);
    });

    test('should map to entity correctly', () {
      final model = CategoryModel()
        ..uuid = tUuid.getOrCrash()
        ..name = 'Food'
        ..isSynced = false
        ..updatedAt = tDate
        ..parentId = tParentId.getOrCrash()
        ..type = CategoryType.expense
        ..expectedMonthlyBudget = 1500
        ..behavioralModifier = BehavioralModifier.active;

      final entity = model.toEntity();

      expect(entity, tCategory);
    });

    test('should handle null parentId correctly', () {
      final rootCategory = Category(
        uuid: tUuid,
        name: StringSingleLine('Root'),
        isSynced: true,
        updatedAt: tDate,
        type: CategoryType.income,
        expectedMonthlyBudget: 500,
        behavioralModifier: BehavioralModifier.recurring,
      );

      final model = CategoryModel.fromEntity(rootCategory);
      expect(model.parentId, isNull);
      expect(model.type, CategoryType.income);
      expect(model.expectedMonthlyBudget, 500);
      expect(model.behavioralModifier, BehavioralModifier.recurring);

      final entity = model.toEntity();
      expect(entity.parentId, isNull);
      expect(entity, rootCategory);
    });
  });
}
