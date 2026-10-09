import 'package:expense_tracker/features/category/domain/entities/category.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';

/// Shared domain helper for category budget aggregation and overrun analysis
/// (R14, R17).
class CategoryBudgetCalculator {
  const CategoryBudgetCalculator._();

  /// Calculates total expected monthly budget across leaf categories of [type].
  /// Matches CategoryState.totalBudget aggregation logic.
  static double calculateTotalBudget(
    List<Category> allCategories, {
    CategoryType type = CategoryType.expense,
  }) {
    return allCategories
        .where((c) => c.type == type && c.parentId != null)
        .where((c) {
          final parent = allCategories.cast<Category?>().firstWhere(
                (parent) => parent?.uuid == c.parentId,
                orElse: () => null,
              );
          return parent != null && parent.parentId != null;
        })
        .map((c) => c.expectedMonthlyBudget)
        .fold(0, (sum, val) => sum + val);
  }

  /// Identifies categories exceeding their individual budgets for a given set
  /// of transactions (R17).
  static List<CategoryOverrunFlag> calculateOverrunFlags({
    required List<Category> allCategories,
    required List<Transaction> transactions,
  }) {
    final expenseTxs =
        transactions.where((tx) => tx.type == TransactionType.expense);

    final spendByCategory = <String, double>{};
    for (final tx in expenseTxs) {
      final id = tx.categoryUuid.getOrCrash();
      spendByCategory[id] =
          (spendByCategory[id] ?? 0) + tx.amount.getOrCrash();
    }

    final flags = <CategoryOverrunFlag>[];

    for (final category in allCategories) {
      if (category.type != CategoryType.expense) continue;
      if (category.expectedMonthlyBudget <= 0) continue;

      final catId = category.uuid.getOrCrash();
      final descendantUuids =
          _findDescendantUuids(category.uuid, allCategories);

      var totalSpent = spendByCategory[catId] ?? 0;
      for (final descId in descendantUuids) {
        totalSpent += spendByCategory[descId] ?? 0;
      }

      if (totalSpent > category.expectedMonthlyBudget) {
        flags.add(
          CategoryOverrunFlag(
            categoryUuid: catId,
            categoryName: category.name.getOrCrash(),
            budget: category.expectedMonthlyBudget,
            spent: totalSpent,
          ),
        );
      }
    }

    return flags;
  }

  static Set<String> _findDescendantUuids(
    UniqueId parentId,
    List<Category> allCategories,
  ) {
    final descendants = <String>{};
    for (final category in allCategories) {
      if (category.parentId == parentId) {
        descendants
          ..add(category.uuid.getOrCrash())
          ..addAll(_findDescendantUuids(category.uuid, allCategories));
      }
    }
    return descendants;
  }
}
