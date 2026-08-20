import 'package:equatable/equatable.dart';
import 'package:expense_tracker/features/category/domain/entities/category.dart';

class CategoryState extends Equatable {
  const CategoryState({
    required this.allCategories,
    required this.navigationStack,
    required this.isLoading,
    this.selectedType = CategoryType.expense,
    this.error,
  });

  factory CategoryState.initial() {
    return const CategoryState(
      allCategories: [],
      navigationStack: [],
      isLoading: false,
    );
  }

  final List<Category> allCategories;
  final List<String> navigationStack;
  final bool isLoading;
  final CategoryType selectedType;
  final String? error;

  String? get activeParentUuid =>
      navigationStack.isEmpty ? null : navigationStack.last;

  List<Category> get currentViewCategories => allCategories.where((c) {
        final parentIdStr = c.parentId?.getOrCrash();
        return parentIdStr == activeParentUuid;
      }).toList();

  List<Category> get activePillars {
    return allCategories
        .where((c) => c.isRoot && c.type == selectedType)
        .toList();
  }

  Map<String, double> get pillarBudgets {
    final budgets = <String, double>{};
    final pillars = activePillars;

    for (final pillar in pillars) {
      final pillarIdStr = pillar.uuid.getOrCrash();
      final subParents = allCategories.where(
        (c) => c.parentId?.getOrCrash() == pillarIdStr,
      );

      var sum = 0.0;
      for (final subParent in subParents) {
        final subParentIdStr = subParent.uuid.getOrCrash();
        final children = allCategories.where(
          (c) => c.parentId?.getOrCrash() == subParentIdStr,
        );
        for (final child in children) {
          sum += child.expectedMonthlyBudget;
        }
      }
      budgets[pillarIdStr] = sum;
    }

    return budgets;
  }

  double get totalBudget {
    return allCategories
        .where((c) => c.type == selectedType && c.parentId != null)
        .where((c) {
          final parent = allCategories.firstWhere(
            (parent) => parent.uuid == c.parentId,
            orElse: () => c,
          );
          return parent != c && parent.parentId != null;
        })
        .map((c) => c.expectedMonthlyBudget)
        .fold(0, (sum, val) => sum + val);
  }

  CategoryState copyWith({
    List<Category>? allCategories,
    List<String>? navigationStack,
    bool? isLoading,
    CategoryType? selectedType,
    Object? error = const Object(),
  }) {
    return CategoryState(
      allCategories: allCategories ?? this.allCategories,
      navigationStack: navigationStack ?? this.navigationStack,
      isLoading: isLoading ?? this.isLoading,
      selectedType: selectedType ?? this.selectedType,
      error: error == const Object() ? this.error : (error as String?),
    );
  }

  @override
  List<Object?> get props => [
        allCategories,
        navigationStack,
        isLoading,
        selectedType,
        error,
      ];
}
