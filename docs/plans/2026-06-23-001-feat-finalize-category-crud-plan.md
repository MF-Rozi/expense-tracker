---
title: "feat: Finalize Category CRUD operations and Transaction selection"
type: feat
status: completed
date: 2026-06-23
---

# feat: Finalize Category CRUD operations and Transaction selection

Finalize the category edit flow, add dynamic child counts to category tiles, and verify the category selector integration in the transaction entry form.

---

## Problem Frame

The Category screen currently defines an empty `onEditTap` callback and category cards do not show sub-envelope child counts. In addition, we need to verify that transaction entry uses the global CategoryCubit state for its category picker to ensure end-to-end correctness before shipping transaction entry flows.

---

## Requirements

- R1. Edit Flow Activation: Tapping the edit button on any category tile must open the CategoryFormPage pre-filled with the category's current name and parent details.
- R2. Dynamic Child Counters: Category tiles must dynamically compute the count of their sub-envelopes (direct children) from the global state.
- R3. Card Subtitle Display: If a category has sub-envelopes (`childCount > 0`), the card subtitle must display `● $childCount Sub-envelopes`. If it has none, it must display `● Empty` (or default back to its category type label when the context is generic, e.g. in the transaction picker).
- R4. Transaction Entry Category Selector: The transaction form must load its available options from the global `CategoryCubit` state (`state.allCategories`) to ensure consistency.

---

## Key Technical Decisions

- KTD1. Navigation Cubit Preservation: When navigating to CategoryFormPage from the edit callback in CategoryManagePage, wrap the destination in `BlocProvider<CategoryCubit>.value` using the existing `blocContext` (similar to the add/new category flow) to ensure CategoryFormPage can access the cubit and save the changes.
- KTD2. CategoryListItem Constructor Backwards-Compatibility: Add an optional `int? childCount` to the `CategoryListItem` widget. This preserves its usage in the transaction entry page (where child counts are not requested or displayed) while supporting dynamic sub-envelope indicators on the manage page.

---

## Implementation Units

### U1. Edit Flow Navigation in CategoryManagePage

- **Goal:** Enable editing of categories by updating the `onEditTap` handler.
- **Files:**
  - [category_manage_page.dart](file:///home/mfrozi/Code/Mobile/flutter/expense-tracker/lib/features/category/presentation/pages/category_manage_page.dart)
- **Approach:**
  - Modify `onEditTap` of `CategoryList` inside `lib/features/category/presentation/pages/category_manage_page.dart`.
  - Use `Navigator.of(context).push(...)` with `MaterialPageRoute` wrapping `CategoryFormPage` in `BlocProvider<CategoryCubit>.value` using the `blocContext`. Pass both `activeParentUuid: state.activeParentUuid` and `categoryToEdit: category`.
- **Test Scenarios:**
  - Tap the edit icon on an existing category card. Verify the edit page opens.
  - Verify that saving changes updates the category in the cubit list.

### U2. Pre-fill name in CategoryFormPage

- **Goal:** Verify that CategoryFormPage correctly pre-fills its text field for editing.
- **Files:**
  - [category_form_page.dart](file:///home/mfrozi/Code/Mobile/flutter/expense-tracker/lib/features/category/presentation/pages/category_form_page.dart)
- **Approach:**
  - Confirm that `initState()` reads `widget.categoryToEdit?.name.getOrCrash()` and populates `_nameController`.
  - Confirm that the save button updates the existing category uuid rather than generating a new one. (This is already fully implemented, but needs to be confirmed/verified during local checks).

### U3. Update CategoryListItem to support child counts

- **Goal:** Add child count visualization to the category tiles.
- **Files:**
  - [category_list_item.dart](file:///home/mfrozi/Code/Mobile/flutter/expense-tracker/lib/features/category/presentation/widgets/category_list_item.dart)
- **Approach:**
  - Add `final int? childCount;` to `CategoryListItem`.
  - Update the constructor to accept `this.childCount`.
  - Update the subtitle text row in `build()`: if `childCount != null`, display `childCount! > 0 ? '● $childCount Sub-envelopes'.toUpperCase() : '● Empty'.toUpperCase()` (and omit the default `Container` dot and label). If `childCount == null`, preserve the default circle dot container and `typeData.label.toUpperCase()`.
- **Test Scenarios:**
  - Render a category list with `childCount` provided. Verify that categories with child envelopes show the correct sub-envelope counts.
  - Render a category with no children. Verify it displays "● EMPTY".

### U4. Add Dynamic Calculations to CategoryList

- **Goal:** Calculate sub-envelope child counts and pass them to the category items.
- **Files:**
  - [category_list.dart](file:///home/mfrozi/Code/Mobile/flutter/expense-tracker/lib/features/category/presentation/widgets/category_list.dart)
- **Approach:**
  - Import `package:flutter_bloc/flutter_bloc.dart` and `package:template/features/category/presentation/blocs/category_cubit.dart` in `category_list.dart`.
  - In `build()`, fetch all categories using `final allCategories = context.read<CategoryCubit>().state.allCategories;`.
  - Inside `itemBuilder`, calculate `childCount` for the current category by checking how many other categories have their `parentUuid` set to the current category's UUID: `allCategories.where((c) => c.parentUuid?.getOrCrash() == category.uuid.getOrCrash()).length`.
  - Pass the calculated `childCount` parameter to `CategoryListItem`.
- **Test Scenarios:**
  - Verify compile-time checks pass after adding imports.
  - Add sub-categories to a parent category. Verify that the parent card's counter immediately increments.

### U5. Verify Transaction Form Category Integration

- **Goal:** Verify that the category selector in the transaction entry form reads global categories.
- **Files:**
  - [transaction_entry_page.dart](file:///home/mfrozi/Code/Mobile/flutter/expense-tracker/lib/features/transaction/presentation/pages/transaction_entry_page.dart)
- **Approach:**
  - Confirm the page accesses the CategoryCubit correctly.
  - Verify that categories are displayed and can be selected to successfully map to the transaction.
