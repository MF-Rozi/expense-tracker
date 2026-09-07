import 'package:expense_tracker/features/category/domain/entities/category.dart';

extension CategoryTreeX on Category {
  /// Sums expected monthly budgets across this category's subtree so
  /// Pillars and Sub-Parents show aggregated totals.
  ///
  /// A category's own budget counts only when it has no children — the
  /// budget model expects allocations on leaves. The walk is capped at
  /// [maxDepth] levels (Pillar → Sub-Parent → Envelope), which keeps
  /// every surface in agreement and guards against infinite recursion
  /// on malformed parent cycles.
  double sumBudgetUnder(
    List<Category> allCategories, {
    int maxDepth = 3,
  }) {
    if (maxDepth <= 0) return 0;
    final parentId = uuid.getOrCrash();
    final directChildren = allCategories
        .where((c) => c.parentId?.getOrCrash() == parentId)
        .toList();
    if (directChildren.isEmpty) {
      return expectedMonthlyBudget;
    }
    return directChildren.fold(
      0,
      (sum, c) => sum + c.sumBudgetUnder(allCategories, maxDepth: maxDepth - 1),
    );
  }
}
