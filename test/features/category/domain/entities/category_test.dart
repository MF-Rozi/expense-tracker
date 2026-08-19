import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Category', () {
    test('represents a root category', () {
      final category = Category(
        uuid: UniqueId('f398a930-77b3-4395-be13-4bc5b53cb2f9'),
        name: StringSingleLine('Food'),
        isSynced: false,
        updatedAt: DateTime.utc(2026, 6, 3),
        type: CategoryType.expense,
        expectedMonthlyBudget: 500,
        behavioralModifier: BehavioralModifier.active,
      );

      expect(category.isRoot, isTrue);
      expect(category.parentId, isNull);
      expect(category.props, [
        category.uuid,
        category.name,
        null,
        false,
        DateTime.utc(2026, 6, 3),
        CategoryType.expense,
        500.0,
        BehavioralModifier.active,
      ]);
    });

    test('represents a child category', () {
      final parentId = UniqueId('a7d7b2f7-4d18-43f0-bf8f-4f3f6d9f4b3b');
      final category = Category(
        uuid: UniqueId('b3f76e40-4f1f-4c40-9d16-1c3a4f8a0f11'),
        name: StringSingleLine('Groceries'),
        parentId: parentId,
        isSynced: true,
        updatedAt: DateTime.utc(2026, 6, 3, 12),
        type: CategoryType.expense,
        expectedMonthlyBudget: 200,
        behavioralModifier: BehavioralModifier.active,
      );

      expect(category.isRoot, isFalse);
      expect(category.parentId, parentId);
      expect(category.props, [
        category.uuid,
        category.name,
        parentId,
        true,
        DateTime.utc(2026, 6, 3, 12),
        CategoryType.expense,
        200.0,
        BehavioralModifier.active,
      ]);
    });
  });
}
