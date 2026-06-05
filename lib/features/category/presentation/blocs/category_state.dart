import 'package:equatable/equatable.dart';
import 'package:template/features/category/domain/entities/category.dart';

class CategoryState extends Equatable {
  const CategoryState({
    required this.allCategories,
    required this.navigationStack,
    required this.isLoading,
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
  final String? error;

  String? get activeParentUuid =>
      navigationStack.isEmpty ? null : navigationStack.last;

  List<Category> get currentViewCategories => allCategories.where((c) {
        final parentUuidStr = c.parentUuid?.getOrCrash();
        return parentUuidStr == activeParentUuid;
      }).toList();

  CategoryState copyWith({
    List<Category>? allCategories,
    List<String>? navigationStack,
    bool? isLoading,
    String? error,
  }) {
    return CategoryState(
      allCategories: allCategories ?? this.allCategories,
      navigationStack: navigationStack ?? this.navigationStack,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        allCategories,
        navigationStack,
        isLoading,
        error,
      ];
}
