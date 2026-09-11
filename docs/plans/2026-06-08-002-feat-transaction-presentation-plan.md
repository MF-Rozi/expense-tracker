# feat: Transaction Presentation Layer & Expression Parser

**Status:** Active
**Date:** 2026-06-08
**Origin:** (see user request)

## Summary
Architectural specification for the Transaction module's presentation layer (Unit U5.4). This includes a reactive `TransactionCubit` for state management, a custom arithmetic expression evaluator for real-time amount calculation, and a premium "Financial Atelier" styled entry page featuring a custom calculator pad.

---

## Problem Frame
Users need a premium, frictionless way to enter financial transactions. This requires real-time arithmetic feedback (calculating totals as they type) and a high-end UI that maintains the "Financial Atelier" editorial aesthetic. The state management must bridge the gap between raw string expressions and the domain's strict `Amount` value object.

---

## Key Technical Decisions
- **Reactive State Management:** Use `TransactionCubit` to manage the lifecycle of a transaction entry, from raw input to submission.
- **Bento UI Pattern:** Reuse the `_BentoInputCell` and "layered capsule" patterns from the Category module for visual consistency.
- **Custom Expression Evaluator:** Implement a lightweight utility to sanitize and compute arithmetic strings (handles `+`, `-`, `*`, `/`, `x`, `÷`).
- **Calculator Pad:** Build a specialized digit/operator pad to replace the standard system keyboard for a focused entry experience.

---

## Implementation Units

### U5.4.1. Transaction State Management
**Goal:** Define the reactive logic for transaction entry.

**Files:**
- `lib/features/transaction/presentation/blocs/transaction_cubit.dart`
- `lib/features/transaction/presentation/blocs/transaction_state.dart`

**Approach:**
- **TransactionState:**
    - `rawExpression`: String (e.g., "15.00 + 12.50").
    - `parsedAmount`: double (The computed result of `rawExpression`).
    - `selectedCategory`: Category? (Relationship to the category module).
    - `type`: TransactionType (expense, income, investment).
    - `description`: String.
    - `date`: DateTime.
    - `isLoading`: bool.
    - `error`: String?.
- **TransactionCubit Methods:**
    - `updateExpression(String character)`: Appends digits or operators, triggering re-evaluation.
    - `clearExpression()`: Resets `rawExpression` and `parsedAmount`.
    - `evaluateExpression()`: Internal helper to update `parsedAmount`.
    - `selectCategory(Category category)`: Updates relationship.
    - `updateDescription(String text)`: Updates description state.
    - `submitTransaction()`: Validates state and calls `SaveTransactionUseCase`.

**Test Scenarios:**
- **State Transitions:** Verify `updateExpression` correctly updates `rawExpression` and emits computed `parsedAmount`.
- **Submission:** Verify `submitTransaction` emits `isLoading` and handles `Either<Failure, Unit>` result correctly.

---

### U5.4.2. Inline Expression Evaluator
**Goal:** Sanitize and compute arithmetic results from string input.

**Files:**
- `lib/features/transaction/presentation/utils/expression_evaluator.dart`

**Approach:**
- **Sanitization:**
    - Strip thousand dot delimiters (e.g., "1.000,00" -> "1000.00" depending on locale, or simply remove dots if used as separators).
    - Map 'x' -> '*' and '÷' -> '/'.
    - Remove invalid characters (only allow `0-9`, `.`, `+`, `-`, `*`, `/`).
- **Computation:**
    - Use a simple recursive descent parser or a lightweight evaluation strategy to compute the mathematical result.
    - Ensure division by zero is handled (returns 0 or keeps previous valid amount).
    - Precision: Use double precision for intermediate totals.

**Test Scenarios:**
- **Operators:** Verify `10 + 5`, `20 - 4`, `5 * 3`, `10 / 2`.
- **Sanitization:** Verify `1.000 + 500` -> `1500` (if dot is thousands) or `10.5 x 2` -> `21.0`.
- **Edge Cases:** Empty string -> 0.0, Division by zero -> handled gracefully.

---

### U5.4.3. Transaction Entry UI (Stitch-Inspired)
**Goal:** Build the premium "Financial Atelier" entry interface.

**Files:**
- `lib/features/transaction/presentation/pages/transaction_entry_page.dart`
- `lib/features/transaction/presentation/widgets/calculator_pad.dart`

**Approach:**
- **Master Display Card:**
    - Top section showing the large "IDR" total (Manrope, Extrabold, Primary #00113A).
    - Sub-text showing the running `rawExpression` preview (Inter, Slate Gray).
- **Bento Form Fields:**
    - Stacked `_BentoInputCell` components for Description, Date, and Category selection.
    - Category field should trigger a horizontal chip selector or a bottom-sheet picker.
- **Custom Calculator Pad:**
    - 4x4 or 4x5 grid of stadium-shaped buttons.
    - Digits 0-9, `00`, `.`.
    - Operators `+`, `-`, `x`, `÷` on the trailing column.
    - Large Action Button (Submit) using the primary brand gradient.
- **Aesthetics:**
    - Premium padding (24-32dp).
    - High-radius capsules for all buttons and cells.
    - Manrope for all numeric totals and titles; Inter for form labels.

**Test Scenarios:**
- **Interactions:** Tap digit -> updates display. Tap operator -> updates expression.
- **Visuals:** Verify Manrope is used for headers and total amounts.

---

## System-Wide Impact
- **Consistent UX:** Matches the Category module's bento-style design.
- **Frictionless Entry:** Calculator-first approach reduces keyboard switching.

---

## Risks & Dependencies
- **Parser Complexity:** Implementing a custom parser requires careful handling of operator precedence (PEMDAS/BODMAS).
- **Responsive Layout:** The custom pad must scale correctly on different screen sizes (using `LayoutBuilder` or `AspectRatio`).

---

## Sources & Research
- `docs/solutions/tooling-decisions/ui-design-system.md`: Visual tokens and capsule geometry.
- `lib/features/category/presentation/pages/category_form_page.dart`: Reference for `_BentoInputCell` implementation.
- `documents/stitch-export.html`: Reference for premium layout parameters.
