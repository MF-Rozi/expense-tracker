import 'package:equatable/equatable.dart';

/// Represents a category that exceeded its expected monthly budget in a given
/// month (R17).
class CategoryOverrunFlag extends Equatable {
  const CategoryOverrunFlag({
    required this.categoryUuid,
    required this.categoryName,
    required this.budget,
    required this.spent,
  });

  final String categoryUuid;
  final String categoryName;
  final double budget;
  final double spent;

  /// Amount spent over the allocated budget.
  double get overrunAmount => (spent - budget).clamp(0, double.infinity);

  @override
  List<Object?> get props => [categoryUuid, categoryName, budget, spent];
}
