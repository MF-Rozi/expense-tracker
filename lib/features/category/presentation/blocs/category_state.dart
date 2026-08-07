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
      selectedType: CategoryType.expense,
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
    final Map<String, double> budgets = {};
    // Level 1 Pillars of the active type
    final pillars = activePillars;

    for (final pillar in pillars) {
      final pillarIdStr = pillar.uuid.getOrCrash();
      // Level 2 Sub-parents under this pillar
      final subParents = allCategories.where((c) => c.parentId?.getOrCrash() == pillarIdStr);

      double sum = 0.0;
      for (final subParent in subParents) {
        final subParentIdStr = subParent.uuid.getOrCrash();
        // Level 3 Child Envelopes under this sub-parent
        final children = allCategories.where((c) => c.parentId?.getOrCrash() == subParentIdStr);
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
          // Check if parent exists and is Level 2 (meaning this category is Level 3 child envelope)
          final parent = allCategories.firstWhere(
            (parent) => parent.uuid == c.parentId,
            orElse: () => c, // fallback to self if not found
          );
          return parent != c && parent.parentId != null;
        })
        .map((c) => c.expectedMonthlyBudget)
        .fold(0.0, (sum, val) => sum + val);
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

