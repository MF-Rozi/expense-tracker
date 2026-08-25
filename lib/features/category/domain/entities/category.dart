import 'package:equatable/equatable.dart';
import 'package:expense_tracker/shared/domain/entities/value_objects.dart';

enum BehavioralModifier { active, passive, recurring }

enum CategoryType { expense, income }

class Category extends Equatable {
  const Category({
    required this.uuid,
    required this.name,
    required this.isSynced,
    required this.updatedAt,
    required this.type,
    required this.expectedMonthlyBudget,
    required this.behavioralModifier,
    this.parentId,
  });

  final UniqueId uuid;
  final StringSingleLine name;
  final UniqueId? parentId;
  final bool isSynced;
  final DateTime updatedAt;
  final CategoryType type;
  final double expectedMonthlyBudget;
  final BehavioralModifier behavioralModifier;

  bool get isRoot => parentId == null;

  bool isValidHierarchy(List<Category> allCategories) {
    if (parentId == null) {
      return true; // Root is always valid
    }

    Category? findById(UniqueId id) {
      for (final c in allCategories) {
        if (c.uuid == id) return c;
      }
      return null;
    }

    final parent = findById(parentId!);
    if (parent == null) return false;

    // Check if parent's parent is null (parent is Level 1)
    if (parent.parentId == null) {
      return true; // Level 2 is valid
    }

    // Check grandparent
    final grandParent = findById(parent.parentId!);
    if (grandParent == null) return false;

    // Grandparent must be a root (Level 1) for this to be a
    // valid Level 3 category
    if (grandParent.parentId == null) {
      return true; // Level 3 is valid
    }

    return false; // Level 4 or deeper is invalid
  }

  /// Returns the root ancestor (Pillar) of this category, or itself if it is a root.
  Category getRootPillar(List<Category> allCategories) {
    if (parentId == null) return this;
    final visited = <UniqueId>{uuid};
    Category current = this;
    while (current.parentId != null) {
      if (visited.contains(current.parentId)) break;
      visited.add(current.parentId!);
      final parent = allCategories.cast<Category?>().firstWhere(
            (c) => c?.uuid == current.parentId,
            orElse: () => null,
          );
      if (parent == null) break;
      current = parent;
    }
    return current;
  }

  /// Returns the ordered list of categories from root Pillar down to this category.
  List<Category> getHierarchyChain(List<Category> allCategories) {
    final chain = <Category>[this];
    final visited = <UniqueId>{uuid};
    Category current = this;
    while (current.parentId != null) {
      if (visited.contains(current.parentId)) break;
      visited.add(current.parentId!);
      final parent = allCategories.cast<Category?>().firstWhere(
            (c) => c?.uuid == current.parentId,
            orElse: () => null,
          );
      if (parent == null) break;
      chain.insert(0, parent);
      current = parent;
    }
    return chain;
  }

  /// Returns a formatted breadcrumb string (e.g. "Essential › Housing › Rent").
  String getBreadcrumbPath(List<Category> allCategories) {
    final chain = getHierarchyChain(allCategories);
    return chain.map((c) => c.name.getOrCrash()).join(' › ');
  }

  @override
  List<Object?> get props => [
        uuid,
        name,
        parentId,
        isSynced,
        updatedAt,
        type,
        expectedMonthlyBudget,
        behavioralModifier,
      ];
}
