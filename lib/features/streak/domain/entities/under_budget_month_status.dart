import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/streak/domain/entities/category_overrun_flag.dart';

/// Encapsulates monthly budget performance for under-budget streak calculations
/// (R14, R17).
class UnderBudgetMonthStatus extends Equatable {
  const UnderBudgetMonthStatus({
    required this.month,
    required this.totalBudget,
    required this.totalSpent,
    required this.isOnTrack,
    this.overrunFlags = const [],
  });

  final DateTime month;
  final double totalBudget;
  final double totalSpent;
  final bool isOnTrack;
  final List<CategoryOverrunFlag> overrunFlags;

  bool get hasBudget => totalBudget > 0;
  double get remainingBudget =>
      (totalBudget - totalSpent).clamp(0, double.infinity);
  double get overrunBudget =>
      (totalSpent - totalBudget).clamp(0, double.infinity);

  @override
  List<Object?> get props => [
        month,
        totalBudget,
        totalSpent,
        isOnTrack,
        overrunFlags,
      ];
}
