import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/category/domain/utils/category_budget_calculator.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Category createCategory({
    required UniqueId uuid,
    required String name,
    UniqueId? parentId,
    double budget = 0,
    CategoryType type = CategoryType.expense,
  }) {
    return Category(
      uuid: uuid,
      name: StringSingleLine(name),
      parentId: parentId,
      isSynced: false,
      updatedAt: DateTime.now(),
      type: type,
      expectedMonthlyBudget: budget,
      behavioralModifier: BehavioralModifier.active,
    );
  }

  Transaction createTx({
    required UniqueId categoryUuid,
    required double amount,
    TransactionType type = TransactionType.expense,
  }) {
    return Transaction(
      uuid: UniqueId.generate(),
      amount: Amount(amount),
      description: StringSingleLine('Test Tx'),
      date: DateTime(2026, 4, 15),
      categoryUuid: categoryUuid,
      type: type,
    );
  }

  group('CategoryBudgetCalculator.calculateTotalBudget', () {
    test('Calculates sum of leaf categories (Level 3) only', () {
      final pillarId = UniqueId.generate();
      final subParentId = UniqueId.generate();
      final leaf1Id = UniqueId.generate();
      final leaf2Id = UniqueId.generate();

      final categories = [
        createCategory(
          uuid: pillarId,
          name: 'Needs',
          budget: 1000,
        ),
        createCategory(
          uuid: subParentId,
          name: 'Food',
          parentId: pillarId,
          budget: 600,
        ),
        createCategory(
          uuid: leaf1Id,
          name: 'Groceries',
          parentId: subParentId,
          budget: 400,
        ),
        createCategory(
          uuid: leaf2Id,
          name: 'Dining',
          parentId: subParentId,
          budget: 200,
        ),
      ];

      final total = CategoryBudgetCalculator.calculateTotalBudget(categories);
      expect(total, 600.0);
    });

    test('Ignores income categories when type is expense', () {
      final pillarId = UniqueId.generate();
      final subParentId = UniqueId.generate();
      final leafExpense = UniqueId.generate();
      final leafIncome = UniqueId.generate();

      final categories = [
        createCategory(uuid: pillarId, name: 'Pillar'),
        createCategory(uuid: subParentId, name: 'Sub', parentId: pillarId),
        createCategory(
          uuid: leafExpense,
          name: 'Expense Leaf',
          parentId: subParentId,
          budget: 500,
        ),
        createCategory(
          uuid: leafIncome,
          name: 'Income Leaf',
          parentId: subParentId,
          budget: 2000,
          type: CategoryType.income,
        ),
      ];

      final total = CategoryBudgetCalculator.calculateTotalBudget(categories);
      expect(total, 500.0);
    });
  });

  group('CategoryBudgetCalculator.calculateOverrunFlags (R17)', () {
    test('Returns empty when all spending is within category budget', () {
      final pillarId = UniqueId.generate();
      final subParentId = UniqueId.generate();
      final leafId = UniqueId.generate();

      final categories = [
        createCategory(uuid: pillarId, name: 'Pillar'),
        createCategory(uuid: subParentId, name: 'Sub', parentId: pillarId),
        createCategory(
          uuid: leafId,
          name: 'Groceries',
          parentId: subParentId,
          budget: 500,
        ),
      ];

      final transactions = [
        createTx(categoryUuid: leafId, amount: 450),
      ];

      final flags = CategoryBudgetCalculator.calculateOverrunFlags(
        allCategories: categories,
        transactions: transactions,
      );

      expect(flags, isEmpty);
    });

    test('Identifies overruns when spending exceeds budget (AE8)', () {
      final pillarId = UniqueId.generate();
      final subParentId = UniqueId.generate();
      final groceriesId = UniqueId.generate();
      final diningId = UniqueId.generate();

      final categories = [
        createCategory(uuid: pillarId, name: 'Pillar'),
        createCategory(uuid: subParentId, name: 'Sub', parentId: pillarId),
        createCategory(
          uuid: groceriesId,
          name: 'Groceries',
          parentId: subParentId,
          budget: 300,
        ),
        createCategory(
          uuid: diningId,
          name: 'Dining',
          parentId: subParentId,
          budget: 200,
        ),
      ];

      final transactions = [
        createTx(categoryUuid: groceriesId, amount: 350), // Over by 50
        createTx(categoryUuid: diningId, amount: 150), // Within budget
      ];

      final flags = CategoryBudgetCalculator.calculateOverrunFlags(
        allCategories: categories,
        transactions: transactions,
      );

      expect(flags.length, 1);
      expect(flags.first.categoryName, 'Groceries');
      expect(flags.first.budget, 300.0);
      expect(flags.first.spent, 350.0);
      expect(flags.first.overrunAmount, 50.0);
    });

    test('Aggregates child spending into parent category with budget', () {
      final parentId = UniqueId.generate();
      final childId = UniqueId.generate();

      final categories = [
        createCategory(uuid: parentId, name: 'Transport', budget: 100),
        createCategory(uuid: childId, name: 'Fuel', parentId: parentId),
      ];

      final transactions = [
        createTx(categoryUuid: childId, amount: 120),
      ];

      final flags = CategoryBudgetCalculator.calculateOverrunFlags(
        allCategories: categories,
        transactions: transactions,
      );

      expect(flags.length, 1);
      expect(flags.first.categoryName, 'Transport');
      expect(flags.first.spent, 120.0);
      expect(flags.first.overrunAmount, 20.0);
    });
  });
}
